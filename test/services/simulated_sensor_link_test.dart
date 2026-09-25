import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/services/sensor_link/simulated_sensor_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimulatedHangProfile', () {
    const profile = SimulatedHangProfile();

    test('opens on a rest, so a tare right after connecting reads zero', () {
      expect(profile.forceAt(const Duration(seconds: 1)), profile.restLoad);
    });

    test('holds around the load during a hang', () {
      final force = profile.forceAt(const Duration(seconds: 6));
      expect(force, closeTo(profile.load, 1));
    });

    test('rests between hangs', () {
      expect(profile.forceAt(const Duration(seconds: 11)), profile.restLoad);
    });

    test('ramps up at the start of each hang instead of jumping', () {
      final early = profile.forceAt(const Duration(milliseconds: 3100));
      expect(early, greaterThan(profile.restLoad));
      expect(early, lessThan(profile.load / 2));
      final nextCycle = profile.forceAt(const Duration(milliseconds: 13100));
      expect(nextCycle, closeTo(early, 1));
    });
  });

  test('a repository over the simulated link streams samples', () async {
    final repository = BleRepository(
      link: SimulatedSensorLink(
        scanDuration: Duration.zero,
        samplePeriod: const Duration(milliseconds: 5),
      ),
    );
    final states = <BleConnectionState>[];
    final points = <BleDataPoint>[];
    repository.connectionStateStream.listen(states.add);
    repository.dataStream.listen(points.add);

    final found = await repository.scanForDevices();
    expect(found.single.id, SimulatedSensorLink.device.id);

    expect(await repository.connectToDevice(found.single), isTrue);
    await Future.delayed(const Duration(milliseconds: 100));

    expect(repository.isConnected, isTrue);
    expect(repository.connectedDevice?.name, 'Crimpy simulator');
    expect(states, [
      BleConnectionState.connecting,
      BleConnectionState.connected,
    ]);
    expect(points, isNotEmpty);

    await repository.disconnect();
    final sampleCount = points.length;
    await Future.delayed(const Duration(milliseconds: 50));

    expect(repository.isConnected, isFalse);
    expect(states.last, BleConnectionState.disconnected);
    expect(points, hasLength(sampleCount));
  });

  test('frames decode back to the reading the way the firmware sends it', () {
    final repository = BleRepository();
    final points = <BleDataPoint>[];
    repository.dataStream.listen(points.add);

    repository.handleRawSample(encodeSensorFrame(12.5, 1234));

    return pumpEventQueue().then((_) => expect(points.single.value, 12.5));
  });
}
