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
      final reps = [
        _rep(index: 0, itemId: 'a'),
        _rep(index: 1, itemId: 'a', hand: HandSide.left),
        _rep(index: 2, itemId: 'a'),
        _rep(index: 3, itemId: 'a', hand: HandSide.left),
        _rep(index: 4, itemId: 'a', isRest: true, duration: 120),
        _rep(index: 5, itemId: 'a'),
        _rep(index: 6, itemId: 'a', hand: HandSide.left),
        _rep(index: 7, itemId: 'a'),
        _rep(index: 8, itemId: 'a', hand: HandSide.left),
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
}
