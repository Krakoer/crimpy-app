import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/utils/reminder_plan.dart';

/// First notification id reserved for availability reminders. Its own block, so
/// rewriting this plan never clears the training reminders at [reminderIdBase]
/// or the coach answers at 800000.
const int availabilityReminderIdBase = 700000;

/// One reminder a week over the horizon leaves room to spare.
const int availabilityReminderIdBlockSize = 8;

/// Days planned ahead. Rewritten whenever the app runs, like the training
/// reminders, so this only has to outlast a stretch of the app never opening.
const int availabilityReminderHorizonDays = 14;

const String _availabilityReminderTitle = 'Your week';
const String _availabilityReminderBody =
    'Tell your coach when you can train next week.';

/// The reminders owed between [from] and the end of the horizon.
///
/// One occurrence per configured weekday, skipped when the week it is nudging
/// about has already been declared. The instant is built in device local time,
/// the way [planReminders] does: the coach picks a wall clock hour and every
/// athlete gets it in their own timezone, which is the only reading available
/// since the backend stores no timezone and schedules nothing itself.
List<ReminderOccurrence> planAvailabilityReminders({
  required CoachAvailabilityReminder? reminder,
  required Set<DateTime> declaredWeekStarts,
  required DateTime from,
  int horizonDays = availabilityReminderHorizonDays,
}) {
  if (reminder == null || !reminder.enabled) return [];

  final declared = declaredWeekStarts.map(mondayOf).toSet();
  final occurrences = <ReminderOccurrence>[];

  for (var offset = 0; offset < horizonDays; offset++) {
    final day = DateTime(from.year, from.month, from.day + offset);
    if (day.weekday - 1 != reminder.dayOfWeek) continue;

    final when = DateTime(
      day.year,
      day.month,
      day.day,
      reminder.time.hour,
      reminder.time.minute,
    );
    if (!when.isAfter(from)) continue;

    // The week the nudge is about is the one starting after the day it fires,
    // which is the point of asking on a Friday for a program written Saturday.
    final target = mondayOf(day).add(const Duration(days: 7));
    if (declared.contains(target)) continue;

    occurrences.add(_availabilityOccurrence(when: when, weekStart: target));
  }

  return occurrences;
}

ReminderOccurrence _availabilityOccurrence({
  required DateTime when,
  required DateTime weekStart,
}) => ReminderOccurrence(
  when: when,
  slot: 0,
  title: _availabilityReminderTitle,
  body: _availabilityReminderBody,
  idOverride: availabilityReminderIdBase + (_weekIndex(weekStart) % 8),
);

/// Derived from the week being nudged about, so replanning the same week reuses
/// the same id rather than leaving a stale duplicate behind.
int _weekIndex(DateTime weekStart) =>
    DateTime.utc(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    ).millisecondsSinceEpoch ~/
    (Duration.millisecondsPerDay * 7);
