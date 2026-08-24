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
}) => RepDataModel(
  averageWeight: averageWeight,
  duration: duration,
  index: index,
  isRest: isRest,
  handSide: hand,
  targetWeight: targetWeight,
  trainingItemId: itemId,
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
      expect(count, (onTarget: 1, total: 1));
    });

    test('a rep at 90% of its target counts, one below it does not', () {
      final count = onTargetCount([
        _rep(index: 0, averageWeight: 18, targetWeight: 20),
        _rep(index: 1, averageWeight: 17.9, targetWeight: 20),
      ]);
      expect(count, (onTarget: 1, total: 2));
    });

    test('a rep the training gave no target misses, once a target was set', () {
      final count = onTargetCount([
        _rep(index: 0, averageWeight: 20, targetWeight: 20),
        _rep(index: 1, averageWeight: 20, targetWeight: 0),
      ]);
      expect(count, (onTarget: 1, total: 2));
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
