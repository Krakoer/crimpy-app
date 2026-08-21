import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/models/session.dart';

/// Completion of program trainings is derived from the user's sessions rather
/// than stored on the program: a scheduled training counts as done when a
/// session carrying its id exists on the relevant day(s).
///
/// The link is written by both paths that can complete a slot, the run flow and
/// the "log as done" button on the scheduled training screen, so names never
/// enter into it. Renaming a training, two slots sharing a title, or a session
/// played from the user's own library can no longer move the count.

/// Whether [session] was played from the scheduled slot [scheduledId].
bool _playedFrom(SessionModel session, String scheduledId) =>
    scheduledId.isNotEmpty && session.programSessionId == scheduledId;

/// How many sessions played from [scheduled] fall in [weekNumber].
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
            _playedFrom(s, scheduled.id) &&
            !s.date.isBefore(start) &&
            s.date.isBefore(end),
      )
      .length;
}

/// Whether a session played from [scheduledId] exists on [date].
bool isDoneOn(List<SessionModel> sessions, String scheduledId, DateTime date) {
  return sessions.any(
    (s) => _playedFrom(s, scheduledId) && isSameDay(s.date, date),
  );
}

/// Whether a scheduled training is considered complete:
/// - day-of-week / everyday: a session played from it exists on [date];
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
  return isDoneOn(sessions, scheduled.id, date);
}
