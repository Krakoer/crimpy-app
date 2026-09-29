// ignore_for_file: scoped_providers_should_specify_dependencies
// A test container is the root container. The rule is about a scope nested
// under another one, where an override the parent cannot see is a bug.

import 'dart:async';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/repositories/sensor_memory_repository.dart';
import 'package:crimpy/services/sensor_link/sensor_link.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/settings_screen/widgets/sensor_ownership_tile.dart';
import 'package:crimpy/views/widgets/ble/connection_dialog.dart';
import 'package:crimpy/views/widgets/primary_action_bar.dart';
import 'package:crimpy/views/widgets/start_training_run.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _sensor = SensorDevice(id: 'AA:BB', name: 'Crimpy 42');

class _MemorySensorMemory extends SensorMemoryRepository {
  _MemorySensorMemory(this.ownership);

  SensorOwnership ownership;

  @override
  Future<SensorOwnership> read() async => ownership;

  @override
  Future<void> remember(SensorDevice device) async =>
      ownership = RememberedSensor(device);

  @override
  Future<void> rememberNoSensor() async => ownership = const NoSensorOwned();

  @override
  Future<void> forget() async => ownership = const SensorOwnershipUnknown();
}

/// Connects to [reachable] only; any other device is out of range. Records
/// the timeout each attempt was given.
class _Link extends SensorLink {
  _Link({this.reachable});

  final SensorDevice? reachable;
  final timeouts = <Duration>[];

  /// Holds the connection open until completed, when set.
  Completer<void>? answering;

  @override
  bool get isAdapterOn => true;

  @override
  Stream<bool> get adapterOnChanges => const Stream.empty();

  @override
  Future<void> turnAdapterOn() async {}

  @override
  Future<List<SensorDevice>> scan() async => [?reachable];

  @override
  Future<SensorChannel?> open(
    SensorDevice device, {
    Duration timeout = defaultSensorConnectTimeout,
  }) async {
    timeouts.add(timeout);
    await answering?.future;
    if (device.id != reachable?.id) {
      throw TimeoutException('not in range', timeout);
    }
    return _Channel();
  }
}

class _Channel extends SensorChannel {
  @override
  Stream<bool> get connectionChanges => Stream.value(true);

  @override
  Stream<List<int>> get notifications => const Stream.empty();

  @override
  Future<void> close() async {}
}

void main() {
  late _MemorySensorMemory memory;
  late _Link link;
  bool? answer;

  Future<void> pump(
    WidgetTester tester,
    SensorOwnership ownership, {
    SensorDevice? reachable,
  }) async {
    answer = null;
    memory = _MemorySensorMemory(ownership);
    link = _Link(reachable: reachable);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sensorMemoryProvider.overrideWithValue(memory),
          bleRepositoryProvider.overrideWithValue(
            BleRepository(link: link, memory: memory),
          ),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => ElevatedButton(
              onPressed: () async =>
                  answer = await resolveSensorForRun(context, ref),
              child: const Text('start'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> start(WidgetTester tester) async {
    await tester.tap(find.text('start'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  testWidgets('connects to the remembered sensor without asking', (
    tester,
  ) async {
    await pump(tester, const RememberedSensor(_sensor), reachable: _sensor);

    await start(tester);

    expect(answer, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
    expect(link.timeouts, [const Duration(seconds: 8)]);
  });

  testWidgets('shows that it is connecting to the remembered sensor', (
    tester,
  ) async {
    await pump(tester, const RememberedSensor(_sensor), reachable: _sensor);
    link.answering = Completer<void>();

    await tester.tap(find.text('start'));
    // The spinner never settles.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Connecting to Crimpy 42...'), findsOneWidget);
    expect(find.text('Run without'), findsOneWidget);

    link.answering!.complete();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(answer, isTrue);
  });

  testWidgets('asks as before when the remembered sensor is not found', (
    tester,
  ) async {
    await pump(tester, const RememberedSensor(_sensor));

    await start(tester);

    expect(find.textContaining('Could not reach Crimpy 42'), findsOneWidget);
    expect(find.text("I don't have one, don't ask again"), findsNothing);

    await tester.tap(find.text('Run without'));
    await tester.pumpAndSettle();

    expect(answer, isFalse);
    expect(memory.ownership, isA<RememberedSensor>());
  });

  testWidgets('offers the scan when the remembered sensor is not found', (
    tester,
  ) async {
    await pump(tester, const RememberedSensor(_sensor));
    await start(tester);

    await tester.tap(find.text('Connect'));
    await tester.pump();

    expect(find.byType(ConnectionDialog), findsOneWidget);
  });

  testWidgets('does not ask an athlete who said they have no sensor', (
    tester,
  ) async {
    await pump(tester, const NoSensorOwned(), reachable: _sensor);

    await start(tester);

    expect(answer, isFalse);
    expect(find.byType(AlertDialog), findsNothing);
    expect(link.timeouts, isEmpty);
  });

  testWidgets('asks when nothing is remembered', (tester) async {
    await pump(tester, const SensorOwnershipUnknown());

    await start(tester);

    expect(
      find.text('Do you have a Crimpy force sensor to measure this training?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Run without'));
    await tester.pumpAndSettle();

    expect(answer, isFalse);
    expect(memory.ownership, isA<SensorOwnershipUnknown>());
  });

  testWidgets('remembers an athlete who has no sensor when they say so', (
    tester,
  ) async {
    await pump(tester, const SensorOwnershipUnknown());
    await start(tester);

    await tester.tap(find.text("I don't have one, don't ask again"));
    await tester.pump();

    final connect = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Connect'),
    );
    expect(connect.onPressed, isNull);

    await tester.tap(find.text('Run without'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(answer, isFalse);
    expect(memory.ownership, isA<NoSensorOwned>());
  });

  group('the start button', () {
    const hang = Training(
      id: 't',
      title: 'Hangboard',
      items: [
        TrainingItem(
          id: 'h1',
          type: TrainingItemType.hangboardRep,
          position: 0,
          hand: 'right',
          worktimeSeconds: 7,
          restSeconds: 10,
          loads: [Load(value: 30, unit: 'kg')],
        ),
      ],
    );

    Future<void> pumpButton(
      WidgetTester tester,
      SensorOwnership ownership,
    ) async {
      memory = _MemorySensorMemory(ownership);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sensorMemoryProvider.overrideWithValue(memory),
            bleRepositoryProvider.overrideWithValue(
              BleRepository(link: _Link(), memory: memory),
            ),
          ],
          child: MaterialApp(
            home: StartTrainingButton(training: hang, onPressed: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('says it connects the remembered sensor', (tester) async {
      await pumpButton(tester, const RememberedSensor(_sensor));

      expect(find.text('CONNECT AND START'), findsOneWidget);
    });

    testWidgets('just starts for an athlete with no sensor', (tester) async {
      await pumpButton(tester, const NoSensorOwned());

      expect(find.text('START TRAINING'), findsOneWidget);
    });
  });

  group('the settings tile', () {
    Future<void> pumpTile(
      WidgetTester tester,
      SensorOwnership ownership,
    ) async {
      memory = _MemorySensorMemory(ownership);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sensorMemoryProvider.overrideWithValue(memory),
            bleRepositoryProvider.overrideWithValue(
              BleRepository(link: _Link(), memory: memory),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: SensorOwnershipTile())),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('forgets the remembered sensor', (tester) async {
      await pumpTile(tester, const RememberedSensor(_sensor));
      expect(find.text('Crimpy 42'), findsOneWidget);

      await tester.tap(find.text('Forget'));
      await tester.pumpAndSettle();

      expect(memory.ownership, isA<SensorOwnershipUnknown>());
      expect(find.text('Asked when a run starts'), findsOneWidget);
    });

    testWidgets('records and undoes having no sensor', (tester) async {
      await pumpTile(tester, const SensorOwnershipUnknown());

      await tester.tap(find.text("I don't have one"));
      await tester.pumpAndSettle();

      expect(memory.ownership, isA<NoSensorOwned>());
      expect(find.text('No force sensor'), findsOneWidget);

      await tester.tap(find.text('I have one'));
      await tester.pumpAndSettle();

      expect(memory.ownership, isA<SensorOwnershipUnknown>());
    });
  });
}
