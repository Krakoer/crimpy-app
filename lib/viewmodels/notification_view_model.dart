import 'package:crimpy/logger.dart';
import 'package:crimpy/models/cached_program_schedule.dart';
import 'package:crimpy/models/notification_preferences.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/services/notification_preferences_service.dart';
import 'package:crimpy/services/notification_service.dart';
import 'package:crimpy/services/training_reminder_scheduler.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_view_model.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationService();

@Riverpod(keepAlive: true)
NotificationPreferencesService notificationPreferencesService(Ref ref) =>
    NotificationPreferencesService();

@Riverpod(keepAlive: true)
TrainingReminderScheduler trainingReminderScheduler(Ref ref) =>
    TrainingReminderScheduler(ref.watch(notificationServiceProvider));

/// The training reminder settings, and the actions that change them.
@Riverpod(keepAlive: true)
class NotificationPreferencesController
    extends _$NotificationPreferencesController {
  late NotificationPreferencesService _service;

  @override
  Future<NotificationPreferences> build() {
    _service = ref.watch(notificationPreferencesServiceProvider);
    return _service.load();
  }

  /// Turning reminders on needs the OS permission first: without it the
  /// scheduled notifications would be dropped silently.
  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      final granted = await ref
          .read(notificationServiceProvider)
          .requestPermission();
      if (!granted) return false;
    }
    await _update((current) => current.copyWith(enabled: enabled));
    return true;
  }

  Future<void> setPrimaryTime(ReminderTime time) =>
      _update((current) => current.copyWith(primaryTime: time));

  Future<void> setSecondaryTime(ReminderTime? time) => _update(
    (current) =>
        current.copyWith(secondaryTime: time, clearSecondaryTime: time == null),
  );

  Future<void> setActiveWeekdays(Set<int> weekdays) =>
      _update((current) => current.copyWith(activeWeekdays: weekdays));

  Future<void> setFlexibleDays(String trainingId, Set<int> weekdays) => _update(
    (current) => current.copyWith(
      flexibleTrainingDays: {
        ...current.flexibleTrainingDays,
        trainingId: weekdays,
      },
    ),
  );

  Future<void> _update(
    NotificationPreferences Function(NotificationPreferences) change,
  ) async {
    final updated = change(state.value ?? const NotificationPreferences());
    await _service.save(updated);
    if (ref.mounted) state = AsyncData(updated);
  }
}

/// The program schedule reminders are planned from: freshly fetched when the
/// user is online, otherwise the last copy stored on the device.
@Riverpod(keepAlive: true)
Future<CachedProgramSchedule?> programScheduleCache(Ref ref) async {
  final service = ref.watch(notificationPreferencesServiceProvider);
  try {
    final program = await ref.watch(activeProgramProvider.future);
    if (program == null) return service.loadSchedule();

    // A 14 day horizon starting mid week spans at most three Monday aligned
    // weeks. Weeks the coach has not published yet come back null.
    final firstWeek = program.currentWeekNumber(DateTime.now());
    final weeks = <Week>[];
    for (var number = firstWeek; number < firstWeek + 3; number++) {
      final week = await ref.watch(
        weekDetailProvider(program.id, number).future,
      );
      if (week != null) weeks.add(week);
    }

    final schedule = CachedProgramSchedule(
      program: program,
      weeks: weeks,
      cachedAt: DateTime.now(),
    );
    await service.saveSchedule(schedule);
    return schedule;
  } catch (error) {
    // Offline or a failing backend must not silence the reminders: fall back to
    // whatever was stored the last time the schedule was fetched.
    AppLoggerHelper.warning(
      'Program schedule fetch failed, using the cache: $error',
    );
    return service.loadSchedule();
  }
}

/// Rewrites the pending reminders whenever the settings, the program schedule
/// or the logged sessions change. Watched by the app shell so it stays alive.
@Riverpod(keepAlive: true)
Future<void> trainingReminderSync(Ref ref) async {
  final preferences = await ref.watch(
    notificationPreferencesControllerProvider.future,
  );

  // Without the opt-in there is nothing to plan, and no reason to reach for the
  // program or the session history.
  if (!preferences.enabled) {
    await ref
        .read(trainingReminderSchedulerProvider)
        .reschedule(
          preferences: preferences,
          schedule: null,
          sessions: const [],
        );
    return;
  }

  final schedule = await ref.watch(programScheduleCacheProvider.future);
  final sessions = await ref.watch(sessionsProvider.future);

  await ref
      .read(trainingReminderSchedulerProvider)
      .reschedule(
        preferences: preferences,
        schedule: schedule,
        sessions: sessions,
      );
  AppLoggerHelper.debug('Training reminders rescheduled');
}
