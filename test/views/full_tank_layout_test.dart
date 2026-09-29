import 'dart:math';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/layouts/full_tank_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/roboto.dart';

class _FakeBodyweight extends BodyweightController {
  _FakeBodyweight(this.kilograms);

  final double? kilograms;

  @override
  Future<double?> build() async => kilograms;
}

class _FakeConnection extends BleConnection {
  _FakeConnection(this.connection);

  final BleConnectionState connection;

  @override
  BleConnectionState build() => connection;
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

const _prescription =
    'kilter volume, 40 degrees, ramp up from 6a, 2 to 3 min between blocks, '
    'aim for 20 problems in 2h';

/// Longer than the running screen has lines for, so it is the case the paused
/// card exists to answer.
final _longNote = List.filled(12, _prescription).join(' ');

const _maxHang = TimedItem(
  label: 'Max hang',
  durationSeconds: 10,
  targetLoad: 0,
  handSide: HandSide.both,
  gripPosition: GripPosition.halfCrimp,
  collectSensorData: true,
  edgeSizeMm: 20,
  isHang: true,
  subtitle: 'SET 1/3',
);

Future<void> _pump(
  WidgetTester tester, {
  required TrainingExecutionItem item,
  TrainingExecutionItem? nextItem,
  double currentWeight = 0,
  double? bodyweight,
  int secondsRemaining = 5,
  bool isPreparation = false,
  bool isRunning = true,
  bool loadBelowTarget = false,
  String? repContext = 'SET 2/4 - REP 3/6',
  String? goal,
  String? nextGoal,
  String? comment,
  String? nextComment,
  String? protocol,
  String? nextProtocol,
  String? videoLink,
  String? nextVideoLink,
  TargetPlatform platform = TargetPlatform.android,
  bool showDropOut = false,
  BleConnectionState connection = BleConnectionState.connected,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bleLastValueProvider.overrideWithValue(currentWeight),
        connectionStateProvider.overrideWith(() => _FakeConnection(connection)),
        bodyweightProvider.overrideWith(() => _FakeBodyweight(bodyweight)),
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
            loadBelowTarget: loadBelowTarget,
            repContext: repContext,
            goal: goal,
            nextGoal: nextGoal,
            comment: comment,
            nextComment: nextComment,
            protocol: protocol,
            nextProtocol: nextProtocol,
            videoLink: videoLink,
            nextVideoLink: nextVideoLink,
            onPlayPause: () {},
            onSkip: () {},
            onConfirm: () {},
            showDropOut: showDropOut,
            onDropOut: () {},
          ),
        ),
      ),
    ),
  );
  // The bodyweight is loaded asynchronously, so the tank only knows what it
  // scales a max hang against on the frame after the first.
  await tester.pump();
}

/// The colour of the force level, which is the one ColoredBox sized to it.
Color? _levelColor(WidgetTester tester) {
  final level = tester
      .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
      .toList();
  if (level.isEmpty) return null;
  return (level.single.decoration as BoxDecoration?)?.color;
}

Color? _textColor(WidgetTester tester, String text) =>
    tester.widgetList<Text>(find.text(text)).first.style?.color;

void main() {
  // One map from what the run is doing to its hue, which every part of the
  // screen reads. See Krakoer/crimpy#158.
  group('the phase colours', () {
    testWidgets('fill the level in sage once the target is held', (
      tester,
    ) async {
      await _pump(tester, item: _hang, currentWeight: 42);
      expect(
        _levelColor(tester),
        CrimpyTheme.fillOn(CrimpyTheme.phaseColor(RunPhase.engaged)),
      );
    });

    testWidgets('fill the level in ink below the target', (tester) async {
      await _pump(tester, item: _hang, currentWeight: 30);
      expect(
        _levelColor(tester),
        CrimpyTheme.fillOn(CrimpyTheme.phaseColor(RunPhase.armed)),
      );
    });

    testWidgets('paint a rest calm, not green', (tester) async {
      await _pump(
        tester,
        item: const RestItem(durationSeconds: 3),
        nextItem: _hang,
        secondsRemaining: 3,
      );

      final calm = CrimpyTheme.textOn(CrimpyTheme.phaseColor(RunPhase.calm));
      expect(_textColor(tester, 'REST'), calm);
      expect(_textColor(tester, '3'), calm);
      expect(_textColor(tester, 'SEC REST'), calm);
      final ground = tester
          .widgetList<ColoredBox>(find.byType(ColoredBox))
          .map((box) => box.color);
      expect(ground, contains(CrimpyTheme.phaseCalmGround));
      expect(ground, isNot(contains(CrimpyTheme.onTarget)));
    });

    // textMutedSmall is under the text floor on the calm ground.
    testWidgets('set the muted labels of a rest in textSecondary', (
      tester,
    ) async {
      await _pump(
        tester,
        item: const RestItem(durationSeconds: 3),
        nextItem: _hang,
      );
      expect(_textColor(tester, 'ELAPSED'), CrimpyTheme.textSecondary);
      expect(_textColor(tester, 'LEFT'), CrimpyTheme.textSecondary);
    });

    testWidgets('paint getting ready armed', (tester) async {
      await _pump(tester, item: _hang, nextItem: _hang, isPreparation: true);

      final armed = CrimpyTheme.textOn(CrimpyTheme.phaseColor(RunPhase.armed));
      expect(_textColor(tester, 'READY'), armed);
      expect(_textColor(tester, 'PREPARATION'), armed);
    });

    testWidgets('raise the alarm when a sensor step has no sensor', (
      tester,
    ) async {
      await _pump(
        tester,
        item: _hang,
        nextItem: const RestItem(durationSeconds: 3),
        currentWeight: 34.2,
        connection: BleConnectionState.disconnected,
      );

      expect(
        _textColor(tester, 'NO SENSOR'),
        CrimpyTheme.textOn(CrimpyTheme.phaseColor(RunPhase.alarm)),
      );
      // The last sample is stale, so the level empties rather than holding it.
      expect(find.text('34.2'), findsNothing);
      expect(find.text('NEXT'), findsNothing);
    });

    testWidgets('raise no alarm on a step that reads no sensor', (
      tester,
    ) async {
      await _pump(
        tester,
        item: _pullUps,
        connection: BleConnectionState.disconnected,
      );
      expect(find.text('NO SENSOR'), findsNothing);
    });

    // See Krakoer/crimpy#175.
    testWidgets('raise the alarm when the load dropped below the target', (
      tester,
    ) async {
      await _pump(
        tester,
        item: _hang,
        nextItem: const RestItem(durationSeconds: 3),
        currentWeight: 30.5,
        loadBelowTarget: true,
      );

      final alarm = CrimpyTheme.phaseColor(RunPhase.alarm);
      expect(_levelColor(tester), CrimpyTheme.fillOn(alarm));
      expect(_textColor(tester, 'BELOW TARGET'), CrimpyTheme.textOn(alarm));
      // The force stays on screen: the athlete has to see how far under it is.
      expect(find.text('30.5'), findsWidgets);
      expect(find.text('NEXT'), findsNothing);
    });

    testWidgets('raise no load alarm on a paused run', (tester) async {
      await _pump(
        tester,
        item: _hang,
        currentWeight: 30,
        isRunning: false,
        loadBelowTarget: true,
      );
      expect(find.text('BELOW TARGET'), findsNothing);
      expect(find.text('PAUSED'), findsWidgets);
    });

    testWidgets('raise no load alarm on a hang with no target load', (
      tester,
    ) async {
      await _pump(
        tester,
        item: _maxHang,
        currentWeight: 30,
        bodyweight: 70,
        loadBelowTarget: true,
      );
      expect(find.text('BELOW TARGET'), findsNothing);
      expect(
        _levelColor(tester),
        CrimpyTheme.fillOn(CrimpyTheme.phaseColor(RunPhase.armed)),
      );
    });

    testWidgets('say NO SENSOR over a load alarm when the sensor is gone', (
      tester,
    ) async {
      await _pump(
        tester,
        item: _hang,
        currentWeight: 30,
        loadBelowTarget: true,
        connection: BleConnectionState.disconnected,
      );
      expect(find.text('NO SENSOR'), findsOneWidget);
      expect(find.text('BELOW TARGET'), findsNothing);
    });

    testWidgets('leave the drop out flag out of the alarm red', (tester) async {
      await _pump(tester, item: _hang, currentWeight: 10, showDropOut: true);

      final flag = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.flag_outlined),
      );
      expect(flag.color, CrimpyTheme.control);
    });
  });

  group('what the tank is scaled against', () {
    test('is the prescribed load when there is one', () {
      expect(tankScaleWeight(targetWeight: 42, bodyweight: 72), 42);
    });

    // A max hang prescribes no load, so the bodyweight stands in: it is known
    // before the first sample and holds still for the whole pull.
    test('is the bodyweight on a step prescribing no load', () {
      expect(tankScaleWeight(targetWeight: 0, bodyweight: 72), 72);
    });

    test(
      'is nothing when no load is prescribed and no bodyweight is known',
      () {
        expect(tankScaleWeight(targetWeight: 0, bodyweight: null), 0);
      },
    );
  });

  group('the force level', () {
    test('lands on the target notch exactly when the target is met', () {
      expect(
        tankFillFraction(currentWeight: 42, scaleWeight: 42),
        targetNotchFraction,
      );
    });

    test('rises in proportion to the pull', () {
      expect(
        tankFillFraction(currentWeight: 21, scaleWeight: 42),
        targetNotchFraction / 2,
      );
    });

    test('has room left above the notch for an overshoot', () {
      final overshoot = tankFillFraction(currentWeight: 50, scaleWeight: 42);

      expect(overshoot, greaterThan(targetNotchFraction));
      expect(overshoot, lessThan(1));
    });

    test('never climbs past the top of the tank', () {
      expect(tankFillFraction(currentWeight: 400, scaleWeight: 42), 1);
    });

    test('stays empty when there is nothing to scale against', () {
      expect(tankFillFraction(currentWeight: 25, scaleWeight: 0), 0);
    });

    // Scaling a max hang against the peak of the rep pinned the level at the
    // notch from the first sample, the peak being the current value all the way
    // up the pull. Against the bodyweight it climbs.
    test('climbs through a max hang instead of pinning to the notch', () {
      final early = tankFillFraction(currentWeight: 10, scaleWeight: 72);
      final late = tankFillFraction(currentWeight: 30, scaleWeight: 72);

      expect(early, lessThan(late));
      expect(early, lessThan(targetNotchFraction));
      expect(late, lessThan(targetNotchFraction));
    });
  });

  group('a sensor step', () {
    testWidgets('sets the whole force on one line beside its unit', (
      tester,
    ) async {
      await _pump(
        tester,
        item: _hang,
        currentWeight: 34.2,
        comment: 'Keep the shoulders engaged',
      );

      expect(find.text('34.2'), findsWidgets);
      expect(find.text('Keep the shoulders engaged'), findsWidgets);
      expect(find.text('kg'), findsWidgets);
      expect(find.text('.2 kg'), findsNothing);
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

    // The level and the notch already say it, so no word repeats it.
    testWidgets('leaves reaching the target to the level', (tester) async {
      await _pump(tester, item: _hang, currentWeight: 41.9);
      expect(find.text('WORK'), findsNothing);

      await _pump(tester, item: _hang, currentWeight: 42);
      expect(find.text('ON TARGET'), findsNothing);
    });

    testWidgets('keeps the total time left beside the countdown', (
      tester,
    ) async {
      await _pump(tester, item: _hang, currentWeight: 10, secondsRemaining: 5);

      expect(find.text('LEFT'), findsWidgets);
      expect(find.text('1:58'), findsWidgets);
      expect(find.text('ELAPSED'), findsWidgets);
    });

    testWidgets('names the step coming up in the strip', (tester) async {
      await _pump(
        tester,
        item: _hang,
        nextItem: const RestItem(durationSeconds: 3),
        currentWeight: 10,
      );

      expect(find.text('NEXT'), findsOneWidget);
      expect(find.text('REST 0:03'), findsOneWidget);
    });

    testWidgets('draws the readouts twice so they invert over the level', (
      tester,
    ) async {
      await _pump(tester, item: _hang, currentWeight: 34.2);
      expect(find.text('34.2'), findsNWidgets(2));

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

    testWidgets('scales a step prescribing no load against the bodyweight', (
      tester,
    ) async {
      await _pump(tester, item: _maxHang, currentWeight: 34.2, bodyweight: 72);

      expect(find.text('BW 72 kg'), findsWidgets);
      expect(find.textContaining('TARGET'), findsNothing);
      // The level is up, so both copies of the readout are drawn.
      expect(find.text('34.2'), findsNWidgets(2));
    });

    testWidgets('leaves the tank empty when it has nothing to scale against', (
      tester,
    ) async {
      await _pump(tester, item: _maxHang, currentWeight: 34.2);

      expect(find.textContaining('BW'), findsNothing);
      expect(find.textContaining('TARGET'), findsNothing);
      expect(find.text('34.2'), findsOneWidget);
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
      expect(find.text('42 kg - 0:07'), findsOneWidget);
      expect(find.text('SEC REST'), findsOneWidget);
      expect(find.text('REST'), findsOneWidget);
      // The block above already names what is next, so the strip stays quiet
      // and the one NEXT above is the block's.
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
      expect(find.text('1:58'), findsOneWidget);
      expect(find.text('REST 0:30'), findsOneWidget);
    });

    // Only a hang on a single hand goes through the sensor, so a hang on both
    // runs as a timed step and has to name the grip itself.
    testWidgets('a hang without the sensor names the grip', (tester) async {
      await _pump(
        tester,
        item: const TimedItem(
          label: 'Hang',
          durationSeconds: 10,
          targetLoad: 0,
          handSide: HandSide.both,
          gripPosition: GripPosition.halfCrimp,
          collectSensorData: false,
          edgeSizeMm: 20,
          isHang: true,
        ),
        secondsRemaining: 10,
      );

      expect(find.text('HANG'), findsOneWidget);
      expect(find.text('BOTH HANDS'), findsOneWidget);
      expect(find.text('HC - 20mm'), findsOneWidget);
    });

    testWidgets('a rest before a hang without the sensor names its grip', (
      tester,
    ) async {
      await _pump(
        tester,
        item: const RestItem(durationSeconds: 3),
        nextItem: const TimedItem(
          label: 'Hang',
          durationSeconds: 10,
          targetLoad: 0,
          handSide: HandSide.both,
          gripPosition: GripPosition.halfCrimp,
          collectSensorData: false,
          isHang: true,
        ),
        secondsRemaining: 3,
      );

      expect(find.text('BOTH HANDS'), findsOneWidget);
      expect(find.text('HC'), findsOneWidget);
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
      // In the set and rep card, and again under the state word where the next
      // step sits while the run is going.
      expect(find.text('SET 2/4 - REP 3/6'), findsNWidgets(2));
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    // The sensor stream is muted for the whole pause, so the reading it stopped
    // on is stale. Holding it on screen looks like the athlete is still on the
    // board, when they let go to take the pause.
    testWidgets('pausing empties the force readout instead of freezing it', (
      tester,
    ) async {
      await _pump(tester, item: _hang, currentWeight: 34.2, isRunning: false);

      expect(find.text('34.2'), findsNothing);
      expect(find.text('0'), findsWidgets);
      expect(find.text('kg'), findsWidgets);
    });

    // Preparation runs with the timer stopped, and it is not a pause: there is
    // nothing to freeze yet.
    testWidgets('preparation is not treated as a pause', (tester) async {
      await _pump(
        tester,
        item: _hang,
        currentWeight: 34.2,
        isRunning: false,
        isPreparation: true,
      );

      expect(find.text('PAUSED'), findsNothing);
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

  group('the set and rep card', () {
    const busyHang = TimedItem(
      label: 'Hang',
      durationSeconds: 10,
      targetLoad: 12,
      handSide: HandSide.both,
      gripPosition: GripPosition.halfCrimp,
      collectSensorData: false,
      edgeSizeMm: 20,
      isHang: true,
    );

    void phone(WidgetTester tester, Size size) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    // The card is opaque, so a tall block running under it would lose its
    // last line, here the target.
    testWidgets('keeps clear of a tall block centred above it', (tester) async {
      phone(tester, const Size(390, 844));
      await _pump(
        tester,
        item: busyHang,
        secondsRemaining: 10,
        goal: 'Finger strength',
        protocol:
            'To failure or 10s. Past 10s add 2kg on the next set, under 6s '
            'take 2kg off, and stop the block after two misses in a row',
        comment:
            'Keep the shoulders engaged all the way through, breathe out on '
            'the way onto the edge and do not let the elbows lock at any '
            'point of the hang, even on the last set of the block',
      );

      final targetBottom = tester.getBottomLeft(find.text('TARGET 12 kg')).dy;
      final cardTop = tester
          .getTopLeft(
            find
                .ancestor(
                  of: find.text('SET 2/4 - REP 3/6'),
                  matching: find.byType(Container),
                )
                .first,
          )
          .dy;
      expect(targetBottom, lessThanOrEqualTo(cardTop));
    });

    // Opaque, so drawn any wider than its text it would hide the foot of the
    // force level across the whole tank.
    testWidgets('is only as wide as a short context needs', (tester) async {
      phone(tester, const Size(390, 844));
      await _pump(
        tester,
        item: _hang,
        currentWeight: 10,
        repContext: 'SET 1/3',
      );

      final card = find
          .ancestor(of: find.text('SET 1/3'), matching: find.byType(Container))
          .first;
      // The room the card is laid out in is the tank less 16 on each side.
      expect(tester.getSize(card).width, lessThan(390 - 32 - 60));
    });

    testWidgets('keeps a long context on one line on a narrow phone', (
      tester,
    ) async {
      phone(tester, const Size(360, 640));
      await _pump(
        tester,
        item: _hang,
        currentWeight: 10,
        repContext: 'SET 10/10 - REP 12/12',
      );

      final text = find.text('SET 10/10 - REP 12/12');
      final lines = tester
          .renderObject<RenderParagraph>(text)
          .getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 21),
          )
          .map((box) => box.top)
          .toSet();
      expect(lines, hasLength(1));
      expect(tester.takeException(), isNull);
    });
  });

  group('a step title', () {
    // The cap exists to stop a pathological title taking the tank over, not to
    // shorten a name a coach actually wrote: a title has no pause to read the
    // rest from, unlike a note's prose.
    testWidgets('long but real is shown whole', (tester) async {
      await _pump(
        tester,
        item: const ConfirmItem(
          label: 'Bulgarian split squat with a slow eccentric',
          reps: 8,
        ),
        repContext: null,
      );

      final title = tester.renderObject<RenderParagraph>(
        find.text('BULGARIAN SPLIT SQUAT WITH A SLOW ECCENTRIC'),
      );
      expect(title.didExceedMaxLines, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('long past all reason is cut short rather than overflowing', (
      tester,
    ) async {
      final absurd = List.filled(40, 'overhang').join(' ');
      await _pump(
        tester,
        item: ConfirmItem(label: absurd, reps: 8),
        repContext: null,
      );

      final title = tester.renderObject<RenderParagraph>(
        find.text(absurd.toUpperCase()),
      );
      expect(title.didExceedMaxLines, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  // The rest block names the step it leads into in the largest type on the
  // screen, so a long exercise name lands there at 30px. It is reachable
  // without any note at all.
  group('the rest preview', () {
    testWidgets('cuts a long name short rather than overflowing the tank', (
      tester,
    ) async {
      final longName = List.filled(20, 'overhang').join(' ');
      await _pump(
        tester,
        item: const RestItem(durationSeconds: 3),
        nextItem: TimedItem(
          label: longName,
          durationSeconds: 24,
          targetLoad: 0,
          handSide: HandSide.both,
          gripPosition: GripPosition.halfCrimp,
          collectSensorData: false,
        ),
        secondsRemaining: 3,
      );

      // The preview names a timed step as its label plus its length.
      final title = tester.renderObject<RenderParagraph>(
        find.text('${longName.toUpperCase()} 0:24'),
      );
      expect(title.didExceedMaxLines, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('leaves a name the block has room for whole', (tester) async {
      await _pump(
        tester,
        item: const RestItem(durationSeconds: 3),
        nextItem: _pullUps,
        secondsRemaining: 3,
      );

      final title = tester.renderObject<RenderParagraph>(
        find.text('PULL-UPS 0:24'),
      );
      expect(title.didExceedMaxLines, isFalse);
      expect(tester.takeException(), isNull);
    });
  });

  group('a note', () {
    // The whole point of the block: what the coach wrote between the exercises
    // is a prescription, so it is set as prose rather than shouted, and it fits
    // whatever the phone gave.
    testWidgets('reads as prose under its title and does not overflow', (
      tester,
    ) async {
      await _pump(
        tester,
        item: const ConfirmItem(label: 'Note', instructions: _prescription),
        repContext: null,
      );

      // A note reads no sensor, so the tank stands empty and its content is
      // drawn once: the clipped copy over the fill only exists when there is a
      // fill to clip it to.
      expect(find.text(_prescription), findsOneWidget);
      expect(find.text(_prescription.toUpperCase()), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('long enough to be cut short still fits the tank', (
      tester,
    ) async {
      await _pump(
        tester,
        item: ConfirmItem(label: 'Note', instructions: _longNote),
        repContext: null,
      );

      expect(tester.takeException(), isNull);
      final prose = tester.widget<Text>(find.text(_longNote).first);
      expect(prose.maxLines, noteProseMaxLines);
      expect(prose.overflow, TextOverflow.ellipsis);
    });

    // A header names the part of the session the way an exercise names its
    // step, so it keeps the treatment a step title has.
    testWidgets('short enough to be a title keeps the title treatment', (
      tester,
    ) async {
      await _pump(
        tester,
        item: const ConfirmItem(label: 'Grimpe :'),
        repContext: null,
      );

      expect(find.text('GRIMPE :'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // An athlete who sees the ellipsis taps the note to read the rest, which is
    // safe on a step they end themselves: they are stood in front of the phone
    // rather than hanging off the wall.
    testWidgets('tapping the prose opens the whole note', (tester) async {
      await _pump(
        tester,
        item: ConfirmItem(label: 'Note', instructions: _longNote),
        repContext: null,
      );

      expect(find.text('Tap the note to open it'), findsOneWidget);
      expect(find.text(_longNote), findsOneWidget);

      await tester.tap(find.text(_longNote));
      await tester.pumpAndSettle();

      // The capped copy on the tank, and the whole note in the reader over it.
      expect(find.text(_longNote), findsNWidgets(2));
      expect(
        find.ancestor(
          of: find.text(_longNote).last,
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
      expect(find.text('Close'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text(_longNote), findsOneWidget);
    });

    // Nothing to open, so nothing invites a tap.
    testWidgets('read at a glance offers no reader', (tester) async {
      await _pump(
        tester,
        item: const ConfirmItem(label: 'Grimpe :'),
        repContext: null,
      );

      expect(find.text('Tap the note to open it'), findsNothing);
    });

    // The band between a title and five wrapped lines: shown in full, and the
    // hint promises only what the tap does, since nothing here measures whether
    // the prose was cut short.
    testWidgets('short enough to fit is shown whole and still opens', (
      tester,
    ) async {
      const twoLines = 'Warm the fingers up properly before the first block.';
      await _pump(
        tester,
        item: const ConfirmItem(label: 'Note', instructions: twoLines),
        repContext: null,
      );

      final prose = tester.renderObject<RenderParagraph>(find.text(twoLines));
      expect(prose.didExceedMaxLines, isFalse);
      expect(find.text('Tap the note to open it'), findsOneWidget);

      await tester.tap(find.text(twoLines));
      await tester.pumpAndSettle();

      expect(find.text(twoLines), findsNWidgets(2));
      expect(find.text('Close'), findsOneWidget);
    });

    // A note is ended by the athlete like every other self paced step, so it
    // carries no play control of its own.
    testWidgets('offers no pause, as no other self paced step does', (
      tester,
    ) async {
      await _pump(
        tester,
        item: ConfirmItem(label: 'Note', instructions: _longNote),
        repContext: null,
      );

      expect(find.text('DONE'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);
      expect(find.byIcon(Icons.skip_next), findsNothing);
    });

    testWidgets('leaves the paused card the two lines it has always been', (
      tester,
    ) async {
      await _pump(
        tester,
        item: ConfirmItem(label: 'Note', instructions: _longNote),
        isRunning: false,
        repContext: null,
      );

      expect(find.text('PAUSED'), findsNWidgets(2));
      expect(find.text('Tap play to resume'), findsOneWidget);
      // The note is read from the tap, not from the card.
      expect(find.byType(SingleChildScrollView), findsNothing);
    });
  });

  // The goal is why the athlete is here, so it heads the step in its own
  // register rather than joining the numbers they are acting on.
  group('the goal of the block', () {
    testWidgets('heads a timed step, in capitals and on one line', (
      tester,
    ) async {
      await _pump(
        tester,
        item: _pullUps,
        goal: 'resi doigts',
        comment: 'Keep the shoulders engaged',
      );

      expect(find.text('RESI DOIGTS'), findsOneWidget);
      expect(find.text('PULL-UPS'), findsWidgets);
      expect(find.text('Keep the shoulders engaged'), findsWidgets);
    });

    testWidgets('heads a self paced step', (tester) async {
      await _pump(
        tester,
        item: const ConfirmItem(label: 'Dips', reps: 8),
        goal: 'explo jambes',
      );

      expect(find.text('EXPLO JAMBES'), findsOneWidget);
      expect(find.text('DIPS'), findsWidgets);
    });

    testWidgets('a rest names the goal of the step it leads into', (
      tester,
    ) async {
      await _pump(
        tester,
        item: const RestItem(durationSeconds: 60),
        nextItem: _pullUps,
        nextGoal: 'capacite/endurance doigts',
      );

      expect(find.text('CAPACITE/ENDURANCE DOIGTS'), findsOneWidget);
    });

    // A sensor step has its middle taken by the force, so the centered block
    // draws nothing. The goal goes under the target with the rest of the
    // notes, since a finger block is exactly what a coach writes a goal for.
    testWidgets('a sensor step carries it under the target, not the header', (
      tester,
    ) async {
      await _pump(
        tester,
        item: _hang,
        currentWeight: 34.2,
        goal: 'resi doigts',
        comment: 'Keep the shoulders engaged',
      );

      // The tank draws its content twice, the second copy clipped to the fill,
      // so the goal has to take its colour from the palette: a fixed green
      // paints the second copy into the dark fill and the goal vanishes exactly
      // where the athlete is hanging.
      expect(find.text('RESI DOIGTS'), findsNWidgets(2));
      final painted = tester
          .widgetList<Text>(find.text('RESI DOIGTS'))
          .map((text) => text.style?.color)
          .toSet();
      expect(painted, {CrimpyTheme.goalColor, CrimpyTheme.textOnFill});
      expect(find.text('Keep the shoulders engaged'), findsWidgets);
      expect(find.text('34.2'), findsWidgets);
      expect(
        tester.getRect(find.text('RESI DOIGTS').first).top,
        greaterThanOrEqualTo(
          tester.getRect(find.text('TARGET 42 kg').first).bottom,
        ),
      );
    });

    testWidgets('a step with no goal shows none', (tester) async {
      await _pump(tester, item: _pullUps);

      expect(find.text('RESI DOIGTS'), findsNothing);
      expect(find.text('PULL-UPS'), findsWidgets);
    });
  });

  // The rule is what the athlete resolves the step by, so it is on screen
  // while the step runs and again during the rest before the next one, which
  // is where it is acted on.
  group('the protocol of the block', () {
    const rule = 'To failure or 40s. Past 40s add 5kg.';

    testWidgets('is labelled under a timed step', (tester) async {
      await _pump(tester, item: _pullUps, protocol: rule);

      expect(find.text('PROTOCOL'), findsOneWidget);
      expect(find.text(rule), findsOneWidget);
    });

    testWidgets('is labelled under a self paced step', (tester) async {
      await _pump(
        tester,
        item: const ConfirmItem(label: 'Dips', reps: 8),
        protocol: rule,
      );

      expect(find.text('PROTOCOL'), findsOneWidget);
      expect(find.text(rule), findsOneWidget);
    });

    testWidgets('a rest carries the rule of the step it leads into', (
      tester,
    ) async {
      await _pump(
        tester,
        item: const RestItem(durationSeconds: 60),
        nextItem: _pullUps,
        nextProtocol: rule,
      );

      expect(find.text(rule), findsOneWidget);
    });

    // The tank draws its content twice, the second copy clipped to the fill,
    // so the label has to take its colour from the palette or the copy over
    // the fill paints gold on gold and disappears where the athlete is hanging.
    testWidgets('a sensor step carries it, coloured from the palette', (
      tester,
    ) async {
      await _pump(tester, item: _hang, currentWeight: 34.2, protocol: rule);

      expect(find.text('PROTOCOL'), findsNWidgets(2));
      final painted = tester
          .widgetList<Text>(find.text('PROTOCOL'))
          .map((text) => text.style?.color)
          .toSet();
      expect(painted, {CrimpyTheme.protocolColor, CrimpyTheme.textOnFill});
      expect(find.text(rule), findsNWidgets(2));
    });

    testWidgets('a step with no protocol shows none', (tester) async {
      await _pump(tester, item: _pullUps);

      expect(find.text('PROTOCOL'), findsNothing);
    });

    // The tank draws its content twice and cannot scroll, so everything in it
    // is bounded by a line cap. A step carrying a rule and a comment at the
    // server's limit together is the worst case of that, and it is the one the
    // caps exist for.
    testWidgets('lays out a protocol and a comment both at the limit', (
      tester,
    ) async {
      final long = List.filled(401, 'ceilings').join(' ').substring(0, 2000);
      final other = List.filled(401, 'rampup').join(' ').substring(0, 2000);

      await _pump(
        tester,
        item: _pullUps,
        protocol: long,
        comment: other,
        goal: 'resi doigts',
      );

      expect(find.text(long), findsOneWidget);
      expect(find.text(other), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out a rest preview carrying both at the limit', (
      tester,
    ) async {
      final long = List.filled(401, 'ceilings').join(' ').substring(0, 2000);
      final other = List.filled(401, 'rampup').join(' ').substring(0, 2000);

      await _pump(
        tester,
        item: const RestItem(durationSeconds: 60),
        nextItem: _pullUps,
        nextProtocol: long,
        nextComment: other,
      );

      expect(find.text(long), findsOneWidget);
      expect(find.text(other), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // The level cut the clocks and the countdown in two where its edge crossed
  // them. It stops under the header instead, as the header is drawn: with the
  // phone's text scale and the grip lines. See Krakoer/crimpy#161. The notes
  // of a hang used to grow the header past the notch and the force; they sit
  // in the lower tank now, under the target. See Krakoer/crimpy#180.
  group('the header', () {
    setUpAll(loadRoboto);

    // Each long enough to be cut short on any phone, so the line caps are
    // what the layout is measured against.
    const goal = 'Max strength, recruitment and finger stiffness';
    const protocol =
        'To failure or 10s. Past 10s add 2kg on the next set, under 6s take '
        '2kg off, and stop the block after two misses in a row';
    const comment =
        'Keep the shoulders engaged all the way through and breathe out on '
        'the way onto the edge, and do not let the elbows lock at any point';

    const headerTexts = [
      'ELAPSED',
      '4:12',
      'LEFT',
      '1:58',
      '5',
      'SEC',
      'BOTH HANDS',
      '3FD - 20mm',
    ];
    final noteTexts = [goal.toUpperCase(), 'PROTOCOL', protocol, comment];

    Future<void> pumpFullTank(
      WidgetTester tester, {
      required Size phone,
      required TargetPlatform platform,
      double textScale = 1,
      bool notes = false,
      bool withGoal = true,
      double currentWeight = 400,
      String? repContext = 'SET 2/4 - REP 3/6',
    }) async {
      tester.view.physicalSize = phone;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pump(
        tester,
        item: _hang,
        currentWeight: currentWeight,
        platform: platform,
        repContext: repContext,
        goal: notes && withGoal ? goal : null,
        protocol: notes ? protocol : null,
        comment: notes ? comment : null,
      );
    }

    double forceBaseline(WidgetTester tester) {
      final figure = find.text('400').first;
      final paragraph = tester.renderObject<RenderParagraph>(figure);
      final painter = TextPainter(
        text: paragraph.text,
        textDirection: TextDirection.ltr,
        textScaler: paragraph.textScaler,
      )..layout();
      addTearDown(painter.dispose);
      final rect = tester.getRect(figure);
      final drawnScale = rect.height / painter.height;
      return rect.top +
          painter.computeDistanceToActualBaseline(TextBaseline.alphabetic) *
              drawnScale;
    }

    double levelTop(WidgetTester tester) =>
        tester.getRect(find.byType(AnimatedContainer)).top;

    double footOf(WidgetTester tester, List<String> texts) => texts
        .map((text) => tester.getRect(find.text(text).first).bottom)
        .reduce(max);

    void expectAboveLevel(WidgetTester tester, List<String> texts) {
      final top = levelTop(tester);
      for (final text in texts) {
        final foot = tester.getRect(find.text(text).first).bottom;
        expect(top, greaterThanOrEqualTo(foot), reason: text);
      }
    }

    Rect tankRect(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(FullTankLayout),
            matching: find.byType(CustomMultiChildLayout),
          )
          .first,
    );

    double notchOf(WidgetTester tester) {
      final tank = tankRect(tester);
      return tank.bottom - tank.height * targetNotchFraction;
    }

    double cardTop(WidgetTester tester) => tester
        .getRect(
          find
              .ancestor(
                of: find.text('SET 2/4 - REP 3/6'),
                matching: find.byType(Container),
              )
              .first,
        )
        .top;

    const pixel = Size(412, 843);
    const iPhone15 = Size(393, 759);
    const iPhoneSE = Size(375, 647);

    // The phones and text scales the notes of a hang used to run into the
    // notch on, and the ones they did not.
    const layouts = [
      (TargetPlatform.android, pixel, 1.0),
      (TargetPlatform.android, pixel, 1.3),
      (TargetPlatform.android, iPhone15, 1.3),
      (TargetPlatform.android, iPhoneSE, 1.3),
      (TargetPlatform.iOS, iPhone15, 1.0),
      (TargetPlatform.iOS, iPhone15, 1.3),
      (TargetPlatform.iOS, pixel, 1.0),
      (TargetPlatform.iOS, pixel, 1.3),
      (TargetPlatform.iOS, iPhoneSE, 1.0),
      (TargetPlatform.iOS, iPhoneSE, 1.3),
    ];

    String named(TargetPlatform platform, Size phone, double textScale) =>
        '${platform.name} ${phone.width.toInt()}x${phone.height.toInt()} at '
        'text scale $textScale';

    for (final (platform, phone, textScale) in layouts) {
      for (final notes in [false, true]) {
        testWidgets('stops a full level under the clocks and the grip on '
            '${named(platform, phone, textScale)}'
            '${notes ? ', with the notes of the step' : ''}', (tester) async {
          await pumpFullTank(
            tester,
            phone: phone,
            platform: platform,
            textScale: textScale,
            notes: notes,
          );
          expectAboveLevel(tester, headerTexts);
          // Stopped by the header, not held at the notch for want of room,
          // and the notes of the step do not move it.
          expect(levelTop(tester), lessThan(notchOf(tester)));
          expect(levelTop(tester), lessThan(footOf(tester, headerTexts) + 16));
        });
      }

      testWidgets('keeps the notes of a hang between the target and the card '
          'on ${named(platform, phone, textScale)}', (tester) async {
        await pumpFullTank(
          tester,
          phone: phone,
          platform: platform,
          textScale: textScale,
          notes: true,
        );
        expect(tester.takeException(), isNull);

        final target = tester.getRect(find.text('TARGET 42 kg').first);
        final targetFoot = target.bottom;
        final forceFoot = footOf(tester, ['400', 'kg']);
        final card = cardTop(tester);
        // The notes are placed off the target, so the target has to clear the
        // force above it: the foot of the figure, which has no descender, is
        // its baseline.
        expect(target.top, greaterThanOrEqualTo(forceBaseline(tester)));
        for (final note in noteTexts) {
          final rect = tester.getRect(find.text(note).first);
          expect(rect.top, greaterThanOrEqualTo(targetFoot), reason: note);
          expect(rect.top, greaterThan(forceFoot), reason: note);
          expect(rect.bottom, lessThanOrEqualTo(card), reason: note);
        }
      });
    }

    // Without a set and rep card the notes still end above the foot of the
    // tank, where the controls start.
    testWidgets('keeps the notes of a hang above the controls', (tester) async {
      await pumpFullTank(
        tester,
        phone: iPhoneSE,
        platform: TargetPlatform.iOS,
        textScale: 1.3,
        notes: true,
        repContext: null,
      );
      expect(tester.takeException(), isNull);
      // The reserve kept at the foot of a tank with no card.
      expect(
        footOf(tester, noteTexts),
        lessThanOrEqualTo(tankRect(tester).bottom - 14),
      );
    });

    // Past the text sizes the notes are held to, the lower tank cannot take
    // them all. They are dropped rather than run under the opaque card: the
    // comment first, then the goal, and the stop rule last.
    for (final (platform, phone) in [
      (TargetPlatform.android, pixel),
      (TargetPlatform.android, iPhoneSE),
      (TargetPlatform.iOS, iPhone15),
      (TargetPlatform.iOS, iPhoneSE),
    ]) {
      for (final textScale in [1.5, 2.0]) {
        testWidgets('drops notes rather than overflow on '
            '${named(platform, phone, textScale)}', (tester) async {
          await pumpFullTank(
            tester,
            phone: phone,
            platform: platform,
            textScale: textScale,
            notes: true,
          );
          expect(tester.takeException(), isNull);

          final clip = tester
              .getRect(
                find
                    .ancestor(
                      of: find.text(protocol).first,
                      matching: find.byType(ClipRect),
                    )
                    .first,
              )
              .bottom;
          bool shown(String note) =>
              tester.getRect(find.text(note).first).top < clip;
          for (final note in noteTexts) {
            final rect = tester.getRect(find.text(note).first);
            if (shown(note)) {
              expect(rect.bottom, lessThanOrEqualTo(clip), reason: note);
            }
          }
          expect(clip, lessThanOrEqualTo(cardTop(tester)));
          expect(shown(protocol), isTrue);
          if (shown(comment)) expect(shown(goal.toUpperCase()), isTrue);
          // Pinned where it is known: on the small phone the comment goes at
          // 1.5, and the goal after it at 2.0.
          if (phone == iPhoneSE) {
            expect(shown(comment), isFalse);
            expect(shown(goal.toUpperCase()), textScale < 2);
          }
        });
      }
    }

    // A hang with no goal starts its notes with the rule, set as close under
    // the target as a note under the goal would be.
    for (final (platform, phone) in [
      (TargetPlatform.android, pixel),
      (TargetPlatform.iOS, iPhoneSE),
    ]) {
      for (final textScale in [1.0, 1.3]) {
        testWidgets('sets the rule of a hang with no goal under the target on '
            '${named(platform, phone, textScale)}', (tester) async {
          await pumpFullTank(
            tester,
            phone: phone,
            platform: platform,
            textScale: textScale,
            notes: true,
            withGoal: false,
          );
          expect(tester.takeException(), isNull);

          final scale = tankRect(tester).height / 624;
          final targetFoot = tester
              .getRect(find.text('TARGET 42 kg').first)
              .bottom;
          expect(
            tester.getRect(find.text('PROTOCOL').first).top,
            closeTo(targetFoot + 8 * scale, 0.01),
          );
          final commentRect = tester.getRect(find.text(comment).first);
          expect(
            commentRect.top,
            closeTo(
              tester.getRect(find.text(protocol).first).bottom + 8 * scale,
              0.01,
            ),
          );
          expect(commentRect.bottom, lessThanOrEqualTo(cardTop(tester)));
        });
      }
    }

    // The lower tank has room for a line of goal, two of rule and one of
    // comment at text scale 1.3 on a small phone. The rest of each is on the
    // training breakdown.
    testWidgets('holds the notes of a hang to what the lower tank fits', (
      tester,
    ) async {
      await pumpFullTank(
        tester,
        phone: iPhoneSE,
        platform: TargetPlatform.android,
        textScale: 1.3,
        notes: true,
      );
      for (final (note, lines) in [
        (goal.toUpperCase(), 1),
        (protocol, 2),
        (comment, 1),
      ]) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(note).first,
        );
        expect(paragraph.maxLines, lines, reason: note);
        expect(paragraph.didExceedMaxLines, isTrue, reason: note);
      }
    });

    // Only a hang has its middle taken by the force. A rest and a timed step
    // keep the room they had for the notes.
    testWidgets('leaves a rest preview its four lines of notes', (
      tester,
    ) async {
      await _pump(
        tester,
        item: const RestItem(durationSeconds: 60),
        nextItem: _pullUps,
        nextProtocol: protocol,
        nextComment: comment,
      );
      for (final note in [protocol, comment]) {
        expect(
          tester.renderObject<RenderParagraph>(find.text(note)).maxLines,
          4,
          reason: note,
        );
      }
    });

    testWidgets('leaves a timed step its four lines of notes', (tester) async {
      await _pump(tester, item: _pullUps, protocol: protocol, comment: comment);
      for (final note in [protocol, comment]) {
        expect(
          tester.renderObject<RenderParagraph>(find.text(note)).maxLines,
          4,
          reason: note,
        );
      }
    });

    // A header deeper than the tank has room for above the notch still lets
    // the level reach the target. It stops at the notch, and what it crosses
    // is drawn over it in the colours that read there.
    testWidgets('still lets the level reach the notch under a deep header', (
      tester,
    ) async {
      await pumpFullTank(
        tester,
        phone: iPhoneSE,
        platform: TargetPlatform.iOS,
        textScale: 2.2,
      );

      final notch = notchOf(tester);
      expect(footOf(tester, headerTexts), greaterThan(notch));
      expect(levelTop(tester), closeTo(notch, 0.01));
    });

    // The copy over the level is only readable if it lands exactly on the
    // copy under it, text for text.
    void expectInRegister(WidgetTester tester, {bool notes = true}) {
      final copies = <String, int>{};
      for (final text in tester.widgetList<Text>(find.byType(Text))) {
        final data = text.data;
        if (data != null) {
          copies.update(data, (n) => n + 1, ifAbsent: () => 1);
        }
      }
      final doubled = [
        for (final MapEntry(:key, :value) in copies.entries)
          if (value == 2) key,
      ];
      expect(
        doubled,
        containsAll(['ELAPSED', 'BOTH HANDS', 'kg', if (notes) ...noteTexts]),
      );
      for (final text in doubled) {
        expect(
          tester.getRect(find.text(text).at(1)),
          tester.getRect(find.text(text).at(0)),
          reason: text,
        );
      }
    }

    // The level rises through the notes on its way to the target, so they are
    // drawn in both palettes, and the edge crossing them leaves each half in
    // the colours that read on its side.
    testWidgets('draws the notes over a level crossing them in register', (
      tester,
    ) async {
      await pumpFullTank(
        tester,
        phone: pixel,
        platform: TargetPlatform.android,
        currentWeight: 0,
        notes: true,
      );
      final notesTop = tester.getRect(find.text(goal.toUpperCase())).top;
      final notesFoot = tester.getRect(find.text(comment)).bottom;
      final tank = tankRect(tester);
      final crossing = (notesTop + notesFoot) / 2;
      // The weight whose level ends halfway down the notes.
      final weight =
          (tank.bottom - crossing) / tank.height / targetNotchFraction * 42;

      await pumpFullTank(
        tester,
        phone: pixel,
        platform: TargetPlatform.android,
        currentWeight: weight,
        notes: true,
      );
      expect(levelTop(tester), closeTo(crossing, 0.01));
      expectInRegister(tester);
      for (final (note, overTank) in [
        (goal.toUpperCase(), CrimpyTheme.goalColor),
        ('PROTOCOL', CrimpyTheme.protocolColor),
        (comment, CrimpyTheme.textSecondary),
      ]) {
        expect(
          tester.widgetList<Text>(find.text(note)).map((t) => t.style?.color),
          [
            overTank,
            anyOf(CrimpyTheme.textOnFill, CrimpyTheme.textOnFillSecondary),
          ],
          reason: note,
        );
      }
    });

    testWidgets('draws the copy over a level below the header in register', (
      tester,
    ) async {
      await pumpFullTank(
        tester,
        phone: pixel,
        platform: TargetPlatform.android,
        currentWeight: 30,
        notes: true,
      );
      expectInRegister(tester);
    });

    testWidgets('draws the copy over a level held at the notch in register', (
      tester,
    ) async {
      await pumpFullTank(
        tester,
        phone: iPhoneSE,
        platform: TargetPlatform.iOS,
        textScale: 2.2,
      );
      expectInRegister(tester, notes: false);
    });

    testWidgets('leaves a level under the header where it was', (tester) async {
      await _pump(tester, item: _hang, currentWeight: 21);

      final level = tester.getRect(find.byType(AnimatedContainer));
      final tank = tankRect(tester);
      expect(
        level.height,
        closeTo(
          tankFillFraction(currentWeight: 21, scaleWeight: 42) * tank.height,
          0.01,
        ),
      );
      expect(level.bottom, tank.bottom);
    });
  });

  // The block a step without the sensor holds in the middle of the tank was
  // centred over the whole of it, so at a large text size it slid under the
  // clocks, and a tall one ran past the tank. It is laid out under the header
  // now, above the set and rep card, and shrunk to fit where it has to be.
  // See Krakoer/crimpy#181.
  group('the centre block', () {
    setUpAll(loadRoboto);

    const goal = 'Max strength';
    const protocol = 'To failure or 10s. Past 10s add 2kg on the next set';
    const comment =
        'Keep the shoulders engaged and breathe out on the way onto the edge';

    const timedHang = TimedItem(
      label: 'Hang',
      durationSeconds: 10,
      targetLoad: 12,
      handSide: HandSide.both,
      gripPosition: GripPosition.halfCrimp,
      collectSensorData: false,
      edgeSizeMm: 20,
      isHang: true,
    );

    // Each step, with the text the block ends on.
    final steps = <(String, TrainingExecutionItem, bool, String)>[
      ('a timed step', _pullUps, false, 'SEC LEFT'),
      ('a timed hang without the sensor', timedHang, false, 'SEC LEFT'),
      (
        'a self paced step',
        const ConfirmItem(label: 'Dips', reps: 8),
        false,
        'Tap DONE when finished',
      ),
      (
        'a self paced step with a long note',
        ConfirmItem(label: 'Kilter', instructions: _longNote),
        false,
        'Tap DONE when finished',
      ),
      ('a rest', const RestItem(durationSeconds: 60), false, 'NEXT'),
      ('the preparation', _pullUps, true, 'PREPARATION'),
    ];

    Future<void> pumpStep(
      WidgetTester tester, {
      required TrainingExecutionItem item,
      required bool isPreparation,
      required Size phone,
      required TargetPlatform platform,
      required double textScale,
    }) async {
      tester.view.physicalSize = phone;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pump(
        tester,
        item: item,
        nextItem: item is RestItem || isPreparation ? timedHang : null,
        isPreparation: isPreparation,
        platform: platform,
        goal: goal,
        protocol: protocol,
        comment: comment,
        nextGoal: goal,
        nextProtocol: protocol,
        nextComment: comment,
      );
    }

    Finder blockOf(String lastText) => find
        .ancestor(
          of: find.text(lastText).last,
          matching: find.byType(FittedBox),
        )
        .first;

    /// How much the block is shrunk by, 1 where it is drawn at its size.
    double shrinkOf(WidgetTester tester, Finder block) {
      final fitted = tester.renderObject<RenderProxyBox>(block);
      return tester.getRect(block).height / fitted.child!.size.height;
    }

    /// The foot of the clocks, and of the countdown in the corner on the
    /// steps that have one there.
    double headerFoot(WidgetTester tester, {required bool cornerCountdown}) =>
        [
              'ELAPSED',
              '4:12',
              'LEFT',
              '1:58',
              if (cornerCountdown) ...['5', 'SEC', 'SEC REST'],
            ]
            .where((text) => find.text(text).evaluate().isNotEmpty)
            .map((text) => tester.getRect(find.text(text).first).bottom)
            .reduce(max);

    double cardTop(WidgetTester tester) => tester
        .getRect(
          find
              .ancestor(
                of: find.text('SET 2/4 - REP 3/6'),
                matching: find.byType(Container),
              )
              .first,
        )
        .top;

    const pixel = Size(412, 843);
    const iPhone15 = Size(393, 759);
    const iPhoneSE = Size(375, 647);

    const layouts = [
      (TargetPlatform.android, pixel, 1.0),
      (TargetPlatform.android, pixel, 1.3),
      (TargetPlatform.android, iPhone15, 1.3),
      (TargetPlatform.android, iPhoneSE, 1.3),
      (TargetPlatform.iOS, iPhone15, 1.0),
      (TargetPlatform.iOS, iPhone15, 1.3),
      (TargetPlatform.iOS, pixel, 1.0),
      (TargetPlatform.iOS, pixel, 1.3),
      (TargetPlatform.iOS, iPhoneSE, 1.0),
      (TargetPlatform.iOS, iPhoneSE, 1.3),
    ];

    for (final (platform, phone, textScale) in [
      ...layouts,
      // Past the sizes it is held to, it still has to stay in the tank.
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS])
        for (final phone in [pixel, iPhoneSE])
          for (final textScale in [1.5, 2.0]) (platform, phone, textScale),
    ]) {
      for (final (name, item, isPreparation, lastText) in steps) {
        testWidgets('keeps $name between the header and the card on '
            '${platform.name} ${phone.width.toInt()}x${phone.height.toInt()} '
            'at text scale $textScale', (tester) async {
          await pumpStep(
            tester,
            item: item,
            isPreparation: isPreparation,
            phone: phone,
            platform: platform,
            textScale: textScale,
          );
          expect(tester.takeException(), isNull);

          final block = tester.getRect(blockOf(lastText));
          expect(
            block.top,
            greaterThanOrEqualTo(
              headerFoot(
                tester,
                cornerCountdown: item is RestItem || isPreparation,
              ),
            ),
          );
          expect(block.bottom, lessThanOrEqualTo(cardTop(tester)));
        });
      }
    }

    // Where the block has the room, it is drawn at its size and where it
    // always was: centred between the top of the tank and the card.
    testWidgets('leaves a block that fits at its size and centred', (
      tester,
    ) async {
      await pumpStep(
        tester,
        item: _pullUps,
        isPreparation: false,
        phone: pixel,
        platform: TargetPlatform.android,
        textScale: 1,
      );

      final block = blockOf('SEC LEFT');
      expect(shrinkOf(tester, block), closeTo(1, 1e-9));
      final tank = tester.getRect(
        find
            .descendant(
              of: find.byType(FullTankLayout),
              matching: find.byType(CustomMultiChildLayout),
            )
            .first,
      );
      final roomFoot = cardTop(tester) - 12 * tank.height / 624;
      expect(
        tester.getRect(block).center.dy,
        closeTo(tank.top + (14 + roomFoot - tank.top) / 2, 0.01),
      );
    });

    // The one that does not fit is shrunk whole, rather than run under the
    // clocks or the card.
    testWidgets('shrinks a block taller than the room it has', (tester) async {
      await pumpStep(
        tester,
        item: timedHang,
        isPreparation: false,
        phone: iPhoneSE,
        platform: TargetPlatform.iOS,
        textScale: 1.3,
      );

      expect(shrinkOf(tester, blockOf('SEC LEFT')), lessThan(1));
    });

    // The countdown is display sized already. Grown with the text size it
    // took the room the notes needed.
    testWidgets('keeps the countdown at its size whatever the text size', (
      tester,
    ) async {
      Future<double> countdownHeight(double textScale) async {
        await pumpStep(
          tester,
          item: _pullUps,
          isPreparation: false,
          phone: pixel,
          platform: TargetPlatform.android,
          textScale: textScale,
        );
        expect(shrinkOf(tester, blockOf('SEC LEFT')), closeTo(1, 1e-9));
        return tester.getRect(find.text('5')).height;
      }

      expect(await countdownHeight(1.3), await countdownHeight(1));
    });
  });
}
