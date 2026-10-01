import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_habit.dart';
import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/utils/habit_schedule.dart';
import 'package:crimpy/utils/program_completion.dart';

/// How many days the home screen's consistency strip covers, ending today.
const int consistencyStripDays = 14;

/// How one day of the strip reads. Every state is told apart by its shape, not
/// by its colour alone.
enum ConsistencyMark {
  /// Before the plan existed. Nobody could have kept a day they had no plan
  /// for, so it is not drawn as a miss.
  beforePlan,

  /// Nothing was owed: a rest day, or a week the coach has not published.
  rest,

  /// Training was owed and none of it was done.
  missed,

  /// Some of what the day owed was done.
  partial,

  /// Everything the day owed was done, or a rest day was trained on anyway.
  kept,

  /// A climbing session. It settles the day, whatever else was owed.
  climbed,

  /// An assessment. It settles the day too, whatever else was owed.
  assessed,
}

/// One day of the strip: what it owed, what of that was done, and what else
/// was trained on it.
class ConsistencyDay {
  final DateTime day;

  /// Whether the plan covered this day at all.
  final bool tracked;

  /// Trainings the plan prescribed on this day.
  final int owed;

  /// How many of [owed] were done.
  final int done;

  /// A session answering one of the week's flexible trainings was trained on
  /// this day.
  final bool trainedFlexible;

  final bool climbed;
  final bool assessed;

  const ConsistencyDay({
    required this.day,
    required this.tracked,
    this.owed = 0,
    this.done = 0,
    this.trainedFlexible = false,
    this.climbed = false,
    this.assessed = false,
  });

  /// The share of what was owed that was done, 0 to 1.
  double get fraction => owed == 0 ? 0 : (done / owed).clamp(0, 1).toDouble();

  ConsistencyMark get mark {
    if (!tracked) return ConsistencyMark.beforePlan;
    if (climbed) return ConsistencyMark.climbed;
    if (assessed) return ConsistencyMark.assessed;
    if (owed == 0) {
      return trainedFlexible ? ConsistencyMark.kept : ConsistencyMark.rest;
    }
    if (done == 0) return ConsistencyMark.missed;
    return done >= owed ? ConsistencyMark.kept : ConsistencyMark.partial;
  }
}

/// The last [consistencyStripDays] training days of [program], oldest first
/// and ending on [today].
///
/// [weeks] holds the published weeks by number; a day in a week missing from it
/// owes nothing. Sessions are placed on their training day, the way the program
/// counts them, so a run started after midnight marks the evening it belongs to.
List<ConsistencyDay> programConsistencyDays({
  required Program program,
  required Map<int, Week> weeks,
  required List<SessionModel> sessions,
  required DateTime today,
}) {
  final byDay = <DateTime, List<SessionModel>>{};
  for (final session in sessions) {
    byDay.putIfAbsent(session.trainingDay, () => []).add(session);
  }

  return [
    for (var back = consistencyStripDays - 1; back >= 0; back--)
      _programDay(
        program,
        weeks,
        sessions,
        byDay[addCalendarDays(today, -back)] ?? const [],
        addCalendarDays(today, -back),
      ),
  ];
}

ConsistencyDay _programDay(
  Program program,
  Map<int, Week> weeks,
  List<SessionModel> sessions,
  List<SessionModel> onDay,
  DateTime day,
) {
  if (!program.isActiveOn(day)) {
    return ConsistencyDay(day: day, tracked: false);
  }
  final weekNumber = program.currentWeekNumber(day);
  final week = weeks[weekNumber];
  final owed = week == null
      ? const <WeekSession>[]
      : week.sessionsOnDay(program.dayOffsetOf(weekNumber, day));
  final flexibleIds = {
    for (final flexible in week?.timesPerWeekSessions ?? const <WeekSession>[])
      flexible.id,
  };
  return ConsistencyDay(
    day: day,
    tracked: true,
    owed: owed.length,
    done: owed
        .where(
          (slot) => isScheduledTrainingDone(
            sessions,
            program,
            weekNumber,
            slot,
            date: day,
          ),
        )
        .length,
    trainedFlexible: onDay.any((s) => flexibleIds.contains(s.programSessionId)),
    climbed: onDay.any((s) => s.activity == SessionActivity.climbing),
    assessed: onDay.any((s) => s.isAssessment),
  );
}

/// The last [consistencyStripDays] training days of the athlete's own
/// [habits], oldest first and ending on [today], for a day no program covers.
///
/// A day before the earliest habit was set is before the plan. A day owes the
/// habits due on its weekday that were already set by then; a habit counted
/// per week is due on no day, so a session of it on a day owing nothing keeps
/// that day, as a flexible program training does.
///
/// A day a coach's [program] covered is drawn the way the program strip draws
/// it, from [programWeeks]: the program took precedence over the habits that
/// day, so they owed nothing on it.
List<ConsistencyDay> habitConsistencyDays({
  required List<ActiveHabit> habits,
  required List<SessionModel> sessions,
  required DateTime today,
  Program? program,
  Map<int, Week> programWeeks = const {},
}) {
  final byDay = <DateTime, List<SessionModel>>{};
  for (final session in sessions) {
    byDay.putIfAbsent(session.trainingDay, () => []).add(session);
  }
  final firstSet = habits.isEmpty
      ? null
      : habits
            .map((h) => h.habit.since)
            .reduce((a, b) => a.isBefore(b) ? a : b);

  return [
    for (var back = consistencyStripDays - 1; back >= 0; back--)
      if (programCovers(program, addCalendarDays(today, -back)))
        _programDay(
          program!,
          programWeeks,
          sessions,
          byDay[addCalendarDays(today, -back)] ?? const [],
          addCalendarDays(today, -back),
        )
      else
        _habitDay(
          habits,
          sessions,
          byDay[addCalendarDays(today, -back)] ?? const [],
          addCalendarDays(today, -back),
          firstSet,
        ),
  ];
}

ConsistencyDay _habitDay(
  List<ActiveHabit> habits,
  List<SessionModel> sessions,
  List<SessionModel> onDay,
  DateTime day,
  DateTime? firstSet,
) {
  if (firstSet == null || day.isBefore(firstSet)) {
    return ConsistencyDay(day: day, tracked: false);
  }
  final owed = [
    for (final habit in habitsDueOn(habits, day))
      if (!day.isBefore(habit.habit.since)) habit,
  ];
  final perWeekIds = {
    for (final habit in perWeekHabits(habits))
      if (!day.isBefore(habit.habit.since)) habit.trainingId,
  };
  return ConsistencyDay(
    day: day,
    tracked: true,
    owed: owed.length,
    done: owed.where((h) => habitDoneOn(sessions, h.habit, day)).length,
    trainedFlexible: onDay.any((s) => perWeekIds.contains(s.trainingId)),
    climbed: onDay.any((s) => s.activity == SessionActivity.climbing),
    assessed: onDay.any((s) => s.isAssessment),
  );
}

/// The strip said in words, for a screen reader: the one place an aggregate is
/// allowed, and phrased as a description rather than a score. Today is left out
/// of the counts, since a day still under way has missed nothing yet.
String describeConsistency(List<ConsistencyDay> days) {
  if (days.isEmpty) return 'No days to show';
  final counts = <ConsistencyMark, int>{};
  for (final day in days.sublist(0, days.length - 1)) {
    counts.update(day.mark, (n) => n + 1, ifAbsent: () => 1);
  }
  String dayCount(int n) => n == 1 ? '1 day' : '$n days';
  final parts = [
    if (counts[ConsistencyMark.kept] case final n?) '${dayCount(n)} kept',
    if (counts[ConsistencyMark.climbed] case final n?)
      '${dayCount(n)} climbing',
    if (counts[ConsistencyMark.assessed] case final n?)
      '${dayCount(n)} testing',
    if (counts[ConsistencyMark.partial] case final n?)
      '${dayCount(n)} partly done',
    if (counts[ConsistencyMark.missed] case final n?) '${dayCount(n)} missed',
    if (counts[ConsistencyMark.rest] case final n?) '${dayCount(n)} rest',
  ];
  final sentences = [
    parts.isEmpty ? 'Nothing planned in the last two weeks' : parts.join(', '),
    if (counts[ConsistencyMark.beforePlan] case final n?)
      '${dayCount(n)} before the plan started',
    _todaySoFar(days.last),
  ];
  return '${sentences.join('. ')}.';
}

String _todaySoFar(ConsistencyDay today) => switch (today.mark) {
  ConsistencyMark.beforePlan => 'The plan has not started today',
  ConsistencyMark.climbed => 'Today: climbed',
  ConsistencyMark.assessed => 'Today: tested',
  ConsistencyMark.rest => 'Today is a rest day',
  _ when today.owed == 0 => 'Today: trained',
  _ => 'Today so far: ${today.done} of ${today.owed} done',
};
