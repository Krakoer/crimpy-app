import 'package:crimpy/logger.dart';
import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/repositories/availability_repository.dart';
import 'package:crimpy/utils/availability_reminder_plan.dart';
import 'package:crimpy/utils/availability_window.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/notification_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:crimpy/utils/datetimes.dart';

part 'availability_view_model.g.dart';

/// Availability repository, or null in guest mode: an athlete with no account
/// has no coach to declare a week to.
@Riverpod(keepAlive: true)
AvailabilityRepository? availabilityRepository(Ref ref) {
  if (!ref.watch(isAuthenticatedProvider)) return null;
  return AvailabilityRepository(ref.watch(apiClientProvider));
}

/// Declared weeks, with the window they were read for.
///
/// The window travels with the weeks rather than sitting beside them, so
/// nothing can read an answer out of the list without knowing which weeks that
/// list could have carried. A week the window does not cover is a week this
/// read says nothing about, which is not a week the athlete never declared.
typedef AvailabilityWeeks = ({
  List<WeekAvailability> weeks,
  AvailabilityWindow window,
});

/// The calendar weeks the athlete can edit, with what they planned in them:
/// this week and the next two, which is what the week switcher offers. Empty
/// when they are not signed in.
///
/// Windowed rather than the whole history, because a week now carries up to
/// 140 activities and the screen renders one week at a time. Which weeks the
/// athlete has ever declared is a different question, answered by
/// [declaredWeekStarts]: do not derive it from this list.
@Riverpod(keepAlive: true)
class MyAvailability extends _$MyAvailability {
  @override
  Future<AvailabilityWeeks> build() async {
    final repository = ref.watch(availabilityRepositoryProvider);
    final window = AvailabilityWindow.editable(DateTime.now());
    if (repository == null) {
      return (weeks: const <WeekAvailability>[], window: window);
    }
    return (weeks: await repository.getWeeks(window), window: window);
  }

  /// The week starting on that Monday, or a blank one when it was never
  /// declared, so the screen edits the same shape either way.
  ///
  /// Whether it was declared comes back with it: a blank week is a week the
  /// athlete has yet to answer, and an untouched one is still worth sending,
  /// since every day off is an answer the coach acts on.
  ///
  /// A week outside the window the list was read for is fetched on its own
  /// rather than reported undeclared. The window is pinned to the day the list
  /// was read, so an app left open across a Sunday midnight is asked for a week
  /// it never fetched, and answering "not declared" there would offer the
  /// athlete a blank week to overwrite what they had already sent.
  Future<({WeekAvailability week, bool declared})> weekOf(
    DateTime monday,
  ) async {
    final start = getStartOfWeek(monday);
    final held = await future;
    if (held.window.covers(start)) return _readWeek(held.weeks, start);

    final repository = ref.read(availabilityRepositoryProvider);
    if (repository == null) {
      return (week: WeekAvailability.empty(start), declared: false);
    }
    return _readWeek(
      await repository.getWeeks(AvailabilityWindow.single(start)),
      start,
    );
  }

  ({WeekAvailability week, bool declared}) _readWeek(
    List<WeekAvailability> weeks,
    DateTime start,
  ) {
    for (final week in weeks) {
      if (getStartOfWeek(week.weekStart) == start) {
        return (week: week, declared: true);
      }
    }
    return (week: WeekAvailability.empty(start), declared: false);
  }

  Future<void> saveWeek(WeekAvailability week) async {
    final repository = ref.read(availabilityRepositoryProvider);
    if (repository == null) return;
    await repository.saveWeek(week);
    ref.invalidateSelf();
    // The week just answered is one the planner must stop nudging about, and
    // it is a different read from the windowed list above.
    ref.invalidate(declaredWeekStartsProvider);
    if (ref.mounted) await future;
  }
}

/// Every calendar week the athlete has declared, dates alone and never
/// windowed.
///
/// Its own provider off its own endpoint, because the reminder planner drops a
/// nudge for a week that was already answered. Fed from the windowed list
/// instead, it would forget the weeks outside the window and nudge the athlete
/// about weeks they have already sent, which is the regression bounding the
/// list could otherwise introduce silently.
@Riverpod(keepAlive: true)
Future<Set<DateTime>> declaredWeekStarts(Ref ref) async {
  final repository = ref.watch(availabilityRepositoryProvider);
  if (repository == null) return {};
  return repository.getDeclaredWeekStarts();
}

/// The reminder the coach set, with the weeks already declared, mirrored to the
/// device so the nudge survives an offline launch. Dropped once the athlete is
/// resolved to be signed out, which is what stops a stale plan reaching the
/// next account.
@Riverpod(keepAlive: true)
Future<CachedAvailabilityPlan?> availabilityPlanCache(Ref ref) async {
  final service = ref.watch(notificationPreferencesServiceProvider);
  final repository = ref.watch(availabilityRepositoryProvider);

  // Waited on rather than read: the auth state is pending on every cold start,
  // and the repository is null for the whole of that window. Wiping on the null
  // alone would delete the mirror on each launch, and the offline launch it
  // exists for would then find nothing left to fall back to.
  if (isSignedOut(await settledAuth(ref))) {
    await service.saveAvailabilityPlan(null);
    return null;
  }
  // Signed in with no repository is the cold start still resolving, and an auth
  // failure says nothing about who the stored plan belongs to. Neither is a
  // sign out, so the mirror stands and this build answers from it.
  if (repository == null) return service.loadAvailabilityPlan();

  try {
    // Asked straight of the reminder endpoint rather than gated on the
    // enrollment: the endpoint already answers 404 for both real cases, which
    // is a null here, and a genuine failure throws into the fallback below, so
    // an outage leaves the mirror alone instead of writing "your coach set
    // none" into it and cancelling the pending nudges.
    final reminder = await repository.getReminder();
    // Taken from the unwindowed provider and never from myAvailabilityProvider,
    // which only holds the three weeks the screen edits. A plan built from
    // those would treat every week outside them as unanswered and nudge the
    // athlete for weeks they already sent.
    final declared = await ref.watch(declaredWeekStartsProvider.future);

    final plan = CachedAvailabilityPlan(
      reminder: reminder,
      declaredWeekStarts: declared,
    );
    await service.saveAvailabilityPlan(plan);
    return plan;
  } catch (error) {
    AppLoggerHelper.warning(
      'Availability plan fetch failed, using the cache: $error',
    );
    return service.loadAvailabilityPlan();
  }
}

/// Rewrites the pending availability reminders whenever the coach setting or
/// the declared weeks change. Watched by the app shell so it stays alive.
@Riverpod(keepAlive: true)
Future<void> availabilityReminderSync(Ref ref) async {
  final notifications = ref.watch(notificationServiceProvider);
  if (!notifications.canNotify) return;

  final plan = await ref.watch(availabilityPlanCacheProvider.future);
  final reminder = plan?.reminder;
  if (reminder == null || !reminder.enabled) {
    await notifications.cancelAvailabilityReminders();
    return;
  }

  // Scheduling into a permission that was never granted drops the reminder
  // silently. The ask lives in the coach notification prompt, which an enrolled
  // athlete already goes through.
  if (!await notifications.hasPermission()) return;

  final occurrences = planAvailabilityReminders(
    reminder: reminder,
    declaredWeekStarts: plan!.declaredWeekStarts,
    from: DateTime.now(),
  );
  if (occurrences.isEmpty) {
    await notifications.cancelAvailabilityReminders();
    return;
  }
  await notifications.scheduleAvailabilityReminders(occurrences);
}
