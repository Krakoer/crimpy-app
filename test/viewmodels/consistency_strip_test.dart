import 'package:clock/clock.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_habit.dart';
import 'package:crimpy/utils/consistency.dart';
import 'package:crimpy/viewmodels/consistency_view_model.dart';
import 'package:crimpy/viewmodels/habit_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedSessions extends Sessions {
  _FixedSessions(this.sessions);
  final List<SessionModel> sessions;

  @override
  Future<List<SessionModel>> build() async => sessions;
}

// Wednesday 30 September 2026, evening. The strip opens on Thursday 17.
final _now = DateTime(2026, 9, 30, 18);

// Hangs on Mondays and Wednesdays, set well before the window opens.
final _hangs = ActiveHabit(
  TrainingHabit.onWeekdays(
    trainingId: 'hangs',
    weekdays: const {0, 2},
    since: DateTime(2026, 9, 1),
  ),
  const Training(id: 'hangs', title: 'Hangs'),
);

// A coach's program from Monday 14 September, owing one training each Monday.
Program _program({required DateTime start, int durationWeeks = 2}) => Program(
  id: 'p',
  coachId: 'c',
  userId: 'u',
  name: 'Block',
  startDate: start,
  durationWeeks: durationWeeks,
  createdAt: start,
  updatedAt: start,
);

Week _week(int number) => Week(
  id: 'w$number',
  programId: 'p',
  weekNumber: number,
  sessions: [
    WeekSession(
      id: 'mon-$number',
      trainingId: 'program-training',
      trainingTitle: 'Max Hangs',
      trainingType: 'crimpy',
      dayOfWeek: 0,
      position: 0,
    ),
  ],
);

SessionModel _run(DateTime date, {String? trainingId, String? slot}) =>
    SessionModel(
      name: 'run',
      isAssessment: false,
      origin: SessionOrigin.played,
      trainingId: trainingId,
      programSessionId: slot,
      date: date,
    );

Future<List<ConsistencyDay>?> _strip({
  Program? program,
  List<ActiveHabit> habits = const [],
  List<SessionModel> sessions = const [],
}) => withClock(Clock.fixed(_now), () async {
  final container = ProviderContainer.test(
    overrides: [
      activeProgramProvider.overrideWith((ref) async => program),
      for (var number = 1; number <= 6; number++)
        weekDetailProvider(
          'p',
          number,
        ).overrideWith((ref) async => _week(number)),
      sessionsProvider.overrideWith(() => _FixedSessions(sessions)),
      activeHabitsProvider.overrideWith((ref) async => habits),
    ],
  );
  return container.read(consistencyStripProvider.future);
});

ConsistencyDay _on(List<ConsistencyDay> days, int septemberDay) =>
    days.singleWhere((d) => d.day == DateTime(2026, 9, septemberDay));

void main() {
  test('draws the program while one covers today, habits or not', () async {
    final days = await _strip(
      program: _program(start: DateTime(2026, 9, 21)),
      habits: [_hangs],
    );

    // Before the program started is before the plan, not a habit day.
    expect(_on(days!, 17).mark, ConsistencyMark.beforePlan);
    // Wednesday 23: the program owes nothing, the habit is not asked about.
    expect(_on(days, 23).mark, ConsistencyMark.rest);
    expect(_on(days, 28).mark, ConsistencyMark.missed);
  });

  test('draws the habits when no program covers today', () async {
    final days = await _strip(
      habits: [_hangs],
      sessions: [_run(DateTime(2026, 9, 21, 18), trainingId: 'hangs')],
    );

    expect(days, hasLength(consistencyStripDays));
    expect(_on(days!, 21).mark, ConsistencyMark.kept);
    expect(_on(days, 23).mark, ConsistencyMark.missed);
    expect(_on(days, 22).mark, ConsistencyMark.rest);
  });

  test('draws the days an ended program covered as the program decided '
      'them', () async {
    // The program ran 14-27 September and the athlete followed it, leaving
    // the hangs habit aside as the app told them to.
    final days = await _strip(
      program: _program(start: DateTime(2026, 9, 14)),
      habits: [_hangs],
      sessions: [_run(DateTime(2026, 9, 21, 18), slot: 'mon-2')],
    );

    // Monday 21: the program's training was done, so the day was kept,
    // though the habit's training was not run.
    expect(_on(days!, 21).mark, ConsistencyMark.kept);
    // Wednesday 23 is a habit day, but the program covered it and owed
    // nothing on it.
    expect(_on(days, 23).mark, ConsistencyMark.rest);
    expect(_on(days, 23).owed, 0);
    // Once the program is over the habit is owed again.
    expect(_on(days, 28).mark, ConsistencyMark.missed);
  });

  test('draws nothing with neither a program nor a habit', () async {
    expect(await _strip(), isNull);
    expect(
      await _strip(program: _program(start: DateTime(2026, 8, 3))),
      isNull,
    );
  });
}
