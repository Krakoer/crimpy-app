import 'package:crimpy/models/training_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrainingItem.fromJson hand_positions', () {
    test('reads one grip array per hand', () {
      final item = TrainingItem.fromJson({
        'id': 'i1',
        'type': 'repeater',
        'position': 0,
        'hand_positions': [
          ['HC', 'FC'],
          ['OC', '3FD'],
        ],
      });
      expect(item.handPositions, [
        ['HC', 'FC'],
        ['OC', '3FD'],
      ]);
      expect(item.handPositionsPerHand, item.handPositions);
      expect(item.toJson()['hand_positions'], [
        ['HC', 'FC'],
        ['OC', '3FD'],
      ]);
    });

    // Items written before the format was unified carried a flat array.
    test('reads a flat array as the rows of a single hand', () {
      final item = TrainingItem.fromJson({
        'id': 'i2',
        'type': 'repeater',
        'position': 0,
        'hand_positions': ['halfCrimp', 'openHand'],
      });
      expect(item.handPositions, [
        ['halfCrimp', 'openHand'],
      ]);
      // It is written back in the shape every client now reads.
      expect(item.toJson()['hand_positions'], [
        ['halfCrimp', 'openHand'],
      ]);
    });

    test('an item without hand_positions has no grips at all', () {
      final item = TrainingItem.fromJson({
        'id': 'i3',
        'type': 'repeater',
        'position': 0,
      });
      expect(item.handPositionsPerHand, isEmpty);
      expect(item.toJson().containsKey('hand_positions'), isFalse);
    });
  });

  group('TrainingItem hand modes', () {
    TrainingItem itemWith(String hand) => TrainingItem.fromJson({
      'id': 'h1',
      'type': 'repeater',
      'position': 0,
      'hand': hand,
      'granularity': 'uniform',
      'loads': [
        {'unit': 'kg', 'value': 20},
      ],
    });

    // Both hands on the board cannot be measured by a single-hand sensor;
    // every other mode hangs one hand at a time and can.
    test('only the two-handed mode is outside the sensor', () {
      expect(itemWith(HangboardHand.both).usesSensor, isFalse);
      expect(itemWith(HangboardHand.alternate).usesSensor, isTrue);
      expect(itemWith(HangboardHand.split).usesSensor, isTrue);
      expect(itemWith(HangboardHand.left).usesSensor, isTrue);
      expect(itemWith(HangboardHand.right).usesSensor, isTrue);
    });

    // A hangboard_rep runs a single hang, so the expander gives it HandSide.both
    // for anything but an explicitly named hand. Offering the sensor there would
    // record nothing, so usesSensor has to agree with the expander.
    test('a hangboard rep only reaches the sensor on a named hand', () {
      TrainingItem hangboardRepWith(String hand) => TrainingItem.fromJson({
        'id': 'h2',
        'type': 'hangboard_rep',
        'position': 0,
        'hand': hand,
        'granularity': 'uniform',
        'loads': [
          {'unit': 'kg', 'value': 20},
        ],
      });

      expect(hangboardRepWith(HangboardHand.left).usesSensor, isTrue);
      expect(hangboardRepWith(HangboardHand.right).usesSensor, isTrue);
      expect(hangboardRepWith(HangboardHand.both).usesSensor, isFalse);
      expect(hangboardRepWith(HangboardHand.alternate).usesSensor, isFalse);
      expect(hangboardRepWith(HangboardHand.split).usesSensor, isFalse);
    });

    test('the granularity round-trips through toJson', () {
      final item = itemWith(HangboardHand.split);
      expect(item.granularity, HangboardGranularity.uniform);
      expect(item.toJson()['granularity'], 'uniform');
      expect(item.toJson()['hand'], 'split');
    });
  });

  group('TrainingItem.applyOverride', () {
    TrainingItem splitItem() => TrainingItem.fromJson({
      'id': 'o1',
      'type': 'repeater',
      'position': 0,
      'hand': 'split',
      'granularity': 'set',
      'cycles': 2,
      'reps': 2,
      'edge_sizes_mm': [20, 20, 14, 14],
      'hand_positions': [
        ['HC', 'FC', 'OC', '3FD'],
        ['OC', '3FD', 'HC', 'FC'],
      ],
      'loads': List.generate(4, (i) => {'unit': 'kg', 'value': i + 1}),
      'left_loads': List.generate(4, (i) => {'unit': 'kg', 'value': i + 10}),
    });

    test('an empty array leaves the base prescription alone', () {
      final overridden = splitItem().applyOverride({
        'edge_sizes_mm': <int>[],
        'loads': <Map<String, dynamic>>[],
        'hand_positions': <String>[],
      });

      expect(overridden.edgeSizesMm, [20, 20, 14, 14]);
      expect(overridden.loads, hasLength(4));
      expect(overridden.handPositions, [
        ['HC', 'FC', 'OC', '3FD'],
        ['OC', '3FD', 'HC', 'FC'],
      ]);
    });

    test('a populated array still replaces the base prescription', () {
      final overridden = splitItem().applyOverride({
        'edge_sizes_mm': [10],
      });

      expect(overridden.edgeSizesMm, [10]);
      expect(overridden.loads, hasLength(4));
    });

    test('the hand mode and granularity can be overridden', () {
      final overridden = splitItem().applyOverride({
        'hand': 'alternate',
        'granularity': 'rep',
      });

      expect(overridden.hand, HangboardHand.alternate);
      expect(overridden.granularity, HangboardGranularity.perRep);
    });
  });

  group('TrainingItem.fromJson comment', () {
    test('parses an optional coach comment', () {
      final item = TrainingItem.fromJson({
        'id': 'i3',
        'type': 'exercise',
        'position': 0,
        'comment': 'First rep in pronation, second in supination',
      });
      expect(item.comment, 'First rep in pronation, second in supination');
    });

    test('comment is null when absent and round-trips through toJson', () {
      final item = TrainingItem.fromJson({
        'id': 'i4',
        'type': 'exercise',
        'position': 0,
      });
      expect(item.comment, isNull);
      expect(item.toJson().containsKey('comment'), isFalse);

      final withComment = TrainingItem.fromJson({
        'id': 'i5',
        'type': 'exercise',
        'position': 0,
        'comment': 'Keep elbows tucked',
      });
      expect(withComment.toJson()['comment'], 'Keep elbows tucked');
    });
  });
}
