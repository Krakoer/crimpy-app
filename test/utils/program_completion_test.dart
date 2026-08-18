import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/program_completion.dart';
import 'package:flutter_test/flutter_test.dart';

Program _program() => Program(
  id: 'p',
  coachId: 'c',
  userId: 'u',
  name: 'Block',
  startDate: DateTime(2026, 6, 1),
  durationWeeks: 6,
  createdAt: DateTime(2026, 6, 1),
  updatedAt: DateTime(2026, 6, 1),
);

WeekSession _daySession() => const WeekSession(
  id: 's1',
  trainingId: 't1',
  trainingTitle: 'Max Hangs',
  trainingType: 'crimpy',
  dayOfWeek: 2, // Wednesday -> 2026-06-03
  position: 0,
);

WeekSession _flexSession() => const WeekSession(
  id: 's2',
  trainingId: 't2',
  trainingTitle: 'Mobility',
  trainingType: 'stretching',
  timesPerWeek: 3,
  position: 1,
);

SessionModel _session(String name, DateTime date) => SessionModel(
  name: name,
  isAssessment: false,
  origin: SessionOrigin.logged,
  date: date,
);

void main() {
  test(
    'day-of-week session is done when a matching session exists that day',
    () {
      final program = _program();
      final s = _daySession();
      final date = s.scheduledDate(program, 1)!;

      expect(isScheduledTrainingDone([], program, 1, s, date: date), isFalse);

      // The run flow names sessions "<title> - <date>".
      final sessions = [_session('Max Hangs - 03/06/2026', date)];
      expect(
        isScheduledTrainingDone(sessions, program, 1, s, date: date),
        isTrue,
      );
    },
  );

  test('times-per-week session is done once the weekly target is reached', () {
    final program = _program();
    final s = _flexSession();

    final two = [
      _session('Mobility', DateTime(2026, 6, 2)),
      _session('Mobility', DateTime(2026, 6, 4)),
    ];
    expect(completionsInWeek(two, program, 1, s), 2);
    expect(
      isScheduledTrainingDone(two, program, 1, s, date: DateTime(2026, 6, 4)),
      isFalse,
    );

    final three = [...two, _session('Mobility', DateTime(2026, 6, 6))];
    expect(
      isScheduledTrainingDone(three, program, 1, s, date: DateTime(2026, 6, 6)),
      isTrue,
    );
  });

  test(
    'weeks always start on Monday even when the program starts mid-week',
    () {
      // Program starting on a Sunday still has Monday-anchored weeks.
      final program = Program(
        id: 'p',
        coachId: 'c',
        userId: 'u',
        name: 'Block',
        startDate: DateTime(2026, 6, 7), // Sunday
        durationWeeks: 6,
        createdAt: DateTime(2026, 6, 7),
        updatedAt: DateTime(2026, 6, 7),
      );
      expect(program.weekStart(1), DateTime(2026, 6, 1)); // Monday
      expect(program.weekStart(2), DateTime(2026, 6, 8));
      // Monday 15 Jun is the first day (offset 0) of week 3.
      expect(program.currentWeekNumber(DateTime(2026, 6, 15)), 3);
      expect(program.dayOffsetOf(3, DateTime(2026, 6, 15)), 0);
    },
  );

  test('sessions outside the week are not counted', () {
    final program = _program();
    final s = _flexSession();
    // Week 1 is 1-7 Jun; this is week 2.
    final sessions = [_session('Mobility', DateTime(2026, 6, 9))];
    expect(completionsInWeek(sessions, program, 1, s), 0);
  });
}
