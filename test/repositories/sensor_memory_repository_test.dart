import 'dart:async';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/repositories/sensor_memory_repository.dart';
import 'package:crimpy/services/sensor_link/simulated_sensor_link.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('SharedPreferencesSensorMemory', () {
    const sensor = SensorDevice(id: 'AA:BB', name: 'Crimpy 42');

    test('remembers nothing at first', () async {
      expect(
        await SharedPreferencesSensorMemory().read(),
        isA<SensorOwnershipUnknown>(),
      );
    });

    test('remembers the sensor with its name', () async {
      await SharedPreferencesSensorMemory().remember(sensor);

      final ownership = await SharedPreferencesSensorMemory().read();

      expect(ownership, isA<RememberedSensor>());
      final device = (ownership as RememberedSensor).device;
      expect(device.id, 'AA:BB');
      expect(device.name, 'Crimpy 42');
    });

    test('an athlete with no sensor who connects one has one', () async {
      final memory = SharedPreferencesSensorMemory();
      await memory.rememberNoSensor();
      expect(await memory.read(), isA<NoSensorOwned>());

      await memory.remember(sensor);

      expect(await memory.read(), isA<RememberedSensor>());
    });

    test('saying they have no sensor forgets the one remembered', () async {
      final memory = SharedPreferencesSensorMemory();
      await memory.remember(sensor);

      await memory.rememberNoSensor();

      expect(await memory.read(), isA<NoSensorOwned>());
    });

    test('says when a change is stored', () async {
      final memory = SharedPreferencesSensorMemory();
      var changes = 0;
      memory.changes.listen((_) => changes++);

      await memory.remember(sensor);
      await memory.rememberNoSensor();
      await memory.forget();
      await pumpEventQueue();

      expect(changes, 3);
    });

    test('forgetting goes back to asking', () async {
      final memory = SharedPreferencesSensorMemory();
      await memory.remember(sensor);

      await memory.forget();

      expect(await memory.read(), isA<SensorOwnershipUnknown>());
    });
  });

  test('connecting a sensor remembers it, whoever connected it', () async {
    final memory = SharedPreferencesSensorMemory();
    final repository = BleRepository(
      link: SimulatedSensorLink(
        scanDuration: Duration.zero,
        connectDuration: Duration.zero,
      ),
      memory: memory,
    );

    expect(
      await repository.connectToDevice(SimulatedSensorLink.device),
      isTrue,
    );

    final ownership = await memory.read();
    expect((ownership as RememberedSensor).device.id, 'SIMULATED-SENSOR');
    await repository.disconnect();
  });

  test('the simulator never finds a sensor other than itself', () async {
    const remembered = SensorDevice(id: 'AA:BB', name: 'Crimpy 42');
    final link = SimulatedSensorLink();

    await expectLater(
      link.open(remembered, timeout: const Duration(milliseconds: 20)),
      throwsA(isA<TimeoutException>()),
    );
  });

  test(
    'a sensor that is not found leaves the repository disconnected',
    () async {
      const remembered = SensorDevice(id: 'AA:BB', name: 'Crimpy 42');
      final memory = SharedPreferencesSensorMemory();
      final repository = BleRepository(
        link: SimulatedSensorLink(),
        memory: memory,
      );

      final connected = await repository.connectToDevice(
        remembered,
        timeout: const Duration(milliseconds: 20),
      );

      expect(connected, isFalse);
      expect(repository.isConnected, isFalse);
      expect(await memory.read(), isA<SensorOwnershipUnknown>());
    },
  );
}
