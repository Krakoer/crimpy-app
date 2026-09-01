import 'package:crimpy/logger.dart';
import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/repositories/availability_repository.dart';
import 'package:crimpy/utils/availability_reminder_plan.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/coach_view_model.dart';
import 'package:crimpy/viewmodels/notification_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  Future<WeekAvailability> weekOf(DateTime monday) async {
    final weeks = await future;
    final start = mondayOf(monday);
    for (final week in weeks) {
      if (mondayOf(week.weekStart) == start) return week;
    }
    return WeekAvailability.empty(start);
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
/// device so the nudge survives an offline launch. Null once when the athlete
/// is signed out, which is what stops a stale plan reaching the next account.
@Riverpod(keepAlive: true)
Future<CachedAvailabilityPlan?> availabilityPlanCache(Ref ref) async {
  final service = ref.watch(notificationPreferencesServiceProvider);
  final repository = ref.watch(availabilityRepositoryProvider);
  if (repository == null) {
    await service.saveAvailabilityPlan(null);
    return null;
  }

  try {
    // No coach is an answer rather than a failure, and so is a coach who set no
    // reminder: both are stored as a plan with no reminder, so the next launch
    // reads "off" instead of falling back to a mirror that never expires.
    final enrollment = await ref.watch(coachEnrollmentProvider.future);
    final reminder = enrollment == null ? null : await repository.getReminder();
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
