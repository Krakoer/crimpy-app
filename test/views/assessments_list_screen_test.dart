import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/views/screens/assessments/assessments_list_screen/assessments_list_screen.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/run_screen_plugins.dart';

/// A coach's assessment: the athlete cannot fetch its definition, so the
/// training that backs it is the only thing that names it here.
const _maxPullUps = AssessmentDefinition(
  id: 'a-pull-ups',
  label: 'Max pull ups',
  unit: AssessmentUnit.repetitions,
  prompt: 'How many pull ups did you manage?',
  trainingId: 't-pull-ups',
);

Training _coachAssessment() => const Training(
  id: 't-pull-ups',
  title: 'Pull up test',
  assessment: _maxPullUps,
  items: [
    TrainingItem(
      id: 'i1',
      type: TrainingItemType.exercise,
      position: 0,
      reps: 1,
      exerciseName: 'Pull up',
    ),
  ],
);

class _FixedConnection extends BleConnection {
  _FixedConnection(this._state);

  final BleConnectionState _state;

  @override
  BleConnectionState build() => _state;
}

class _StubBodyweight extends BodyweightController {
  @override
  Future<double?> build() async => 70;
}

const _hangTime = AssessmentDefinition(
  id: 'a-hang',
  label: 'Half crimp hang',
  unit: AssessmentUnit.seconds,
  perHand: true,
  trainingId: 't-hang',
);

Training _perHandAssessment() =>
    const Training(id: 't-hang', title: 'Hang test', assessment: _hangTime);

/// The athlete's recorded results, served without the device database. A
/// result that is not measured per hand carries its single number on the
/// right, the way the post workout screen writes it.
class _FixedAssessments extends Assessments {
  @override
  Future<List<AssessmentModel>> build(String? assessmentId) async => [
    AssessmentModel(
      id: 'r1',
      date: DateTime.now(),
      definition: _maxPullUps,
      rightValue: 12,
    ),
    AssessmentModel(
      id: 'r2',
      date: DateTime.now(),
      definition: _hangTime,
      rightValue: 22,
      leftValue: 19,
    ),
  ];
}

class _NoAssessments extends Assessments {
  @override
  Future<List<AssessmentModel>> build(String? assessmentId) async => const [];
}

Future<void> _pump(
  WidgetTester tester, {
  List<Training> recordable = const [],
  bool withResults = false,
  BleConnectionState connection = BleConnectionState.disconnected,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        recordableAssessmentTrainingsProvider.overrideWith(
          (ref) async => recordable,
        ),
        assessmentsProvider.overrideWith(
          withResults ? _FixedAssessments.new : _NoAssessments.new,
        ),
        assessmentResultsProvider.overrideWith(
          (ref) async => AssessmentResults.none,
        ),
        bodyweightProvider.overrideWith(_StubBodyweight.new),
        connectionStateProvider.overrideWith(
          () => _FixedConnection(connection),
        ),
        // Always served, never built: the real provider reaches for the stored
        // calibration on creation, which no test binding can answer.
        bleRepositoryProvider.overrideWithValue(BleRepository()),
      ],
      child: const MaterialApp(home: Scaffold(body: AssessmentsScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the three protocols Crimpy ships are always listed', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Max Force'), findsOneWidget);
    expect(find.text('Critical Force'), findsOneWidget);
    expect(find.text('60% Endurance'), findsOneWidget);
  });

  testWidgets('a coach assessment is listed beside them', (tester) async {
    // It used to be reachable only from the week the coach scheduled it in, so
    // an athlete could not re-run a test they wanted to check.
    await _pump(tester, recordable: [_coachAssessment()]);

    expect(find.text('Max pull ups'), findsOneWidget);
    expect(find.text('How many pull ups did you manage?'), findsOneWidget);
  });

  testWidgets('a coach assessment reads back its last result', (tester) async {
    // Not measured per hand, so the number reads on its own: an "R:" in front
    // of it would claim a right hand for a test that has no sides.
    await _pump(tester, recordable: [_coachAssessment()], withResults: true);

    expect(find.textContaining('12 reps'), findsOneWidget);
    expect(find.textContaining('R: 12 reps'), findsNothing);
  });

  testWidgets('an assessment measured per hand reads back both', (
    tester,
  ) async {
    await _pump(tester, recordable: [_perHandAssessment()], withResults: true);

    expect(find.textContaining('R: 22s  L: 19s'), findsOneWidget);
  });

  testWidgets('tapping a coach assessment runs the training behind it', (
    tester,
  ) async {
    stubRunScreenPlugins();
    // No sensor connected: a coach's assessment is not measured by one, so it
    // must start anyway, unlike the three protocols.
    await _pump(tester, recordable: [_coachAssessment()]);

    await tester.tap(find.text('Max pull ups'));
    await tester.pumpAndSettle();

    final run = tester.widget<PlayTrainingScreen>(
      find.byType(PlayTrainingScreen),
    );
    expect(run.training.id, 't-pull-ups');
    expect(run.trainingId, 't-pull-ups');
    expect(run.training.assessment!.label, 'Max pull ups');
  });

  testWidgets('the protocols stay disabled without a sensor', (tester) async {
    await _pump(tester, recordable: [_coachAssessment()]);

    await tester.tap(find.text('Max Force'));
    await tester.pumpAndSettle();

    expect(find.byType(PlayTrainingScreen), findsNothing);
    expect(find.text('Max Force'), findsOneWidget);
  });
}
