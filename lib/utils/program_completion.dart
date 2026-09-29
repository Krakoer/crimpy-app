import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/utils/datetimes.dart';
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
///
/// A session counts on its training day ([trainingDayOf]), not its calendar
/// day, so a training started after midnight still answers the evening's slot.
///
/// Origin deliberately does not enter into it either. A slot whose training has
/// nothing to step through is completed by hand, so a logged session answers a
/// prescription just as a played one does. The server draws the line elsewhere:
/// only a played session freezes the coach's week.

/// Whether [session] answers the scheduled slot [scheduledId].
bool _answers(SessionModel session, String scheduledId) =>
    session.programSessionId == scheduledId;

/// How many sessions answering [scheduled] fall in [weekNumber].
int completionsInWeek(
  List<SessionModel> sessions,
  Program program,
  int weekNumber,
  WeekSession scheduled,
) {
  final start = program.weekStart(weekNumber);
  final end = addCalendarDays(start, 7);
  return sessions.where((s) {
    if (!_answers(s, scheduled.id)) return false;
    final day = s.trainingDay;
    return !day.isBefore(start) && day.isBefore(end);
  }).length;
}

/// Whether a session answering the slot [scheduledId] exists on the training
/// day [date]. Private
/// because a caller passing a training title instead would compile and silently
/// report that nothing is ever done.
bool _isDoneOn(List<SessionModel> sessions, String scheduledId, DateTime date) {
  return sessions.any(
    (s) => _answers(s, scheduledId) && isSameDay(s.trainingDay, date),
  );
}

/// Whether a scheduled training is considered complete:
/// - day-of-week / everyday: a session answering it exists on [date];
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
  return _isDoneOn(sessions, scheduled.id, date);
}
