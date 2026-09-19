import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:flutter_test/flutter_test.dart';

RepDataModel _rep({
  required int index,
  String? itemId,
  bool isRest = false,
  int duration = 7,
  double averageWeight = 20,
  double targetWeight = 20,
  HandSide hand = HandSide.right,
  bool targetUnmeasured = false,
}) => RepDataModel(
  averageWeight: averageWeight,
  duration: duration,
  index: index,
  isRest: isRest,
  handSide: hand,
  targetWeight: targetWeight,
  trainingItemId: itemId,
  targetUnmeasured: targetUnmeasured,
);

TrainingItem _item({
  required String id,
  TrainingItemType type = TrainingItemType.repeater,
  int position = 0,
  int? cycles,
  int? reps,
  int? cycleRestSeconds,
  String? hand,
  String? exerciseName,
  String? groupTitle,
  List<int>? edgeSizesMm,
  List<TrainingItem> items = const [],
}) => TrainingItem(
  id: id,
  type: type,
  position: position,
  cycles: cycles,
  reps: reps,
  cycleRestSeconds: cycleRestSeconds,
  hand: hand,
  exerciseName: exerciseName,
  groupTitle: groupTitle,
  edgeSizesMm: edgeSizesMm,
  items: items,
);

void main() {
  group('review pass', _reviewPassTests);
  group('groupRepsByTrainingItem', () {
    test('returns null when no rep names an item', () {
      final reps = [_rep(index: 0), _rep(index: 1)];
      expect(groupRepsByTrainingItem(reps, [_item(id: 'a')]), null);
    });

    test('cuts a new block wherever the item changes', () {
      final reps = [
        _rep(index: 0, itemId: 'a'),
        _rep(index: 1, itemId: 'a'),
        _rep(index: 2, itemId: 'b'),
      ];
      final items = [
        _item(
          id: 'a',
          type: TrainingItemType.exercise,
          exerciseName: 'Pull ups',
        ),
        _item(
          id: 'b',
          type: TrainingItemType.exercise,
          position: 1,
          exerciseName: 'Dips',
        ),
      ];

      final blocks = groupRepsByTrainingItem(reps, items)!;

      expect(blocks.map((b) => b.label), ['Pull ups', 'Dips']);
      expect(blocks.map((b) => b.reps.length), [2, 1]);
    });

    test('numbers the passes when an item is played more than once', () {
      final reps = [
        _rep(index: 0, itemId: 'a'),
        _rep(index: 1, itemId: 'b'),
        _rep(index: 2, itemId: 'a'),
      ];
      final items = [
        _item(
          id: 'a',
          type: TrainingItemType.exercise,
          exerciseName: 'Pull ups',
        ),
        _item(
          id: 'b',
          type: TrainingItemType.exercise,
          position: 1,
          exerciseName: 'Dips',
        ),
      ];

      final blocks = groupRepsByTrainingItem(reps, items)!;

      expect(blocks.map((b) => b.label), [
        'Pull ups (pass 1)',
        'Dips',
        'Pull ups (pass 2)',
      ]);
    });

    test('keeps a link the training can no longer name as its own block', () {
      final reps = [
        _rep(index: 0, itemId: 'a'),
        _rep(index: 1, itemId: 'gone'),
        _rep(index: 2, itemId: 'a'),
      ];
      final items = [
        _item(
          id: 'a',
          type: TrainingItemType.exercise,
          exerciseName: 'Pull ups',
        ),
      ];

      final blocks = groupRepsByTrainingItem(reps, items)!;

      expect(blocks.map((b) => b.label), [
        'Pull ups (pass 1)',
        'Unnamed block',
        'Pull ups (pass 2)',
      ]);
    });

    test('finds an item nested in a circuit', () {
      final reps = [_rep(index: 0, itemId: 'child')];
      final items = [
        _item(
          id: 'circuit',
          type: TrainingItemType.circuit,
          groupTitle: 'Core',
          items: [
            _item(
              id: 'child',
              type: TrainingItemType.exercise,
              exerciseName: 'Front lever',
            ),
          ],
        ),
      ];

      final blocks = groupRepsByTrainingItem(reps, items)!;

      expect(blocks.single.label, 'Front lever');
    });

    test('returns null when no rep names an item the training still holds', () {
      // A guest-mode run resolves no training at all, and the local reps carry
      // their item links regardless. Heading every block 'Unnamed block' would
      // read as a breakdown while saying less than the flat list does.
      final reps = [_rep(index: 0, itemId: 'a'), _rep(index: 1, itemId: 'a')];

      expect(groupRepsByTrainingItem(reps, const []), null);
      expect(groupRepsByTrainingItem(reps, [_item(id: 'other')]), null);
    });

    test('keeps an unnamed block when another rep does name its item', () {
      final reps = [
        _rep(index: 0, itemId: 'a'),
        _rep(index: 1, itemId: 'gone'),
      ];

      final blocks = groupRepsByTrainingItem(reps, [
        _item(id: 'a', type: TrainingItemType.hangboardRep, reps: 1),
      ])!;

      expect(blocks.map((b) => b.label), ['Hang rep', 'Unnamed block']);
    });

    test('a block that is not a repeater carries no sets', () {
      final reps = [_rep(index: 0, itemId: 'a')];
      final items = [
        _item(id: 'a', type: TrainingItemType.hangboardRep, reps: 3),
      ];

      expect(groupRepsByTrainingItem(reps, items)!.single.sets, null);
    });
  });

  group('groupRepsIntoSets', () {
    test('splits a two handed repeater into one set per hand', () {
      final item = _item(
        id: 'a',
        cycles: 2,
        reps: 2,
        cycleRestSeconds: 120,
        hand: HangboardHand.alternate,
      );
      // Both callers filter the rests out before grouping, so a set is cut by
      // its rep count alone.
      final reps = [
        _rep(index: 0, itemId: 'a'),
        _rep(index: 1, itemId: 'a', hand: HandSide.left),
        _rep(index: 2, itemId: 'a'),
        _rep(index: 3, itemId: 'a', hand: HandSide.left),
        _rep(index: 4, itemId: 'a'),
        _rep(index: 5, itemId: 'a', hand: HandSide.left),
        _rep(index: 6, itemId: 'a'),
        _rep(index: 7, itemId: 'a', hand: HandSide.left),
      ];

      final sets = groupRepsIntoSets(reps, repeaterConfigOfItem(item)!);

      expect(sets.map((s) => s.label), [
        'Set 1 - Right',
        'Set 1 - Left',
        'Set 2 - Right',
        'Set 2 - Left',
      ]);
      expect(sets.every((s) => s.reps.length == 2), true);
    });

    test('splits a split hand repeater set by set', () {
      final item = _item(
        id: 'a',
        cycles: 1,
        reps: 2,
        cycleRestSeconds: 120,
        hand: HangboardHand.split,
      );
      final reps = [
        _rep(index: 0, itemId: 'a'),
        _rep(index: 1, itemId: 'a'),
        _rep(index: 2, itemId: 'a', hand: HandSide.left),
        _rep(index: 3, itemId: 'a', hand: HandSide.left),
      ];

      final sets = groupRepsIntoSets(reps, repeaterConfigOfItem(item)!);

      expect(sets.map((s) => s.label), ['Set 1 - Right', 'Set 1 - Left']);
    });

    test('names a two handed set after no hand at all', () {
      // 'both' puts two hands on the board for a single rep, so there is no
      // right or left half to cut the set into. The app records such a rep on
      // the left, which would otherwise head every set of a two-handed hang
      // 'Left'.
      final item = _item(id: 'a', cycles: 2, reps: 2, hand: HangboardHand.both);
      final reps = [
        for (var i = 0; i < 4; i++)
          _rep(index: i, itemId: 'a', hand: HandSide.left),
      ];

      final sets = groupRepsIntoSets(reps, repeaterConfigOfItem(item)!);

      expect(sets.map((s) => s.label), ['Set 1', 'Set 2']);
      expect(sets.every((s) => s.reps.length == 2), true);
    });

    test('shows reps the configuration did not account for', () {
      final item = _item(
        id: 'a',
        cycles: 1,
        reps: 1,
        cycleRestSeconds: 120,
        hand: HangboardHand.both,
      );
      final reps = [
        _rep(index: 0, itemId: 'a'),
        _rep(index: 1, itemId: 'a'),
        _rep(index: 2, itemId: 'a'),
      ];

      final sets = groupRepsIntoSets(reps, repeaterConfigOfItem(item)!);

      expect(sets.last.label, 'Remaining');
      expect(sets.last.reps.length, 2);
    });
  });

  group('sessionBlockLabel', () {
    test('names a repeater the way the portal does, edge included', () {
      expect(
        sessionBlockLabel(
          _item(id: 'a', cycles: 1, reps: 1, edgeSizesMm: const [20]),
        ),
        'Hangboard 20mm',
      );
    });

    test('leaves a block spanning several edges on its type', () {
      expect(
        sessionBlockLabel(
          _item(id: 'a', cycles: 1, reps: 1, edgeSizesMm: const [20, 14]),
        ),
        'Hangboard',
      );
    });

    test('prefers the title the athlete gave the block', () {
      expect(
        sessionBlockLabel(
          _item(
            id: 'a',
            cycles: 1,
            reps: 1,
            groupTitle: 'Max hangs',
            edgeSizesMm: const [20],
          ),
        ),
        'Max hangs',
      );
    });

    test('names an exercise after itself', () {
      expect(
        sessionBlockLabel(
          _item(
            id: 'a',
            type: TrainingItemType.exercise,
            exerciseName: 'Front lever',
          ),
        ),
        'Front lever',
      );
    });
  });

  group('repeaterConfigOfItem', () {
    test('is null for an item that is not a repeater', () {
      expect(
        repeaterConfigOfItem(
          _item(id: 'a', type: TrainingItemType.exercise, reps: 3),
        ),
        null,
      );
    });

    test('is null for a repeater with nothing to lay out', () {
      expect(repeaterConfigOfItem(_item(id: 'a', cycles: 0, reps: 0)), null);
    });

    test('only the alternating mode works two hands per set', () {
      expect(
        repeaterConfigOfItem(
          _item(id: 'a', cycles: 1, reps: 1, hand: HangboardHand.alternate),
        )!.handsPerSet,
        2,
      );
      expect(
        repeaterConfigOfItem(
          _item(id: 'a', cycles: 1, reps: 1, hand: HangboardHand.both),
        )!.handsPerSet,
        1,
      );
    });
  });

  group('onTargetCount', () {
    test('a run given no target is not a failed one', () {
      expect(onTargetCount([_rep(index: 0, targetWeight: 0)]), null);
    });

    test('rests are not reps to grade', () {
      final count = onTargetCount([
        _rep(index: 0, averageWeight: 20, targetWeight: 20),
        _rep(index: 1, isRest: true, targetWeight: 0),
      ]);
      expect(count, (onTarget: 1, total: 1, unmeasured: 0));
    });

    test('a rep at 90% of its target counts, one below it does not', () {
      final count = onTargetCount([
        _rep(index: 0, averageWeight: 18, targetWeight: 20),
        _rep(index: 1, averageWeight: 17.9, targetWeight: 20),
      ]);
      expect(count, (onTarget: 1, total: 2, unmeasured: 0));
    });

    test('a rep the training gave no target misses, once a target was set', () {
      final count = onTargetCount([
        _rep(index: 0, averageWeight: 20, targetWeight: 20),
        _rep(index: 1, averageWeight: 20, targetWeight: 0),
      ]);
      expect(count, (onTarget: 1, total: 2, unmeasured: 0));
    });

    test('a rep whose target the sensor never measured leaves the ratio', () {
      final count = onTargetCount([
        _rep(index: 0, averageWeight: 20, targetWeight: 20),
        _rep(index: 1, averageWeight: 20, targetWeight: 20),
        for (var index = 2; index < 6; index++)
          _rep(
            index: index,
            averageWeight: 0,
            targetWeight: 0,
            targetUnmeasured: true,
          ),
      ]);
      expect(count, (onTarget: 2, total: 2, unmeasured: 4));
    });

    test('a group whose only target went unmeasured grades nothing', () {
      // Nothing enforces an empty target on a flagged rep outside the app, and
      // a 0/0 ratio would read as a run that met none of its targets.
      final count = onTargetCount([
        _rep(index: 0, averageWeight: 20, targetWeight: 0),
        _rep(
          index: 1,
          averageWeight: 0,
          targetWeight: 20,
          targetUnmeasured: true,
        ),
      ]);
      expect(count, null);
    });

    test('a run the sensor never measured at all grades nothing', () {
      final count = onTargetCount([
        for (var index = 0; index < 3; index++)
          _rep(
            index: index,
            averageWeight: 0,
            targetWeight: 0,
            targetUnmeasured: true,
          ),
      ]);
      expect(count, null);
    });
  });

  group('measuredAvgWeight', () {
    test('averages the reps the sensor weighed', () {
      final average = measuredAvgWeight([
        _rep(index: 0, averageWeight: 30, targetWeight: 30),
        _rep(index: 1, averageWeight: 30, targetWeight: 30),
        for (var index = 2; index < 4; index++)
          _rep(
            index: index,
            averageWeight: 0,
            targetWeight: 0,
            targetUnmeasured: true,
          ),
      ]);
      // Counting the two the sensor missed would read 15.0 kg, a load the
      // athlete never pulled, beside a ratio that already leaves them out.
      expect(average, 30);
    });

    test('leaves the rests out', () {
      final average = measuredAvgWeight([
        _rep(index: 0, averageWeight: 30, targetWeight: 30),
        _rep(index: 1, isRest: true, averageWeight: 0, targetWeight: 0),
      ]);
      expect(average, 30);
    });

    test('keeps the zero a working sensor read', () {
      final average = measuredAvgWeight([
        _rep(index: 0, averageWeight: 30, targetWeight: 30),
        _rep(index: 1, averageWeight: 0, targetWeight: 30),
      ]);
      expect(average, 15);
    });

    test('a run the sensor never measured at all states no load', () {
      final average = measuredAvgWeight([
        for (var index = 0; index < 3; index++)
          _rep(
            index: index,
            averageWeight: 0,
            targetWeight: 0,
            targetUnmeasured: true,
          ),
      ]);
      expect(average, null);
    });

    test('a run nothing was ever meant to weigh states no load', () {
      final average = measuredAvgWeight([
        for (var index = 0; index < 3; index++)
          _rep(index: index, averageWeight: 0, targetWeight: 0),
      ]);
      expect(average, null);
    });
  });

  group('measuredAvgWeight counts the reps the run weighed', () {
    test('leaves out a rep the sensor missed that prescribed no load', () {
      // A rep the sensor dropped on a run with no target is not flagged
      // unmeasured, since nothing was prescribed to lose. Averaged in, its zero
      // states 15.0 kg beside a row that names it unmeasured.
      final avg = measuredAvgWeight([
        _rep(index: 0, averageWeight: 30, targetWeight: 0),
        _rep(index: 1, averageWeight: 0, targetWeight: 0),
      ]);
      expect(avg, 30);
    });
  });

  group('measuredMaxWeight', () {
    test('takes the heaviest of the reps the sensor weighed', () {
      final max = measuredMaxWeight([
        _rep(index: 0, averageWeight: 30, targetWeight: 30),
        _rep(index: 1, averageWeight: 34, targetWeight: 30),
        for (var index = 2; index < 4; index++)
          _rep(
            index: index,
            averageWeight: 0,
            targetWeight: 0,
            targetUnmeasured: true,
          ),
      ]);
      expect(max, 34);
    });

    test('leaves the rests out', () {
      final max = measuredMaxWeight([
        _rep(index: 0, averageWeight: 30, targetWeight: 30),
        _rep(index: 1, isRest: true, averageWeight: 0, targetWeight: 0),
      ]);
      expect(max, 30);
    });

    test('a run the sensor never measured at all states no load', () {
      // Every rep is stored at zero, so a max over them reads 0.0 kg, a load
      // the athlete never pulled beside a mean that is correctly absent.
      final max = measuredMaxWeight([
        for (var index = 0; index < 3; index++)
          _rep(
            index: index,
            averageWeight: 0,
            targetWeight: 0,
            targetUnmeasured: true,
          ),
      ]);
      expect(max, null);
    });

    test('a run nothing was ever meant to weigh states no load', () {
      final max = measuredMaxWeight([
        for (var index = 0; index < 3; index++)
          _rep(index: index, averageWeight: 0, targetWeight: 0),
      ]);
      expect(max, null);
    });

    test('keeps the zero a working sensor read against a target', () {
      final max = measuredMaxWeight([
        for (var index = 0; index < 2; index++)
          _rep(index: index, averageWeight: 0, targetWeight: 30),
      ]);
      // The athlete came off the board on every rep, which the sensor did read.
      expect(max, 0);
    });

    test('states a run read below zero as it was read', () {
      // A sensor tared under load reads a whole run below zero. Flooring the
      // max at 0 states the same load no rep pulled that this function exists
      // to stop stating, and the portal carries no floor either.
      final max = measuredMaxWeight([
        for (var index = 0; index < 2; index++)
          _rep(index: index, averageWeight: -0.4, targetWeight: 20),
      ]);
      expect(max, -0.4);
    });
  });

  group('repWeighed', () {
    test('a rep the sensor read states the load it read', () {
      expect(
        repWeighed(_rep(index: 0, averageWeight: 30, targetWeight: 30)),
        isTrue,
      );
    });

    test('a rep whose target a dropped sensor lost was weighed by nothing', () {
      expect(
        repWeighed(
          _rep(
            index: 0,
            averageWeight: 0,
            targetWeight: 0,
            targetUnmeasured: true,
          ),
        ),
        isFalse,
      );
    });

    test('a rep nothing was ever meant to weigh was weighed by nothing', () {
      // An exercise block records the reps it played and no load at all, so its
      // stored zero is the absence of a reading just as a lost target is.
      expect(
        repWeighed(_rep(index: 0, averageWeight: 0, targetWeight: 0)),
        isFalse,
      );
    });

    test('keeps the zero a working sensor read against a target', () {
      expect(
        repWeighed(_rep(index: 0, averageWeight: 0, targetWeight: 30)),
        isTrue,
      );
    });

    test('keeps a rep read below zero by a sensor tared under load', () {
      expect(
        repWeighed(_rep(index: 0, averageWeight: -0.4, targetWeight: 20)),
        isTrue,
      );
    });

    test('keeps a rep read below zero that prescribed no load', () {
      // The sensor answered, so the run was measured. Reading it as unweighed
      // would state that nothing measured a run that was.
      expect(
        repWeighed(_rep(index: 0, averageWeight: -0.4, targetWeight: 0)),
        isTrue,
      );
    });
  });

  group('unmeasuredNote', () {
    test('a fully measured run says nothing', () {
      expect(unmeasuredNote((onTarget: 2, total: 2, unmeasured: 0)), null);
    });

    test('names how many reps went unmeasured', () {
      expect(
        unmeasuredNote((onTarget: 2, total: 2, unmeasured: 4)),
        '4 unmeasured',
      );
    });
  });

  group('spansMultipleBlocks', () {
    RepBlock block(String label) =>
        RepBlock(label: label, reps: [_rep(index: 0)]);

    test('a session that named no block pools nothing', () {
      expect(spansMultipleBlocks(null), false);
    });

    test('one block is its own session, so nothing is pooled across it', () {
      expect(spansMultipleBlocks([block('a')]), false);
    });

    test('two blocks cannot be stated as one number', () {
      expect(spansMultipleBlocks([block('a'), block('b')]), true);
    });
  });
}

/// The review pass the post workout screen is built from: which steps it asks
/// about, what it says each one was asked for, and which numbers it offers to
/// answer with. The two have to agree, since a card stating a prescription it
/// gives no field for is worse than one that asks nothing.
void _reviewPassTests() {
  const pullUps = TrainingItem(
    id: 'pullup-1',
    type: TrainingItemType.exercise,
    position: 0,
    exerciseName: 'Pull up',
    repsIsMax: true,
  );

  const dips = TrainingItem(
    id: 'dip-1',
    type: TrainingItemType.exercise,
    position: 1,
    exerciseName: 'Dip',
    reps: 8,
  );

  const plank = TrainingItem(
    id: 'plank-1',
    type: TrainingItemType.exercise,
    position: 2,
    exerciseName: 'Plank',
    duration: 90,
  );

  const repeater = TrainingItem(
    id: 'repeater-1',
    type: TrainingItemType.repeater,
    position: 3,
    cycles: 6,
    reps: 6,
    worktimeSeconds: 7,
    restSeconds: 3,
  );

  const circuit = TrainingItem(
    id: 'circuit-1',
    type: TrainingItemType.circuit,
    position: 4,
    cycles: 4,
    items: [dips],
  );

  const emom = TrainingItem(
    id: 'emom-1',
    type: TrainingItemType.emom,
    position: 5,
    cycles: 10,
    intervalSeconds: 60,
    items: [pullUps],
  );

  group('prescribedSummary and reportableFields agree', () {
    test('an AMRAP names no count and is asked for one', () {
      expect(prescribedSummary(pullUps), 'as many reps as possible');
      final fields = reportableFields(pullUps);
      expect(fields.reps, isTrue);
      expect(fields.duration, isFalse);
    });

    test('a rep based exercise names its reps and is asked for reps', () {
      expect(prescribedSummary(dips), 'of 8 reps');
      expect(reportableFields(dips).reps, isTrue);
    });

    test('a timed exercise names its time and is asked for a time', () {
      expect(prescribedSummary(plank), 'of 1mn 30s');
      final fields = reportableFields(plank);
      expect(fields.duration, isTrue);
      // It counts no repetitions, so it is not asked for any.
      expect(fields.reps, isFalse);
    });

    // The case the review missed: the card used to read "Asked of 6 reps" over
    // a load and a time box and no rep box.
    test('a repeater names its hang and is asked for a hang', () {
      expect(prescribedSummary(repeater), 'of 7s hangs');
      final fields = reportableFields(repeater);
      expect(fields.duration, isTrue);
      expect(fields.load, isTrue);
      expect(fields.reps, isFalse);
    });

    test('a circuit names its rounds and is asked for rounds', () {
      expect(prescribedSummary(circuit), 'of 4 rounds');
      final fields = reportableFields(circuit);
      expect(fields.cycles, isTrue);
      expect(fields.reps, isFalse);
      expect(fields.load, isFalse);
    });

    test('an emom names its rounds and is asked for rounds', () {
      expect(prescribedSummary(emom), 'of 10 rounds');
      expect(reportableFields(emom).cycles, isTrue);
    });
  });

  // The review asks the athlete to report a load, so the card has to name the
  // one they were given or they are reporting against nothing.
  group('the asked line states the prescribed load', () {
    const loadedDip = TrainingItem(
      id: 'dip-1',
      type: TrainingItemType.exercise,
      position: 0,
      exerciseName: 'Dip',
      reps: 8,
      loads: [Load(value: 20, unit: 'kg')],
    );

    test('beside the reps it was prescribed with', () {
      expect(prescribedSummary(loadedDip), 'of 8 reps at 20 kg');
    });

    test('beside the hang of a repeater', () {
      const hangs = TrainingItem(
        id: 'r-1',
        type: TrainingItemType.repeater,
        position: 0,
        cycles: 4,
        reps: 6,
        worktimeSeconds: 7,
        loads: [Load(value: 25, unit: 'kg')],
      );
      expect(prescribedSummary(hangs), 'of 7s hangs at 25 kg');
    });

    test('beside an AMRAP, which names no count of its own', () {
      const loadedAmrap = TrainingItem(
        id: 'p-1',
        type: TrainingItemType.exercise,
        position: 0,
        repsIsMax: true,
        loads: [Load(value: 10, unit: 'kg')],
      );
      expect(
        prescribedSummary(loadedAmrap),
        'as many reps as possible at 10 kg',
      );
    });

    // A load that only becomes kilograms once an assessment has been done is
    // left unstated when nothing resolves it, for the reason a percentage rep
    // count is: the fallback is not the number the athlete was given.
    test('says nothing of a percentage load when nothing resolves it', () {
      const relativeLoad = TrainingItem(
        id: 'h-1',
        type: TrainingItemType.hangboardRep,
        position: 0,
        worktimeSeconds: 10,
        loads: [
          Load(
            value: 80,
            unit: percentAssessmentUnit,
            assessmentId: 'max-force',
            fallback: 30,
          ),
        ],
      );
      expect(prescribedSummary(relativeLoad), 'of 10s hangs');
    });

    test('says nothing extra for a step carrying no load', () {
      expect(prescribedSummary(dips), 'of 8 reps');
    });

    // A share of the athlete's weight becomes kilograms only once one is known,
    // and the number is what the review asks them to report against.
    test('resolves a bodyweight load once a weight is known', () {
      const bodyweightPullUp = TrainingItem(
        id: 'p-2',
        type: TrainingItemType.exercise,
        position: 0,
        reps: 5,
        loads: [Load(value: 80, unit: 'percent_bw')],
      );
      expect(
        prescribedSummary(bodyweightPullUp, AssessmentResults.none, 70),
        'of 5 reps at 80 %BW (56 kg)',
      );
      // With no weight known it still states what was prescribed, in the unit
      // it was prescribed in.
      expect(prescribedSummary(bodyweightPullUp), 'of 5 reps at 80 %BW');
    });

    // The percentage is what cannot be stated, not the load beside it.
    test('keeps the load of a percentage rep target', () {
      const relativeReps = TrainingItem(
        id: 'p-3',
        type: TrainingItemType.exercise,
        position: 0,
        reps: 5,
        loads: [Load(value: 20, unit: 'kg')],
        variableTargets: {
          'reps': VariableTarget(
            assessmentId: 'max-pullups',
            percent: 60,
            fallback: 5,
          ),
        },
      );
      expect(prescribedSummary(relativeReps), 'at 20 kg');
    });
  });

  group('sessionKeepsItemReports', () {
    // A report is stored against the prescription the session names, so a run
    // that names none has nowhere to put one. Every builtin is such a run.
    test('is false for a run that names no prescription', () {
      expect(sessionKeepsItemReports(), isFalse);
    });

    test('is true for a run played from a training', () {
      expect(sessionKeepsItemReports(trainingId: 't-1'), isTrue);
    });

    test('is true for a run played from a coach slot', () {
      expect(sessionKeepsItemReports(programSessionId: 'ps-1'), isTrue);
    });
  });

  group('holdsReportableWork', () {
    test('is true for a training holding work', () {
      expect(holdsReportableWork(const [dips]), isTrue);
    });

    // A group is a heading and a free item is the coach's own text, so a
    // training of nothing else owes the athlete no explanation.
    test('is false for a training of headings and notes alone', () {
      const group = TrainingItem(
        id: 'group-1',
        type: TrainingItemType.group,
        position: 0,
        groupTitle: 'Warm up',
      );
      const note = TrainingItem(
        id: 'free-1',
        type: TrainingItemType.free,
        position: 1,
        freeText: 'Stay loose',
      );
      expect(holdsReportableWork(const [group, note]), isFalse);
    });

    test('finds work nested inside a heading', () {
      const group = TrainingItem(
        id: 'group-1',
        type: TrainingItemType.group,
        position: 0,
        items: [dips],
      );
      expect(holdsReportableWork(const [group]), isTrue);
    });
  });

  group('isReportable', () {
    test('leaves out a group and a free note, which carry no work', () {
      const group = TrainingItem(
        id: 'group-1',
        type: TrainingItemType.group,
        position: 0,
        groupTitle: 'Warm up',
      );
      const note = TrainingItem(
        id: 'free-1',
        type: TrainingItemType.free,
        position: 1,
        freeText: 'Stay loose',
      );
      expect(isReportable(group), isFalse);
      expect(isReportable(note), isFalse);
      expect(isReportable(dips), isTrue);
    });

    // A line written against an item with no key at all is keyed to nothing,
    // can never be read back, and collides with every other nameless line of
    // the same session.
    test('leaves out an item with neither an id nor a key', () {
      const unsaved = TrainingItem(
        id: '',
        type: TrainingItemType.repeater,
        position: 0,
        worktimeSeconds: 7,
      );
      expect(isReportable(unsaved), isFalse);
    });

    // What #110 was about: a builtin's steps are generated rather than stored,
    // and used to be left out of the review pass for want of an id.
    test('takes a generated item, which is keyed without being stored', () {
      const generated = TrainingItem(
        id: '',
        stableKey: 'builtin:mvc:0',
        type: TrainingItemType.repeater,
        position: 0,
        worktimeSeconds: 7,
      );
      expect(isReportable(generated), isTrue);
      expect(generated.reportKey, 'builtin:mvc:0');
    });
  });

  // The plumbing that carries the athlete's own numbers into the review. A
  // coach may prescribe reps or a duration as a percentage of an assessment,
  // and the raw field then holds only the fallback, so reading it names a
  // target nobody was played.
  group('percent of assessment prescriptions', () {
    const maxPullUps = AssessmentDefinition(
      id: 'max-pullups',
      label: 'Max pull ups',
      unit: AssessmentUnit.repetitions,
    );
    final results = AssessmentResults(
      const {'max-pullups': AssessmentHandValues(right: 20)},
      definitions: const {'max-pullups': maxPullUps},
    );
    const relative = TrainingItem(
      id: 'pullup-1',
      type: TrainingItemType.exercise,
      position: 0,
      exerciseName: 'Pull up',
      reps: 5,
      variableTargets: {
        'reps': VariableTarget(
          assessmentId: 'max-pullups',
          percent: 60,
          fallback: 5,
        ),
      },
    );

    test('states the resolved number the run counted down from', () {
      // 60% of 20 is 12, which is what the athlete actually did.
      expect(prescribedSummary(relative, results), 'of 12 reps');
    });

    // The history card has no results to resolve against: the numbers the
    // athlete has now are not the ones the run was played against. Stating the
    // fallback there would show a miss against 12 as a rout against 5.
    test('says nothing rather than the fallback when nothing resolves it', () {
      expect(prescribedSummary(relative), isNull);
    });

    test('an item with no percentage is unaffected', () {
      expect(prescribedSummary(dips), 'of 8 reps');
      expect(prescribedSummary(dips, results), 'of 8 reps');
    });
  });

  group('reviewLines', () {
    test('walks the tree in prescription order, nested items included', () {
      final lines = reviewLines(const [emom, dips], const []);
      expect(lines.map((l) => l.item.id), ['emom-1', 'pullup-1', 'dip-1']);
      expect(lines.every((l) => l.occurrence == 0), isTrue);
    });

    test('gives an item one line per pass the run already recorded', () {
      final lines = reviewLines(
        const [pullUps],
        const [
          SessionItemResultModel(
            trainingItemId: 'pullup-1',
            occurrence: 2,
            reps: 15,
          ),
          SessionItemResultModel(
            trainingItemId: 'pullup-1',
            occurrence: 0,
            reps: 23,
          ),
        ],
      );

      // Ordered by pass, whatever order they arrived in.
      expect(lines.map((l) => l.occurrence), [0, 2]);
    });

    // The run inherits a block's rule down to its steps, and a group gets no
    // line of its own, so the line carries the rule in force rather than the
    // item's own field.
    test('carries the protocol of the block a step sits in', () {
      const block = TrainingItem(
        id: 'group-1',
        type: TrainingItemType.group,
        position: 0,
        groupTitle: 'Max hangs',
        protocol: 'To failure or 40s.',
        items: [
          TrainingItem(
            id: 'inherits-1',
            type: TrainingItemType.exercise,
            position: 0,
            reps: 8,
          ),
          TrainingItem(
            id: 'own-1',
            type: TrainingItemType.exercise,
            position: 1,
            reps: 8,
            protocol: 'Stop at 24 reps.',
          ),
        ],
      );

      final lines = reviewLines(const [block], const []);

      expect(lines.map((l) => l.item.id), ['inherits-1', 'own-1']);
      expect(lines[0].protocol, 'To failure or 40s.');
      expect(lines[1].protocol, 'Stop at 24 reps.');
    });

    test('carries no protocol where nothing above the step names one', () {
      final lines = reviewLines(const [dips], const []);
      expect(lines.single.protocol, isNull);
    });

    test('gives an item the run answered nothing for a single line', () {
      final lines = reviewLines(const [dips], const []);
      expect(lines, hasLength(1));
      expect(lines.single.occurrence, 0);
    });

    test('holds no line for a training of builtin items', () {
      const unsaved = TrainingItem(
        id: '',
        type: TrainingItemType.repeater,
        position: 0,
        worktimeSeconds: 7,
      );
      expect(reviewLines(const [unsaved], const []), isEmpty);
    });
  });
}
