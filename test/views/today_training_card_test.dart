import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/training_intensity.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/widgets/today_training_card.dart';
import 'package:crimpy/utils/datetimes.dart';
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
  // The program starts on the training day the card reads as today, which is
  // still yesterday until 04:00 (#152).
  final today = currentTrainingDay();
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
  TrainingIntensityRater rater = const TrainingIntensityRater(
    maxForce: MaxForceReference.none,
    results: AssessmentResults.none,
  ),
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
        trainingIntensityRaterProvider.overrideWith((ref) async => rater),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: TodayTrainingCard())),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a training row is never shorter than a tap target', (
    tester,
  ) async {
    await _pump(tester, _weekSession());

    final row = find.ancestor(
      of: find.text('Core work'),
      matching: find.byType(InkWell),
    );
    expect(
      tester.getSize(row.first).height,
      greaterThanOrEqualTo(kMinInteractiveDimension),
    );
  });

  testWidgets('a this-week row is never shorter than a tap target', (
    tester,
  ) async {
    await _pump(
      tester,
      const WeekSession(
        id: 'week-session-1',
        trainingId: _trainingId,
        trainingTitle: 'Core work',
        trainingType: 'workout',
        timesPerWeek: 2,
        position: 0,
      ),
    );

    final row = find.ancestor(
      of: find.text('Core work'),
      matching: find.byType(InkWell),
    );
    expect(
      tester.getSize(row.first).height,
      greaterThanOrEqualTo(kMinInteractiveDimension),
    );
  });

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

    expect(find.text('2 min'), findsOneWidget);
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

    expect(find.text('1 min'), findsOneWidget);
    expect(find.text('30s'), findsNothing);
  });

  testWidgets('falls back to the coach number when nothing was measured', (
    tester,
  ) async {
    await _pump(tester, _weekSession(), training: _percentCoreWork);

    expect(find.text('30s'), findsOneWidget);
  });

  group('intensity', () {
    final rater = TrainingIntensityRater.fromHistory([
      AssessmentModel(
        id: 'mvc',
        date: DateTime(2026, 1, 1),
        definition: BuiltinAssessmentIds.definitionOf(AssessmentType.mvc),
        rightValue: 40,
        leftValue: 40,
        gripPosition: GripPosition.halfCrimp,
      ),
    ]);

    WeekSession hangSession({List<SessionOverride> overrides = const []}) =>
        WeekSession(
          id: 'week-session-1',
          trainingId: _trainingId,
          trainingTitle: 'Board strength',
          trainingType: 'hangboard',
          isEveryday: true,
          position: 0,
          overrides: overrides,
        );

    testWidgets('rates the training against the athlete max', (tester) async {
      await _pump(tester, hangSession(), training: _hang, rater: rater);

      expect(find.text('75% max'), findsOneWidget);
    });

    testWidgets('rates the training as the week prescribes it', (tester) async {
      await _pump(
        tester,
        hangSession(
          overrides: const [
            SessionOverride(
              id: 'override-1',
              itemId: 'hang-1',
              overrides: {
                'loads': [
                  {'value': 36, 'unit': 'kg'},
                ],
              },
            ),
          ],
        ),
        training: _hang,
        rater: rater,
      );

      expect(find.text('90% max'), findsOneWidget);
      expect(find.text('75% max'), findsNothing);
    });

    testWidgets('the row holds on a 320dp phone', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 800);
      addTearDown(tester.view.reset);

      await _pump(
        tester,
        hangSession(
          overrides: const [
            SessionOverride(
              id: 'override-1',
              itemId: 'hang-1',
              overrides: {
                'loads': [
                  {'value': 40, 'unit': 'kg'},
                ],
              },
            ),
          ],
        ),
        training: _hang,
        rater: rater,
      );

      expect(find.text('100% max'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// A 30 kg right hand hang on a half crimp, ten reps of 7s.
const _hang = Training(
  id: _trainingId,
  title: 'Board strength',
  items: [
    TrainingItem(
      id: 'hang-1',
      type: TrainingItemType.repeater,
      position: 0,
      cycles: 3,
      reps: 10,
      worktimeSeconds: 7,
      restSeconds: 3,
      hand: HangboardHand.right,
      loads: [Load(value: 30, unit: 'kg')],
      handPositions: [
        ['HC'],
      ],
    ),
  ],
);
