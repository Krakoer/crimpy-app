import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/consistency.dart';
import 'package:flutter_test/flutter_test.dart';

// 2026-06-01 is a Monday. The program starts Wednesday 3 June, so a strip
// ending Sunday 14 June opens on two days before it.
Program _program() => Program(
  id: 'p',
  coachId: 'c',
  userId: 'u',
  name: 'Block',
  startDate: DateTime(2026, 6, 3),
  durationWeeks: 6,
  createdAt: DateTime(2026, 6, 1),
  updatedAt: DateTime(2026, 6, 1),
);

const _monday = WeekSession(
  id: 'mon',
  trainingId: 't1',
  trainingTitle: 'Max Hangs',
  trainingType: 'crimpy',
  dayOfWeek: 0,
  position: 0,
);
const _mondayCore = WeekSession(
  id: 'mon-core',
  trainingId: 't2',
  trainingTitle: 'Core',
  trainingType: 'workout',
  dayOfWeek: 0,
  position: 1,
);
const _thursday = WeekSession(
  id: 'thu',
  trainingId: 't1',
  trainingTitle: 'Max Hangs',
  trainingType: 'crimpy',
  dayOfWeek: 3,
  position: 0,
);
const _flexible = WeekSession(
  id: 'flex',
  trainingId: 't3',
  trainingTitle: 'Mobility',
  trainingType: 'stretching',
  timesPerWeek: 2,
  position: 2,
);

Week _week(int number) => Week(
  id: 'w$number',
  programId: 'p',
  weekNumber: number,
  sessions: const [_monday, _mondayCore, _thursday, _flexible],
);

SessionModel _session(
  DateTime date, {
  String? slot,
  SessionActivity activity = SessionActivity.hangboard,
  bool isAssessment = false,
}) => SessionModel(
  name: 'session',
  isAssessment: isAssessment,
  origin: SessionOrigin.played,
  activity: activity,
  programSessionId: slot,
  date: date,
);

List<ConsistencyDay> _strip(
  List<SessionModel> sessions, {
  Map<int, Week>? weeks,
}) => programConsistencyDays(
  program: _program(),
  weeks: weeks ?? {1: _week(1), 2: _week(2)},
  sessions: sessions,
  today: DateTime(2026, 6, 14),
);

ConsistencyDay _on(List<ConsistencyDay> days, int juneDay) =>
    days.singleWhere((d) => d.day == DateTime(2026, 6, juneDay));

void main() {
  test('covers fourteen days, oldest first, ending today', () {
    final days = _strip([]);
    expect(days, hasLength(14));
    expect(days.first.day, DateTime(2026, 6, 1));
    expect(days.last.day, DateTime(2026, 6, 14));
  });

  test('days before the plan are not misses', () {
    final days = _strip([]);
    expect(_on(days, 1).mark, ConsistencyMark.beforePlan);
    expect(_on(days, 2).mark, ConsistencyMark.beforePlan);
    expect(_on(days, 3).mark, ConsistencyMark.rest);
  });

  test('a day with nothing scheduled is a rest day, not a miss', () {
    expect(_on(_strip([]), 5).mark, ConsistencyMark.rest);
  });

  test('a day that owed training and got none is missed', () {
    expect(_on(_strip([]), 4).mark, ConsistencyMark.missed);
  });

  test('a day owing two trainings with one done is partly kept', () {
    final day = _on(
      _strip([_session(DateTime(2026, 6, 8, 18), slot: 'mon')]),
      8,
    );
    expect(day.mark, ConsistencyMark.partial);
    expect(day.fraction, 0.5);
  });

  test('a day with everything done is kept', () {
    final days = _strip([
      _session(DateTime(2026, 6, 8, 18), slot: 'mon'),
      _session(DateTime(2026, 6, 8, 19), slot: 'mon-core'),
    ]);
    expect(_on(days, 8).mark, ConsistencyMark.kept);
  });

  test('a run started past midnight marks the evening it belongs to', () {
    final days = _strip([_session(DateTime(2026, 6, 5, 0, 30), slot: 'thu')]);
    expect(_on(days, 4).mark, ConsistencyMark.kept);
    expect(_on(days, 5).mark, ConsistencyMark.rest);
  });

  test('a rest day trained with a flexible training counts as kept', () {
    final days = _strip([_session(DateTime(2026, 6, 6, 10), slot: 'flex')]);
    expect(_on(days, 6).mark, ConsistencyMark.kept);
  });

  test('a climbing day settles the day, with its own mark', () {
    final days = _strip([
      _session(DateTime(2026, 6, 11, 19), activity: SessionActivity.climbing),
    ]);
    expect(_on(days, 11).mark, ConsistencyMark.climbed);
  });

  test('an assessment day settles the day, with its own mark', () {
    final days = _strip([
      _session(DateTime(2026, 6, 4, 9), isAssessment: true),
    ]);
    expect(_on(days, 4).mark, ConsistencyMark.assessed);
  });

  test('a week the coach has not published owes nothing', () {
    final days = _strip([], weeks: {1: _week(1)});
    expect(_on(days, 11).mark, ConsistencyMark.rest);
  });

  group('describeConsistency', () {
    test('describes the days rather than scoring them', () {
      final days = _strip([
        _session(DateTime(2026, 6, 4, 18), slot: 'thu'),
        _session(DateTime(2026, 6, 8, 18), slot: 'mon'),
      ]);
      expect(
        describeConsistency(days),
        '1 day kept, 1 day partly done, 1 day missed, 8 days rest. '
        '2 days before the plan started. Today is a rest day.',
      );
    });

    test('leaves today out of the counts, and says how far it is', () {
      final days = programConsistencyDays(
        program: _program(),
        weeks: {1: _week(1), 2: _week(2)},
        sessions: const [],
        today: DateTime(2026, 6, 8),
      );
      expect(describeConsistency(days), endsWith('Today so far: 0 of 2 done.'));
      // Thursday 4 June is the only miss: today, owing two, is not one.
      expect(
        describeConsistency(days),
        startsWith('1 day missed, 4 days rest.'),
      );
    });
  });
}
