import 'dart:async';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/load_drop_alarm_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScriptedSensor extends BleRepository {
  final samples = StreamController<BleDataPoint>.broadcast();

  @override
  Stream<BleDataPoint> get dataStream => samples.stream;
}

class _Connection extends BleConnection {
  @override
  BleConnectionState build() => BleConnectionState.connected;

  void set(BleConnectionState connection) => state = connection;
}

const _hang = TimedItem(
  label: 'Right hang',
  durationSeconds: 7,
  targetLoad: 30,
  handSide: HandSide.right,
  gripPosition: GripPosition.halfCrimp,
  collectSensorData: true,
  isHang: true,
);

void main() {
  // See Krakoer/crimpy#175. Target 30 kg: fires under 27 kg.
  test('a sensor that reconnects mid-rep starts the watch over', () async {
    final sensor = _ScriptedSensor();
    final container = ProviderContainer(
      overrides: [
        bleRepositoryProvider.overrideWithValue(sensor),
        connectionStateProvider.overrideWith(_Connection.new),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(loadDropAlarmProvider, (_, _) {});
    addTearDown(subscription.close);

    final start = DateTime(2026, 9, 28, 10);
    Future<void> read(double kilograms, int milliseconds) async {
      sensor.samples.add(
        BleDataPoint(
          kilograms,
          start.add(Duration(milliseconds: milliseconds)),
        ),
      );
      await Future<void>.delayed(Duration.zero);
    }

    container.read(loadDropAlarmProvider.notifier).follow(_hang);
    await read(30, 0);
    await read(20, 100);
    await read(20, 400);

    final connection =
        container.read(connectionStateProvider.notifier) as _Connection;
    connection.set(BleConnectionState.disconnected);
    connection.set(BleConnectionState.connected);

    // Past the dwell counted before the drop, and still nothing: the rep has
    // to get on target again first.
    await read(20, 700);
    await read(20, 1500);
    expect(container.read(loadDropAlarmProvider), isFalse);

    await read(30, 2000);
    await read(20, 2100);
    await read(20, 2600);
    expect(container.read(loadDropAlarmProvider), isTrue);
  });
}
