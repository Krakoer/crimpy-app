import 'package:clock/clock.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/consistency.dart';
import 'package:crimpy/viewmodels/consistency_view_model.dart';
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

// 2026-06-01 is a Monday; each week owes one training on its Monday.
Program _program({int durationWeeks = 6}) => Program(
  id: 'p',
  coachId: 'c',
  userId: 'u',
  name: 'Block',
  startDate: DateTime(2026, 6, 1),
  durationWeeks: durationWeeks,
  createdAt: DateTime(2026, 6, 1),
  updatedAt: DateTime(2026, 6, 1),
);

Week _week(int number) => Week(
  id: 'w$number',
  programId: 'p',
  weekNumber: number,
  sessions: [
    WeekSession(
      id: 'mon-$number',
      trainingId: 't1',
      trainingTitle: 'Max Hangs',
      trainingType: 'crimpy',
      dayOfWeek: 0,
      position: 0,
    ),
  ],
);

Future<List<ConsistencyDay>?> _stripAt(
  DateTime now, {
  Program? program,
  List<SessionModel> sessions = const [],
}) => withClock(Clock.fixed(now), () async {
  final container = ProviderContainer.test(
    overrides: [
      activeProgramProvider.overrideWith((ref) async => program),
      for (var number = 1; number <= 6; number++)
        weekDetailProvider(
          'p',
          number,
        ).overrideWith((ref) async => _week(number)),
      sessionsProvider.overrideWith(() => _FixedSessions(sessions)),
    ],
  );
  return container.read(programConsistencyProvider.future);
});

void main() {
  test('reads every week the fourteen days fall in', () async {
    // Wednesday 17 June: the window opens on Thursday 4 June, in week 1, and
    // runs through weeks 2 and 3.
    final days = await _stripAt(
      DateTime(2026, 6, 17, 18),
      program: _program(),
      sessions: [
        SessionModel(
          name: 'hangs',
          isAssessment: false,
          origin: SessionOrigin.played,
          programSessionId: 'mon-2',
          date: DateTime(2026, 6, 8, 18),
        ),
      ],
    );

    ConsistencyMark on(int juneDay) =>
        days!.singleWhere((d) => d.day == DateTime(2026, 6, juneDay)).mark;
    expect(on(8), ConsistencyMark.kept);
    expect(on(15), ConsistencyMark.missed);
    expect(on(9), ConsistencyMark.rest);
  });

  test('has nothing to draw without a program', () async {
    expect(await _stripAt(DateTime(2026, 6, 17, 18)), isNull);
  });

  test('has nothing to draw once the program is over', () async {
    expect(
      await _stripAt(
        DateTime(2026, 7, 20, 18),
        program: _program(durationWeeks: 2),
      ),
      isNull,
    );
  });
}
