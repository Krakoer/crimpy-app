import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_sensor_link.dart';

void main() {
  group('TareCheck.of', () {
    TareCheck check(double load, {Duration age = Duration.zero}) =>
        TareCheck.of(loadKg: load, readingAge: age, connection: 1);

    test('a reading near zero needs no confirmation', () {
      expect(check(1.5).concern, TareConcern.none);
      expect(check(-1.5).concern, TareConcern.none);
    });

    test('a reading beyond 2 kg either way is a load', () {
      expect(check(2.5).concern, TareConcern.loaded);
      expect(check(-2.5).concern, TareConcern.loaded);
    });

    test('an old reading is stale whatever it reads', () {
      expect(
        check(0, age: const Duration(seconds: 3)).concern,
        TareConcern.stale,
      );
    });

    test('a confirmation holds for about the same load only', () {
      final confirmed = check(20);
      expect(confirmed.stillMatches(check(21)), isTrue);
      expect(confirmed.stillMatches(check(25)), isFalse);
      expect(
        confirmed.stillMatches(
          TareCheck.of(loadKg: 20, readingAge: Duration.zero, connection: 2),
        ),
        isFalse,
      );
    });
  });

  group('tare guard', () {
    late DateTime now;
    late FakeSensorLink link;
    late BleRepository repository;
    late ProviderContainer container;

    BleConfigController controller() =>
        container.read(bleConfigProvider.notifier);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      now = DateTime(2026, 9, 29, 12);
      link = FakeSensorLink();
      repository = BleRepository(link: link, clock: () => now);
      container = ProviderContainer.test(
        overrides: [bleRepositoryProvider.overrideWithValue(repository)],
      );
      await repository.connectToDevice(FakeSensorLink.device);
    });

    test('there is nothing to tare before the first reading', () {
      expect(controller().checkTare(), isNull);
    });

    test('an unloaded sensor tares straight away', () {
      link.channel!.send(0.3);
      expect(controller().checkTare()!.needsConfirmation, isFalse);
    });

    test('a loaded sensor reports the load that would be zeroed', () async {
      await repository.setTare(1);
      link.channel!.send(21);

      final check = controller().checkTare()!;

      expect(check.concern, TareConcern.loaded);
      expect(check.loadKg, 20);
    });

    test('a reading older than two seconds is stale', () {
      link.channel!.send(0.3);
      now = now.add(const Duration(seconds: 3));

      expect(controller().checkTare()!.concern, TareConcern.stale);
    });

    test('a confirmed tare zeroes the load still on the sensor', () async {
      link.channel!.send(20);
      final confirmed = controller().checkTare()!;
      link.channel!.send(20.4);

      expect(await controller().tareConfirmed(confirmed), isA<TareDone>());
      expect(repository.tare, closeTo(20.4, 1e-4));
    });

    test('a load that moved is put back to the athlete', () async {
      link.channel!.send(20);
      final confirmed = controller().checkTare()!;
      link.channel!.send(30);

      final outcome = await controller().tareConfirmed(confirmed);

      expect(outcome, isA<TareChanged>());
      expect((outcome as TareChanged).check.loadKg, closeTo(30, 1e-4));
      expect(repository.tare, 0);
    });

    test('a load taken off before confirming tares as usual', () async {
      link.channel!.send(20);
      final confirmed = controller().checkTare()!;
      link.channel!.send(0.2);

      expect(await controller().tareConfirmed(confirmed), isA<TareDone>());
      expect(repository.tare, closeTo(0.2, 1e-4));
    });

    test('a confirmation does not carry over to the next connection', () async {
      link.channel!.send(20);
      final confirmed = controller().checkTare()!;
      link.channel!.drop();

      expect(controller().checkTare(), isNull);

      await repository.connectToDevice(FakeSensorLink.device);
      link.channel!.send(20);

      expect(await controller().tareConfirmed(confirmed), isA<TareCancelled>());
      expect(repository.tare, 0);
    });

    test('a reconnection forgets the previous reading', () async {
      link.channel!.send(20);
      await repository.connectToDevice(FakeSensorLink.device);

      expect(repository.lastOriginalValue, isNaN);
      expect(controller().checkTare(), isNull);
    });
  });
}
