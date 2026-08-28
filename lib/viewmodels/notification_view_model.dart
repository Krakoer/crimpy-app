import 'package:crimpy/logger.dart';
import 'package:crimpy/models/cached_program_schedule.dart';
import 'package:crimpy/models/notification_preferences.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/services/coach_notification_prompt_service.dart';
import 'package:crimpy/services/coach_reply_announcer.dart';
import 'package:crimpy/services/notification_preferences_service.dart';
import 'package:crimpy/services/notification_service.dart';
import 'package:crimpy/services/training_reminder_scheduler.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/coach_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_view_model.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  final service = NotificationService();
  ref.onDispose(service.dispose);
  return service;
}

/// Fires when the user taps snooze on a reminder. The app shell answers it by
/// asking which hour to postpone to.
@Riverpod(keepAlive: true)
Stream<DateTime> snoozeRequests(Ref ref) =>
    ref.watch(notificationServiceProvider).snoozeRequests;

@Riverpod(keepAlive: true)
NotificationPreferencesService notificationPreferencesService(Ref ref) =>
    NotificationPreferencesService();

@Riverpod(keepAlive: true)
TrainingReminderScheduler trainingReminderScheduler(Ref ref) =>
    TrainingReminderScheduler(ref.watch(notificationServiceProvider));

/// Whether the OS still accepts our notifications. Revoking the permission in
/// the system settings leaves [NotificationPreferences.enabled] untouched, so
/// the screen has to ask rather than trust it. Auto disposed to re-ask on every
/// visit.
@riverpod
Future<bool> reminderPermission(Ref ref) =>
    ref.watch(notificationServiceProvider).hasPermission();

/// The training reminder settings, and the actions that change them.
@Riverpod(keepAlive: true)
class NotificationPreferencesController
    extends _$NotificationPreferencesController {
  late NotificationPreferencesService _service;

  @override
  Future<NotificationPreferences> build() async {
    _service = ref.watch(notificationPreferencesServiceProvider);

    // Reminder settings describe an account, not a device. Keeping them across a
    // sign out would opt the next user in to someone else's program.
    if (isSignedOut(ref.watch(authStateProvider))) {
      await _service.clear();
      return const NotificationPreferences();
    }
    // A snooze that has already fired is spent, and would otherwise be carried
    // around forever and re-planned on every launch.
    return (await _service.load()).withoutStaleSnooze(DateTime.now());
  }

  /// Postpones the current reminder to [when]. The plan picks it up as one
  /// extra occurrence, so it survives every later reschedule.
  Future<void> snoozeUntil(DateTime when) =>
      _update((current) => current.copyWith(snoozedUntil: when));

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
    // Waiting on the load rather than falling back to the defaults: editing
    // mid load would otherwise persist defaults plus the one change.
    final updated = change(await future);
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
    // No active program is an answer, not a failure: the cached copy belongs to
    // a program that ended or to the account that just signed out. Only the
    // fetch failure below is allowed to fall back to it.
    if (program == null) {
      await service.saveSchedule(null);
      return null;
    }

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

@Riverpod(keepAlive: true)
CoachReplyAnnouncer coachReplyAnnouncer(Ref ref) =>
    CoachReplyAnnouncer(ref.watch(notificationServiceProvider));

/// Tells the athlete about the answers their coach wrote, whenever the session
/// history changes. Watched by the app shell so it stays alive.
///
/// Signing out clears what has been announced instead: the answers belong to
/// the account leaving, and the guest store has none to announce.
@Riverpod(keepAlive: true)
Future<void> coachReplySync(Ref ref) async {
  final announcer = ref.watch(coachReplyAnnouncerProvider);

  // Awaited rather than read off the current state: auth is still loading on
  // every cold start, and the session history answers from the guest store
  // until it resolves. Announcing against that store would say nothing was
  // unread and wipe the record of what has already been announced.
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    await announcer.clear();
    // Whether the permission was asked for belongs to the account leaving too,
    // so the next athlete on this device gets asked rather than inheriting a
    // refusal that was never theirs.
    await ref.read(coachNotificationPromptServiceProvider).clear();
    return;
  }
  await announcer.announce(await ref.watch(sessionsProvider.future));
}

@Riverpod(keepAlive: true)
CoachNotificationPromptService coachNotificationPromptService(Ref ref) =>
    CoachNotificationPromptService();

/// Which permission ask a coached athlete is due, null when none is.
///
/// Notifications are only ever asked for from the reminder settings, which an
/// athlete who does not want a nudge to train never opens. Their coach's
/// answers then have nowhere to land, so the ask has to happen on its own.
@Riverpod(keepAlive: true)
Future<CoachNotificationPrompt?> pendingCoachNotificationPrompt(Ref ref) async {
  final notifications = ref.watch(notificationServiceProvider);
  if (!notifications.canNotify) return null;

  // Awaited for the same reason as the announcer above: auth is still loading
  // on a cold start, and asking before it resolves would read no coach and no
  // history, and answer that nothing is due.
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return null;

  final enrollment = await ref.watch(coachEnrollmentProvider.future);
  if (enrollment == null) return null;

  if (await notifications.hasPermission()) return null;

  final service = ref.watch(coachNotificationPromptServiceProvider);
  final sessions = await ref.watch(sessionsProvider.future);
  final hasUnreadReply = sessions.any((session) => session.hasUnreadCoachReply);
  if (hasUnreadReply &&
      !await service.hasAsked(CoachNotificationPrompt.unreadReply)) {
    return CoachNotificationPrompt.unreadReply;
  }
  if (!await service.hasAsked(CoachNotificationPrompt.enrolled)) {
    return CoachNotificationPrompt.enrolled;
  }
  return null;
}
