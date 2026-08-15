import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/full_screen_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBleSession extends BleSession {
  _FakeBleSession(this.stats);

  final BleSessionStats stats;

  @override
  BleSessionStats build() => stats;
}

Future<void> _pumpGauge(
  WidgetTester tester, {
  required double targetWeight,
  double currentWeight = 0,
  double peak = 0,
  double average = 0,
}) => tester.pumpWidget(
  ProviderScope(
    overrides: [
      bleLastValueProvider.overrideWithValue(currentWeight),
      bleSessionProvider.overrideWith(
        () => _FakeBleSession(BleSessionStats(max: peak, avg: average)),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: FullScreenGauge(
          targetWeight: targetWeight,
          secondsRemaining: 7,
          repProgress: 0.5,
          handSide: HandSide.left,
          gripPosition: GripPosition.halfCrimp,
          edgeSizeMm: 20,
        ),
      ),
    ),
  ),
);

void main() {
  group('the level', () {
    test('lands on the target line exactly when the target is met', () {
      expect(
        gaugeLevelFraction(currentWeight: 40, targetWeight: 40, peakWeight: 40),
        targetHeightFraction,
      );
    });

    test('rises in proportion to the pull', () {
      expect(
        gaugeLevelFraction(currentWeight: 20, targetWeight: 40, peakWeight: 20),
        targetHeightFraction / 2,
      );
    });

    test('has room left above the target for an overshoot', () {
      final overshoot = gaugeLevelFraction(
        currentWeight: 48,
        targetWeight: 40,
        peakWeight: 48,
      );

      expect(overshoot, greaterThan(targetHeightFraction));
      expect(overshoot, lessThan(1));
    });

    test('never climbs past the top of the screen', () {
      expect(
        gaugeLevelFraction(
          currentWeight: 400,
          targetWeight: 40,
          peakWeight: 400,
        ),
        1,
      );
    });

    // A max hang prescribes no load, so there is nothing to scale against but
    // what the athlete has already pulled this rep.
    test('falls back to the peak of the rep when no target is set', () {
      expect(
        gaugeLevelFraction(currentWeight: 25, targetWeight: 0, peakWeight: 50),
        targetHeightFraction / 2,
      );
    });

    test('stays flat before the first sample of a rep with no target', () {
      expect(
        gaugeLevelFraction(currentWeight: 0, targetWeight: 0, peakWeight: 0),
        0,
      );
    });
  });

  group('the readouts', () {
    testWidgets('show the force, the target, the timer and the rep so far', (
      tester,
    ) async {
      await _pumpGauge(
        tester,
        targetWeight: 40,
        currentWeight: 32.5,
        peak: 41,
        average: 30.5,
      );

      expect(find.text('32.5'), findsWidgets);
      expect(find.text('TARGET 40 kg'), findsWidgets);
      expect(find.text('00:07'), findsWidgets);
      expect(find.text('41 kg'), findsWidgets);
      expect(find.text('30.5 kg'), findsWidgets);
      expect(find.text('LEFT HAND'), findsWidgets);
    });

    testWidgets('call out reaching the target', (tester) async {
      await _pumpGauge(tester, targetWeight: 40, currentWeight: 39.9, peak: 40);
      expect(find.text('ON TARGET'), findsNothing);

      await _pumpGauge(tester, targetWeight: 40, currentWeight: 40, peak: 40);
      expect(find.text('ON TARGET'), findsWidgets);
    });

    // A step with no prescribed load has no line to draw, and labelling it
    // "TARGET 0 kg" would read as a target of nothing.
    testWidgets('leave out the target line when no load is prescribed', (
      tester,
    ) async {
      await _pumpGauge(tester, targetWeight: 0, currentWeight: 25, peak: 30);

      expect(find.textContaining('TARGET'), findsNothing);
      expect(find.text('25'), findsWidgets);
    });
  });
}
