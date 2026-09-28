import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/utils/duration_format.dart';
import 'package:crimpy/utils/training_expander.dart';
import 'package:crimpy/utils/training_intensity.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:crimpy/views/screens/trainings/training_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/run_screen_plugins.dart';

/// Keeps the real BLE repository, and the platform channels it opens, out of
/// the screen tests: the screen only asks whether a sensor is connected.
class _DisconnectedSensor extends BleConnection {
  @override
  BleConnectionState build() => BleConnectionState.disconnected;
}

class _StubBodyweight extends BodyweightController {
  _StubBodyweight(this._stored);

  final double? _stored;

  @override
  Future<double?> build() async => _stored;
}

Training _percentBwTraining() => Training(
  id: 't',
  title: 'Hangboard',
  items: [
    TrainingItem(
      id: 'rep',
      type: TrainingItemType.hangboardRep,
      position: 0,
      loads: const [Load(value: 80, unit: 'percent_bw')],
    ),
  ],
);

/// A coach assessment: it lives on the coach's account, so the athlete cannot
/// fetch its definition and only ever sees it through the training.
const _weightedHang = AssessmentDefinition(
  id: 'a9b8c7d6-0000-0000-0000-000000000003',
  label: 'Weighted hang',
  unit: AssessmentUnit.kilograms,
  trainingId: 't-weighted-hang',
);

Training _percentAssessmentTraining() => Training(
  id: 't',
  title: 'Hangboard',
  referencedAssessments: const [_weightedHang],
  items: [
    TrainingItem(
      id: 'rep',
      type: TrainingItemType.hangboardRep,
      position: 0,
      loads: const [
        Load(
          value: 80,
          unit: percentAssessmentUnit,
          assessmentId: 'a9b8c7d6-0000-0000-0000-000000000003',
          fallback: 25,
        ),
      ],
    ),
  ],
);

/// Alternating 7/3 repeaters at 65% of max force, the builtin the list card
/// states a load and a length for.
Training _repeaterTraining() => Training(
  id: 't',
  title: 'Power Endurance',
  items: [
    TrainingItem(
      id: 'rep',
      type: TrainingItemType.repeater,
      position: 0,
      hand: HangboardHand.right,
      cycles: 3,
      reps: 10,
      worktimeSeconds: 7,
      restSeconds: 3,
      cycleRestSeconds: 180,
      edgeSizesMm: const [20],
      loads: const [
        Load(
          value: 65,
          unit: percentAssessmentUnit,
          assessmentId: BuiltinAssessmentIds.maxForce,
          fallback: 26,
        ),
      ],
    ),
  ],
);

Future<void> _pump(
  WidgetTester tester,
  double? stored, {
  Training? training,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bodyweightProvider.overrideWith(() => _StubBodyweight(stored)),
        connectionStateProvider.overrideWith(_DisconnectedSensor.new),
        // Nothing measured, which is the case the training has to name on its
        // own, and it keeps the real provider off the device database.
        assessmentResultsProvider.overrideWith(
          (ref) async => AssessmentResults.none,
        ),
        trainingIntensityRaterProvider.overrideWith(
          (ref) async => const TrainingIntensityRater(
            maxForce: MaxForceReference.none,
            results: AssessmentResults.none,
          ),
        ),
      ],
      child: MaterialApp(
        home: TrainingDetailScreen(training ?? _percentBwTraining()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the exercise list resolves percent of bodyweight loads', (
    tester,
  ) async {
    // This is the screen the athlete reads before loading the board, so it has
    // to agree with the scheduled training screen of a program.
    await _pump(tester, 70);
    expect(find.text('56 kg (80% BW)'), findsOneWidget);
  });

  testWidgets('the coach value stands alone when no bodyweight is known', (
    tester,
  ) async {
    await _pump(tester, null);
    expect(find.text('80% BW'), findsOneWidget);
    expect(find.textContaining('kg'), findsNothing);
  });

  // The definitions the training carries are the only thing that names an
  // assessment the athlete has never done: it is their coach's, so it is in no
  // catalog they can fetch. Without them the tile read "80% assessment".
  testWidgets('a load names the coach assessment the training references', (
    tester,
  ) async {
    await _pump(tester, 70, training: _percentAssessmentTraining());

    expect(find.textContaining('80% Weighted hang'), findsOneWidget);
    expect(find.textContaining('80% assessment'), findsNothing);
  });

  testWidgets('a repeater states its setup, its load and its length', (
    tester,
  ) async {
    await _pump(tester, 70, training: _repeaterTraining());

    expect(find.text('Right hand - Half Crimp - 20mm'), findsOneWidget);
    expect(find.text('26 kg (65% max)'), findsOneWidget);
    // In the one duration format the list card uses, once in the header and
    // once on the only row, which make up the whole.
    final length = formatLength(
      Duration(seconds: trainingDurationSeconds(_repeaterTraining())),
    );
    expect(length, endsWith('min'));
    expect(find.text(length), findsNWidgets(2));
  });

  testWidgets('Start is a labelled primary button pinned under the list', (
    tester,
  ) async {
    await _pump(tester, 70, training: _repeaterTraining());

    final start = find.widgetWithText(FilledButton, 'CONNECT AND START');
    expect(start, findsOneWidget);
    // Wider than half the screen: a full width bar, not a corner glyph.
    expect(tester.getSize(start).width, greaterThan(400));
  });

  testWidgets('without a sensor the athlete can still run it', (tester) async {
    stubRunScreenPlugins();
    await _pump(tester, 70, training: _percentBwTraining());

    // Nothing in it can be measured, so Start asks for no sensor.
    await tester.tap(find.text('START TRAINING'));
    await tester.pumpAndSettle();

    expect(find.byType(PlayTrainingScreen), findsOneWidget);
  });
}
