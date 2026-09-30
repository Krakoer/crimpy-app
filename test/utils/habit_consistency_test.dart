import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_habit.dart';
import 'package:crimpy/utils/consistency.dart';
import 'package:flutter_test/flutter_test.dart';

// 2026-09-28 is a Monday. Today is Wednesday 30 September, so the strip opens
// on Thursday 17 September.
final _today = DateTime(2026, 9, 30);

ActiveHabit _habit(TrainingHabit habit) =>
    ActiveHabit(habit, Training(id: habit.trainingId, title: 'Hangs'));

// Mondays and Wednesdays, set on Monday 21 September.
final _hangs = _habit(
  TrainingHabit.onWeekdays(
    trainingId: 'hangs',
    weekdays: const {0, 2},
    since: DateTime(2026, 9, 21),
  ),
);

// Twice a week, set later, on Thursday 24 September.
final _mobility = _habit(
  TrainingHabit.perWeek(
    trainingId: 'mobility',
    timesPerWeek: 2,
    since: DateTime(2026, 9, 24),
  ),
);

SessionModel _run(
  String? trainingId,
  DateTime date, {
  SessionActivity activity = SessionActivity.hangboard,
}) => SessionModel(
  name: 'run',
  isAssessment: false,
  origin: SessionOrigin.played,
  activity: activity,
  trainingId: trainingId,
  date: date,
);

List<ConsistencyDay> _strip(List<SessionModel> sessions) =>
    habitConsistencyDays(
      habits: [_hangs, _mobility],
      sessions: sessions,
      today: _today,
    );

ConsistencyMark _on(List<ConsistencyDay> days, int septemberDay) =>
    days.singleWhere((d) => d.day == DateTime(2026, 9, septemberDay)).mark;

void main() {
  test('days before the first habit was set are before the plan', () {
    final days = _strip([]);
    expect(days, hasLength(14));
    expect(_on(days, 17), ConsistencyMark.beforePlan);
    expect(_on(days, 20), ConsistencyMark.beforePlan);
    expect(_on(days, 22), ConsistencyMark.rest);
  });

  test('a day owes the habits due on its weekday', () {
    final days = _strip([_run('hangs', DateTime(2026, 9, 21, 18))]);
    expect(_on(days, 21), ConsistencyMark.kept);
    expect(_on(days, 23), ConsistencyMark.missed);
  });

  test('a run of a per week habit keeps a day that owed nothing', () {
    final days = _strip([_run('mobility', DateTime(2026, 9, 26, 10))]);
    expect(_on(days, 26), ConsistencyMark.kept);
    expect(_on(days, 27), ConsistencyMark.rest);
  });

  test('a climbing day settles the day', () {
    final days = _strip([
      _run(null, DateTime(2026, 9, 28, 19), activity: SessionActivity.climbing),
    ]);
    expect(_on(days, 28), ConsistencyMark.climbed);
  });

  test('a habit set later owes nothing on the days before it', () {
    final days = habitConsistencyDays(
      habits: [
        _hangs,
        _habit(
          TrainingHabit.onWeekdays(
            trainingId: 'core',
            weekdays: const {0},
            since: DateTime(2026, 9, 25),
          ),
        ),
      ],
      sessions: [_run('hangs', DateTime(2026, 9, 21, 18))],
      today: _today,
    );
    // Monday 21: only the hangs were a habit yet, and they were done.
    expect(_on(days, 21), ConsistencyMark.kept);
    // Monday 28: both were owed, neither done.
    final monday = days.singleWhere((d) => d.day == DateTime(2026, 9, 28));
    expect(monday.owed, 2);
    expect(monday.mark, ConsistencyMark.missed);
  });
}
