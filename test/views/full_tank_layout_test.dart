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

class _FakeBodyweight extends BodyweightController {
  _FakeBodyweight(this.kilograms);

  final double? kilograms;

  @override
  Future<double?> build() async => kilograms;
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
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bleLastValueProvider.overrideWithValue(currentWeight),
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

void main() {
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
    testWidgets('splits the force so the whole number reads first', (
      tester,
    ) async {
      await _pump(
        tester,
        item: _hang,
        currentWeight: 34.2,
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
      expect(find.text('01:58'), findsWidgets);
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
      expect(find.text('REST 3S'), findsOneWidget);
    });

    testWidgets('draws the readouts twice so they invert over the level', (
      tester,
    ) async {
      await _pump(tester, item: _hang, currentWeight: 34.2);
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

    testWidgets('scales a step prescribing no load against the bodyweight', (
      tester,
    ) async {
      await _pump(tester, item: _maxHang, currentWeight: 34.2, bodyweight: 72);

      expect(find.text('BW 72 kg'), findsWidgets);
      expect(find.textContaining('TARGET'), findsNothing);
      // The level is up, so both copies of the readout are drawn.
      expect(find.text('34'), findsNWidgets(2));
    });

    testWidgets('leaves the tank empty when it has nothing to scale against', (
      tester,
    ) async {
      await _pump(tester, item: _maxHang, currentWeight: 34.2);

      expect(find.textContaining('BW'), findsNothing);
      expect(find.textContaining('TARGET'), findsNothing);
      expect(find.text('34'), findsOneWidget);
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
      expect(find.text('01:58'), findsOneWidget);
      expect(find.text('REST 30S'), findsOneWidget);
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
      // In the pill, and again under the state word where the next step sits
      // while the run is going.
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

      expect(find.text('34'), findsNothing);
      expect(find.text('.2 kg'), findsNothing);
      expect(find.text('0'), findsWidgets);
      expect(find.text(' kg'), findsWidgets);
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
        find.text('${longName.toUpperCase()} 24S'),
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
        find.text('PULL-UPS 24S'),
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
    // draws nothing. The goal goes where the comment already goes for that
    // state, since a finger block is exactly what a coach writes a goal for.
    testWidgets('a sensor step carries it beside the grip, not in the middle', (
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
      expect(painted, {CrimpyTheme.goalColor, CrimpyTheme.primaryWhite});
      expect(find.text('Keep the shoulders engaged'), findsWidgets);
      expect(find.text('34'), findsWidgets);
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
      expect(painted, {CrimpyTheme.protocolColor, CrimpyTheme.primaryWhite});
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
}
