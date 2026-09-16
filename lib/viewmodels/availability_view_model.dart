import 'package:crimpy/logger.dart';
import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/repositories/availability_repository.dart';
import 'package:crimpy/utils/availability_reminder_plan.dart';
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

/// Every calendar week the athlete has declared. Empty when they are not
/// signed in.
@Riverpod(keepAlive: true)
class MyAvailability extends _$MyAvailability {
  @override
  Future<List<WeekAvailability>> build() async {
    final repository = ref.watch(availabilityRepositoryProvider);
    if (repository == null) return [];
    return repository.getWeeks();
  }

  /// The week starting on that Monday, or a blank one when it was never
  /// declared, so the screen edits the same shape either way.
  ///
  /// Whether it was declared comes back with it: a blank week is a week the
  /// athlete has yet to answer, and an untouched one is still worth sending,
  /// since every day off is an answer the coach acts on.
  Future<({WeekAvailability week, bool declared})> weekOf(
    DateTime monday,
  ) async {
    final weeks = await future;
    final start = getStartOfWeek(monday);
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
    if (ref.mounted) await future;
  }
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
    final weeks = await ref.watch(myAvailabilityProvider.future);

    final plan = CachedAvailabilityPlan(
      reminder: reminder,
      declaredWeekStarts: weeks.map((week) => week.weekStart).toSet(),
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
