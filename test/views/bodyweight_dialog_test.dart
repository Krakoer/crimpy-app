// ignore_for_file: scoped_providers_should_specify_dependencies
// A test container is the root container. The rule is about a scope nested
// under another one, where an override the parent cannot see is a bug.

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/views/widgets/bodyweight_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keeps the real BLE repository, and the platform channels it opens, out of
/// the dialog tests: the dialog only asks whether a sensor is connected.
class _DisconnectedSensor extends BleConnection {
  @override
  BleConnectionState build() => BleConnectionState.disconnected;
}

/// The app under test, with [stored] as the bodyweight already on the device.
Widget _app(double? stored, Widget home) => ProviderScope(
  overrides: [
    bodyweightProvider.overrideWith(() => _StubBodyweight(stored)),
    connectionStateProvider.overrideWith(_DisconnectedSensor.new),
  ],
  child: MaterialApp(home: home),
);

/// A button that resolves the bodyweight for [training] and records the answer.
Widget _startButton(Training training, void Function(double?) onResolved) =>
    Consumer(
      builder: (context, ref, _) => ElevatedButton(
        onPressed: () async =>
            onResolved(await resolveBodyweight(context, ref, training)),
        child: const Text('start'),
      ),
    );

class _StubBodyweight extends BodyweightController {
  _StubBodyweight(this._stored);

  final double? _stored;

  @override
  Future<double?> build() async => _stored;

  @override
  Future<void> set(double kilograms) async => state = AsyncData(kilograms);
}

Training _training({required bool percentBw}) => Training(
  id: 't',
  title: 'Hangboard',
  items: [
    TrainingItem(
      id: 'rep',
      type: TrainingItemType.hangboardRep,
      position: 0,
      loads: [
        percentBw
            ? const Load(value: 80, unit: 'percent_bw')
            : const Load(value: 35, unit: 'kg'),
      ],
    ),
  ],
);

void main() {
  group('resolveBodyweight', () {
    /// Taps start for [training] on a device holding [stored], and returns what
    /// resolveBodyweight answered once the UI has settled.
    Future<double?> resolve(
      WidgetTester tester, {
      required Training training,
      required double? stored,
    }) async {
      double? resolved;
      await tester.pumpWidget(
        _app(stored, _startButton(training, (value) => resolved = value)),
      );
      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();
      return resolved;
    }

    testWidgets('a known bodyweight is used without asking again', (
      tester,
    ) async {
      final resolved = await resolve(
        tester,
        training: _training(percentBw: true),
        stored: 68.5,
      );

      expect(resolved, 68.5);
      expect(find.byType(BodyweightDialog), findsNothing);
    });

    testWidgets('a training with no percent of bodyweight load never asks', (
      tester,
    ) async {
      final resolved = await resolve(
        tester,
        training: _training(percentBw: false),
        stored: null,
      );

      expect(resolved, isNull);
      expect(find.byType(BodyweightDialog), findsNothing);
    });

    testWidgets('a percent of bodyweight training asks when none is known', (
      tester,
    ) async {
      await resolve(tester, training: _training(percentBw: true), stored: null);

      expect(find.byType(BodyweightDialog), findsOneWidget);
    });

    testWidgets('skipping the dialog runs the training without a weight', (
      tester,
    ) async {
      double? resolved;
      await tester.pumpWidget(
        _app(
          null,
          _startButton(_training(percentBw: true), (value) => resolved = value),
        ),
      );
      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(resolved, isNull);
    });

    testWidgets('a typed weight is saved and answered back', (tester) async {
      double? resolved;
      await tester.pumpWidget(
        _app(
          null,
          _startButton(_training(percentBw: true), (value) => resolved = value),
        ),
      );
      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '72.5');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(resolved, 72.5);
    });

    testWidgets('a slipped decimal point is refused rather than saved', (
      tester,
    ) async {
      // 700 instead of 70.0 put a 560 kg target on the gauge for an 80 %BW rep.
      await tester.pumpWidget(
        _app(null, const Scaffold(body: BodyweightDialog())),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '700');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.textContaining('between'), findsOneWidget);
    });
  });
}
