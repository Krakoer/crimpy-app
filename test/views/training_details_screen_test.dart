import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/views/screens/trainings/training_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(find.textContaining('80 %BW (56 kg)'), findsOneWidget);
  });

  testWidgets('the coach value stands alone when no bodyweight is known', (
    tester,
  ) async {
    await _pump(tester, null);
    expect(find.textContaining('80 %BW'), findsOneWidget);
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
}
