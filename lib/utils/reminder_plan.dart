import 'package:crimpy/models/cached_program_schedule.dart';
import 'package:crimpy/models/notification_preferences.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/program_completion.dart';

/// First notification id reserved for training reminders. Reminders own the
/// whole block so rescheduling can clear it without touching anything else.
const int reminderIdBase = 900000;

/// Number of notification ids reserved, two slots over a 400 day cycle.
const int reminderIdBlockSize = 800;

/// Days of schedule planned ahead. Reminders are rewritten whenever the app
/// runs, so this only has to outlast a stretch of the app never being opened.
const int reminderHorizonDays = 14;

DateTime _dayAt(DateTime day, ReminderTime time) =>
    DateTime(day.year, day.month, day.day, time.hour, time.minute);

int _epochDay(DateTime day) =>
    DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

/// One reminder notification to be delivered at a specific instant.
class ReminderOccurrence {
  final DateTime when;

  /// Index of the reminder time that produced it, 0 for the primary time.
  final int slot;

  final String title;
  final String body;

  const ReminderOccurrence({
    required this.when,
    required this.slot,
    required this.title,
    required this.body,
  });

  /// Derived from the day and the slot so rescheduling the same plan reuses the
  /// same ids and never leaves a stale duplicate behind.
  int get notificationId =>
      reminderIdBase + (_epochDay(when) % 400) * 2 + (slot % 2);
}

/// The trainings still owed on a given day, as reminder labels.
List<String> _pendingLabels(
  Program program,
  Week week,
  int dayOffset,
  List<SessionModel> sessions,
  NotificationPreferences preferences,
  DateTime day,
) {
  bool isPending(WeekSession session) => !isScheduledTrainingDone(
    sessions,
    program,
    week.weekNumber,
    session,
    date: day,
  );

  final labels = <String>[];
  for (final session in week.sessionsOnDay(dayOffset)) {
    if (isPending(session)) labels.add(session.trainingTitle);
  }
  for (final session in week.timesPerWeekSessions) {
    final target = session.timesPerWeek ?? 1;
    if (!preferences
        .flexibleDaysFor(session.trainingId, target)
        .contains(dayOffset)) {
      continue;
    }
    if (!isPending(session)) continue;
    final done = completionsInWeek(sessions, program, week.weekNumber, session);
    labels.add('${session.trainingTitle} $done/$target this week');
  }
  return labels;
}

/// Every reminder to schedule over the next [horizonDays] days, from the
/// cached program schedule and the sessions already logged.
///
/// Days with nothing left to do produce no reminder at all, so a rest day or a
/// day whose trainings are already logged stays silent.
List<ReminderOccurrence> planReminders({
  required NotificationPreferences preferences,
  required CachedProgramSchedule? schedule,
  required List<SessionModel> sessions,
  required DateTime from,
  int horizonDays = reminderHorizonDays,
}) {
  if (!preferences.enabled || schedule == null) return [];

  final program = schedule.program;
  final times = preferences.times;
  final occurrences = <ReminderOccurrence>[];

  for (var offset = 0; offset < horizonDays; offset++) {
    final day = DateTime(from.year, from.month, from.day + offset);
    if (!program.isActiveOn(day)) continue;
    if (!preferences.activeWeekdays.contains(day.weekday - 1)) continue;

    final weekNumber = program.currentWeekNumber(day);
    final week = schedule.weekNumbered(weekNumber);
    if (week == null) continue;

    final labels = _pendingLabels(
      program,
      week,
      program.dayOffsetOf(weekNumber, day),
      sessions,
      preferences,
      day,
    );
    if (labels.isEmpty) continue;

    final title = labels.length == 1
        ? '1 training today'
        : '${labels.length} trainings today';
    final body = labels.join(', ');

    for (var slot = 0; slot < times.length; slot++) {
      final when = _dayAt(day, times[slot]);
      if (!when.isAfter(from)) continue;
      occurrences.add(
        ReminderOccurrence(when: when, slot: slot, title: title, body: body),
      );
    }
  }

  return occurrences;
}
