// ignore_for_file: scoped_providers_should_specify_dependencies
// A test container is the root container. The rule is about a scope nested
// under another one, where an override the parent cannot see is a bug.

import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/widgets/ble/tare_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_sensor_link.dart';

void main() {
  late FakeSensorLink link;
  late BleRepository repository;
  late DateTime now;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    link = FakeSensorLink();
    now = DateTime(2026, 9, 29, 12);
    repository = BleRepository(link: link, clock: () => now);
  });

  Future<void> openTareDialog(WidgetTester tester) async {
    await tester.runAsync(
      () => repository.connectToDevice(FakeSensorLink.device),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bleRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const TareDialog(),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> tapTare(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Tare'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  testWidgets('asks for an unloaded sensor', (tester) async {
    await openTareDialog(tester);

    expect(find.textContaining('Take all load off the sensor'), findsOneWidget);
  });

  testWidgets('tares an unloaded sensor without asking', (tester) async {
    await openTareDialog(tester);
    link.channel!.send(0.4);

    await tapTare(tester);

    expect(find.text('The sensor is loaded'), findsNothing);
    expect(repository.tare, closeTo(0.4, 1e-4));
  });

  testWidgets('shows the load before taring a loaded sensor', (tester) async {
    await openTareDialog(tester);
    link.channel!.send(20);

    await tapTare(tester);

    expect(find.text('The sensor is loaded'), findsOneWidget);
    expect(find.textContaining('20.0 kg'), findsOneWidget);
    expect(repository.tare, 0);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('The sensor is loaded'), findsNothing);
    expect(repository.tare, 0);
  });

  testWidgets('tares the load once the athlete confirms', (tester) async {
    await openTareDialog(tester);
    link.channel!.send(20);
    await tapTare(tester);

    await tester.tap(find.text('Tare anyway'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.text('The sensor is loaded'), findsNothing);
    expect(repository.tare, closeTo(20, 1e-4));
  });

  testWidgets('asks again when the load moved before confirming', (
    tester,
  ) async {
    await openTareDialog(tester);
    link.channel!.send(20);
    await tapTare(tester);
    link.channel!.send(35);

    await tester.tap(find.text('Tare anyway'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.text('The reading changed since you were asked.'), findsOne);
    expect(find.textContaining('35.0 kg'), findsOneWidget);
    expect(repository.tare, 0);
  });

  testWidgets('closes the prompt when the sensor disconnects', (tester) async {
    await openTareDialog(tester);
    link.channel!.send(20);
    await tapTare(tester);

    link.channel!.drop();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.text('The sensor is loaded'), findsNothing);
    expect(find.text('Tare sensor'), findsOneWidget);
    expect(repository.tare, 0);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Tare sensor'), findsNothing);
  });

  testWidgets('asks before taring a reading that stopped coming', (
    tester,
  ) async {
    await openTareDialog(tester);
    link.channel!.send(0.3);
    now = now.add(const Duration(seconds: 3));

    await tapTare(tester);

    expect(find.text('No recent reading'), findsOneWidget);
    expect(find.textContaining('its last one, 0.3 kg'), findsOneWidget);
    expect(repository.tare, 0);
  });

  testWidgets('tells a sensor tared under load to tare again', (tester) async {
    await openTareDialog(tester);
    link.channel!.send(-20);

    await tapTare(tester);

    expect(find.text('The sensor reads below zero'), findsOneWidget);
    expect(find.textContaining('Take the load off'), findsNothing);

    await tester.tap(find.text('Tare now'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(repository.tare, closeTo(-20, 1e-4));
  });

  testWidgets('a prompt dismissed from its barrier leaves the tare dialog', (
    tester,
  ) async {
    await openTareDialog(tester);
    link.channel!.send(20);
    await tapTare(tester);

    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    link.channel!.drop();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.text('The sensor is loaded'), findsNothing);
    expect(find.text('Tare sensor'), findsOneWidget);
  });
}
