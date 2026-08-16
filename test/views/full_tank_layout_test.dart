import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/layouts/full_tank_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBleSession extends BleSession {
  _FakeBleSession(this.stats);

  final BleSessionStats stats;

  @override
  BleSessionStats build() => stats;
}

const _hang = TimedItem(
  label: 'Hang',
  durationSeconds: 7,
  targetLoad: 42,
  handSide: HandSide.both,
  gripPosition: GripPosition.threeFinger,
  collectSensorData: true,
  edgeSizeMm: 20,
  isHang: true,
  subtitle: 'SET 2/4 - REP 3/6',
);

const _pullUps = TimedItem(
  label: 'Pull-ups',
  durationSeconds: 24,
  targetLoad: 12,
  handSide: HandSide.both,
  gripPosition: GripPosition.halfCrimp,
  collectSensorData: false,
  subtitle: 'CIRCUIT 1/2',
);

Future<void> _pump(
  WidgetTester tester, {
  required TrainingExecutionItem item,
  TrainingExecutionItem? nextItem,
  double currentWeight = 0,
  double peak = 0,
  int secondsRemaining = 5,
  bool isPreparation = false,
  bool isRunning = true,
  String? repContext = 'SET 2/4 - REP 3/6',
  String? comment,
  TargetPlatform platform = TargetPlatform.android,
}) => tester.pumpWidget(
  ProviderScope(
    overrides: [
      bleLastValueProvider.overrideWithValue(currentWeight),
      bleSessionProvider.overrideWith(
        () => _FakeBleSession(BleSessionStats(max: peak)),
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(platform: platform),
      home: Scaffold(
        body: FullTankLayout(
          item: item,
          nextItem: nextItem,
          secondsRemaining: secondsRemaining,
          elapsedMilliseconds: 252000,
          remainingMilliseconds: 118000,
          showRemaining: true,
          isPreparation: isPreparation,
          isRunning: isRunning,
          repContext: repContext,
          comment: comment,
          nextComment: null,
          onPlayPause: () {},
          onSkip: () {},
          onConfirm: () {},
        ),
      ),
    ),
  ),
);

void main() {
  group('the force level', () {
    test('lands on the target notch exactly when the target is met', () {
      expect(
        tankFillFraction(currentWeight: 42, targetWeight: 42, peakWeight: 42),
        targetNotchFraction,
      );
    });

    test('rises in proportion to the pull', () {
      expect(
        tankFillFraction(currentWeight: 21, targetWeight: 42, peakWeight: 21),
        targetNotchFraction / 2,
      );
    });

    test('has room left above the notch for an overshoot', () {
      final overshoot = tankFillFraction(
        currentWeight: 50,
        targetWeight: 42,
        peakWeight: 50,
      );

      expect(overshoot, greaterThan(targetNotchFraction));
      expect(overshoot, lessThan(1));
    });

    test('never climbs past the top of the tank', () {
      expect(
        tankFillFraction(currentWeight: 400, targetWeight: 42, peakWeight: 400),
        1,
      );
    });

    // A max hang prescribes no load, so there is nothing to scale against but
    // what the athlete has already pulled this rep.
    test('falls back to the peak of the rep when no target is set', () {
      expect(
        tankFillFraction(currentWeight: 25, targetWeight: 0, peakWeight: 50),
        targetNotchFraction / 2,
      );
    });

    test('stays flat before the first sample of a rep with no target', () {
      expect(
        tankFillFraction(currentWeight: 0, targetWeight: 0, peakWeight: 0),
        0,
      );
    });
  });

  group('a sensor step', () {
    testWidgets('splits the force so the whole number reads first', (
      tester,
    ) async {
      await _pump(
        tester,
        item: _hang,
        currentWeight: 34.2,
        peak: 34.2,
        comment: 'Keep the shoulders engaged',
      );

      expect(find.text('34'), findsWidgets);
      expect(find.text('Keep the shoulders engaged'), findsWidgets);
      expect(find.text('.2 kg'), findsWidgets);
      expect(find.text('TARGET 42 kg'), findsWidgets);
    });

    testWidgets('counts down in bare seconds, and names the grip', (
      tester,
    ) async {
      await _pump(tester, item: _hang, currentWeight: 10, secondsRemaining: 5);

      expect(find.text('5'), findsWidgets);
      expect(find.text('SEC'), findsWidgets);
      expect(find.text('BOTH HANDS'), findsWidgets);
      expect(find.text('3FD - 20mm'), findsWidgets);
    });

    testWidgets('calls out reaching the target', (tester) async {
      await _pump(tester, item: _hang, currentWeight: 41.9, peak: 42);
      expect(find.text('ON TARGET'), findsNothing);
      expect(find.text('WORK'), findsOneWidget);

      await _pump(tester, item: _hang, currentWeight: 42, peak: 42);
      expect(find.text('ON TARGET'), findsOneWidget);
    });

    testWidgets('draws the readouts twice so they invert over the level', (
      tester,
    ) async {
      await _pump(tester, item: _hang, currentWeight: 34.2, peak: 34.2);
      expect(find.text('34'), findsNWidgets(2));

      // Nothing to invert before the first pull, so a single copy is drawn.
      await _pump(tester, item: _hang, currentWeight: 0);
      expect(find.text('0'), findsOneWidget);
    });

    // Android leaves the workout with its own back gesture.
    testWidgets('leaves the corner alone where the system has a way back', (
      tester,
    ) async {
      await _pump(tester, item: _hang, currentWeight: 34.2);

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    // iOS has nothing to leave with once the app bar is gone.
    testWidgets('offers a way out where the system has none', (tester) async {
      await _pump(
        tester,
        item: _hang,
        currentWeight: 34.2,
        platform: TargetPlatform.iOS,
      );

      expect(find.byIcon(Icons.arrow_back), findsWidgets);
    });

    testWidgets('keeps the set and rep on screen', (tester) async {
      await _pump(tester, item: _hang, currentWeight: 34.2);
      expect(find.text('SET 2/4 - REP 3/6'), findsOneWidget);
    });
  });

  group('the other steps', () {
    testWidgets('preparation names the first grip and its target', (
      tester,
    ) async {
      await _pump(
        tester,
        item: const RestItem(durationSeconds: 7),
        nextItem: _hang,
        isPreparation: true,
        secondsRemaining: 7,
        isRunning: false,
      );

      expect(find.text('PREPARATION'), findsOneWidget);
      expect(
        find.text('Get on the edge. Both hands, 3-finger drag, 20mm.'),
        findsOneWidget,
      );
      expect(find.text('FIRST TARGET 42 kg'), findsOneWidget);
      expect(find.text('READY'), findsOneWidget);
    });

    testWidgets('a rest previews the step it leads into', (tester) async {
      await _pump(
        tester,
        item: const RestItem(durationSeconds: 3),
        nextItem: _hang,
        secondsRemaining: 3,
      );

      expect(find.text('NEXT'), findsOneWidget);
      expect(find.text('BOTH HANDS'), findsOneWidget);
      expect(find.text('42 kg - 7s'), findsOneWidget);
      expect(find.text('SEC REST'), findsOneWidget);
      expect(find.text('REST'), findsOneWidget);
      // The block above already names what is next, so the strip stays quiet.
      expect(find.textContaining('Next:'), findsNothing);
    });

    testWidgets('a step without the sensor centers its countdown', (
      tester,
    ) async {
      await _pump(
        tester,
        item: _pullUps,
        nextItem: const RestItem(durationSeconds: 30),
        secondsRemaining: 24,
      );

      expect(find.text('PULL-UPS'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('SEC LEFT'), findsOneWidget);
      expect(find.text('TARGET 12 kg'), findsOneWidget);
      // The corner is free for the total time left, in minutes and seconds.
      expect(find.text('01:58'), findsOneWidget);
      expect(find.text('Next: rest 30s'), findsOneWidget);
    });

    testWidgets('pausing says so without hiding where the run stopped', (
      tester,
    ) async {
      await _pump(
        tester,
        item: _hang,
        currentWeight: 34.2,
        isRunning: false,
        comment: 'Keep the shoulders engaged',
      );

      expect(find.text('PAUSED'), findsNWidgets(2));
      expect(find.text('Tap play to resume'), findsOneWidget);
      // In the pill, and again under the state word where the next step sits
      // while the run is going.
      expect(find.text('SET 2/4 - REP 3/6'), findsNWidgets(2));
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('a self-paced step is finished from the strip', (tester) async {
      await _pump(
        tester,
        item: const ConfirmItem(label: 'Core', reps: 12, load: '10 kg'),
        repContext: 'ROUND 1/3',
      );

      expect(find.text('CORE'), findsOneWidget);
      expect(find.text('12 reps  -  10 kg'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsNothing);
    });
  });
}
