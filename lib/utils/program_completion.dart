import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/training_model.dart';

/// Completion of program trainings is derived from the user's logged/ran
/// sessions rather than stored on the program: a scheduled training counts as
/// done when a session with a matching name exists on the relevant day(s).

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// A session matches a scheduled training when its name equals the training
/// title or starts with it (the run flow appends a date suffix).
bool _matchesTraining(String sessionName, String trainingTitle) {
  if (trainingTitle.isEmpty) return false;
  return sessionName == trainingTitle ||
      sessionName.startsWith('$trainingTitle -') ||
      sessionName.startsWith('$trainingTitle-');
}

/// How many matching sessions were completed during [weekNumber].
int completionsInWeek(
  List<SessionModel> sessions,
  Program program,
  int weekNumber,
  WeekSession scheduled,
) {
  final start = program.weekStart(weekNumber);
  final end = start.add(const Duration(days: 7));
  return sessions
      .where(
        (s) =>
            _matchesTraining(s.name, scheduled.trainingTitle) &&
            !s.date.isBefore(start) &&
            s.date.isBefore(end),
      )
      .length;
}

/// Whether a matching session was completed on [date].
bool isDoneOn(
  List<SessionModel> sessions,
  String trainingTitle,
  DateTime date,
) {
  return sessions.any(
    (s) => _sameDay(s.date, date) && _matchesTraining(s.name, trainingTitle),
  );
}

/// Whether a scheduled training is considered complete:
/// - day-of-week / everyday: a matching session exists on [date];
/// - times-per-week: the weekly target has been reached.
bool isScheduledTrainingDone(
  List<SessionModel> sessions,
  Program program,
  int weekNumber,
  WeekSession scheduled, {
  required DateTime date,
}) {
  if (scheduled.schedule == SessionSchedule.timesPerWeek) {
    final target = scheduled.timesPerWeek ?? 1;
    return completionsInWeek(sessions, program, weekNumber, scheduled) >=
        target;
  }
  return isDoneOn(sessions, scheduled.trainingTitle, date);
}
