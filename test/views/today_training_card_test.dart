import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/widgets/today_training_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoSessions extends Sessions {
  @override
  Future<List<SessionModel>> build() async => [];
}

const _programId = 'program-1';
const _trainingId = 'training-1';

Program _program() {
  final today = DateTime.now();
  return Program(
    id: _programId,
    coachId: 'coach-1',
    userId: 'user-1',
    name: 'Winter block',
    startDate: DateTime(today.year, today.month, today.day),
    durationWeeks: 4,
    createdAt: today,
    updatedAt: today,
  );
}

const _coreWork = Training(
  id: _trainingId,
  title: 'Core work',
  items: [
    TrainingItem(
      id: 'plank-1',
      type: TrainingItemType.exercise,
      position: 0,
      exerciseName: 'Plank',
      duration: 30,
    ),
  ],
);

const _hangAssessmentId = 'assessment-hang';

const _hangDefinition = AssessmentDefinition(
  id: _hangAssessmentId,
  label: 'Max hang',
  unit: AssessmentUnit.seconds,
  trainingId: 'coach-training-1',
);

/// The same plank, prescribed as 80 percent of a hang the athlete has measured
/// at 90s, with the coach's own number as the fallback.
const _percentCoreWork = Training(
  id: _trainingId,
  title: 'Core work',
  items: [
    TrainingItem(
      id: 'plank-1',
      type: TrainingItemType.exercise,
      position: 0,
      exerciseName: 'Plank',
      duration: 30,
      variableTargets: {
        'duration': VariableTarget(
          assessmentId: _hangAssessmentId,
          percent: 80,
          fallback: 30,
        ),
      },
    ),
  ],
  referencedAssessments: [_hangDefinition],
);

WeekSession _weekSession({List<SessionOverride> overrides = const []}) =>
    WeekSession(
      id: 'week-session-1',
      trainingId: _trainingId,
      trainingTitle: 'Core work',
      trainingType: 'workout',
      isEveryday: true,
      position: 0,
      overrides: overrides,
    );

/// Pumps the home card with [session] scheduled today in an active program
/// whose training is [_coreWork].
Future<void> _pump(
  WidgetTester tester,
  WeekSession session, {
  Training training = _coreWork,
  AssessmentResults results = AssessmentResults.none,
}) async {
  final program = _program();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        activeProgramProvider.overrideWith((ref) async => program),
        activeProgramWeekProvider.overrideWith(
          (ref) async => ActiveProgramWeek(
            program: program,
            weekNumber: 1,
            week: Week(
              id: 'week-1',
              programId: _programId,
              weekNumber: 1,
              sessions: [session],
            ),
          ),
        ),
        programTrainingProvider(
          _programId,
          _trainingId,
        ).overrideWith((ref) async => training),
        assessmentResultsProvider.overrideWith((ref) async => results),
        sessionsProvider.overrideWith(_NoSessions.new),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: TodayTrainingCard())),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('estimates an untouched session from the training itself', (
    tester,
  ) async {
    await _pump(tester, _weekSession());

    expect(find.text('Core work'), findsOneWidget);
    expect(find.text('30s'), findsOneWidget);
  });

  testWidgets('estimates a retimed session from what the week prescribes', (
    tester,
  ) async {
    await _pump(
      tester,
      _weekSession(
        overrides: const [
          SessionOverride(
            id: 'override-1',
            itemId: 'plank-1',
            overrides: {'duration': 120},
          ),
        ],
      ),
    );

    expect(find.text('2m'), findsOneWidget);
    expect(find.text('30s'), findsNothing);
  });

  testWidgets('resolves a percentage of an assessment the athlete has done', (
    tester,
  ) async {
    // 80 percent of a 90s hang is 72s. Read without the results it would show
    // the coach's 30s fallback, which is not what the run plays.
    await _pump(
      tester,
      _weekSession(),
      training: _percentCoreWork,
      results: const AssessmentResults(
        {_hangAssessmentId: AssessmentHandValues(right: 90)},
        definitions: {_hangAssessmentId: _hangDefinition},
      ),
    );

    expect(find.text('1m 12s'), findsOneWidget);
    expect(find.text('30s'), findsNothing);
  });

  testWidgets('falls back to the coach number when nothing was measured', (
    tester,
  ) async {
    await _pump(tester, _weekSession(), training: _percentCoreWork);

    expect(find.text('30s'), findsOneWidget);
  });
}
