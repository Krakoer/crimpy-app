import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_habit.dart';
import 'package:crimpy/utils/habit_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

// 2026-09-28 is a Monday.
final _mondays = TrainingHabit.onWeekdays(
  trainingId: 't1',
  weekdays: const {0},
  since: DateTime(2026, 9, 1),
);
final _twiceAWeek = TrainingHabit.perWeek(
  trainingId: 't2',
  timesPerWeek: 2,
  since: DateTime(2026, 9, 1),
);

SessionModel _run(String trainingId, DateTime date) => SessionModel(
  name: 'run',
  isAssessment: false,
  origin: SessionOrigin.played,
  trainingId: trainingId,
  date: date,
);

Program _program(DateTime start, {int weeks = 4}) => Program(
  id: 'p',
  coachId: 'c',
  userId: 'u',
  name: 'Block',
  startDate: start,
  durationWeeks: weeks,
  createdAt: start,
  updatedAt: start,
);

void main() {
  test('a session of the training on the day does the habit', () {
    final monday = DateTime(2026, 9, 28);
    expect(habitDoneOn([], _mondays, monday), isFalse);
    expect(
      habitDoneOn([_run('t1', DateTime(2026, 9, 28, 18))], _mondays, monday),
      isTrue,
    );
    // Another training does not count for it.
    expect(
      habitDoneOn([_run('t9', DateTime(2026, 9, 28, 18))], _mondays, monday),
      isFalse,
    );
  });

  test('a run started past midnight counts for the evening before', () {
    expect(
      habitDoneOn(
        [_run('t1', DateTime(2026, 9, 29, 0, 30))],
        _mondays,
        DateTime(2026, 9, 28),
      ),
      isTrue,
    );
  });

  test('a per week habit is done once the week reaches its count', () {
    final sunday = DateTime(2026, 10, 4);
    final one = [_run('t2', DateTime(2026, 9, 29, 18))];
    expect(isHabitDone(one, _twiceAWeek, sunday), isFalse);
    final two = [...one, _run('t2', DateTime(2026, 10, 2, 18))];
    expect(isHabitDone(two, _twiceAWeek, sunday), isTrue);
    // The week before does not count towards this one.
    final lastWeek = [_run('t2', DateTime(2026, 9, 26, 18)), ...one];
    expect(habitCompletionsInWeek(lastWeek, _twiceAWeek, sunday), 1);
  });

  test('a program decides the day only while it runs', () {
    final day = DateTime(2026, 9, 30);
    expect(programCovers(null, day), isFalse);
    expect(programCovers(_program(DateTime(2026, 9, 28)), day), isTrue);
    // Not started yet: the habits stay in charge until it does.
    expect(programCovers(_program(DateTime(2026, 10, 5)), day), isFalse);
    // Over: they are back in charge.
    expect(
      programCovers(_program(DateTime(2026, 8, 3), weeks: 2), day),
      isFalse,
    );
  });
}
