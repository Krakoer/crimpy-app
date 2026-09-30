import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_habit.dart';
import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/utils/format.dart';

/// Whether a coach's program decides what [day] owes. It does from its start
/// date to its end: a program not started yet leaves the athlete's own habits
/// in charge until it does, and one that ended hands them back.
bool programCovers(Program? program, DateTime day) =>
    program != null && program.isActiveOn(day);

bool _answers(SessionModel session, TrainingHabit habit) =>
    session.trainingId == habit.trainingId;

/// Whether a session of [habit]'s training falls on the training day [day].
bool habitDoneOn(
  List<SessionModel> sessions,
  TrainingHabit habit,
  DateTime day,
) => sessions.any((s) => _answers(s, habit) && isSameDay(s.trainingDay, day));

/// Sessions of [habit]'s training in the Monday-aligned week holding [day].
int habitCompletionsInWeek(
  List<SessionModel> sessions,
  TrainingHabit habit,
  DateTime day,
) {
  final start = getStartOfWeek(day);
  final end = addCalendarDays(start, 7);
  return sessions.where((s) {
    if (!_answers(s, habit)) return false;
    final trained = s.trainingDay;
    return !trained.isBefore(start) && trained.isBefore(end);
  }).length;
}

/// Whether [habit] asks nothing more of [day]: its session is done that day,
/// or, for a habit counted per week, the week's count is reached.
bool isHabitDone(
  List<SessionModel> sessions,
  TrainingHabit habit,
  DateTime day,
) {
  final times = habit.timesPerWeek;
  if (times != null) {
    return habitCompletionsInWeek(sessions, habit, day) >= times;
  }
  return habitDoneOn(sessions, habit, day);
}

/// The habits due on [day] specifically, in the order they are listed.
List<ActiveHabit> habitsDueOn(List<ActiveHabit> habits, DateTime day) => [
  for (final habit in habits)
    if (habit.habit.isDueOn(day)) habit,
];

/// The habits counted per week, which are due on no day in particular.
List<ActiveHabit> perWeekHabits(List<ActiveHabit> habits) => [
  for (final habit in habits)
    if (habit.habit.isPerWeek) habit,
];
