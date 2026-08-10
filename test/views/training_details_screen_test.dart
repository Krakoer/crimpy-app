import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
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

Future<void> _pump(WidgetTester tester, double? stored) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bodyweightProvider.overrideWith(() => _StubBodyweight(stored)),
        connectionStateProvider.overrideWith(_DisconnectedSensor.new),
      ],
      child: MaterialApp(home: TrainingDetailScreen(_percentBwTraining())),
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
}
