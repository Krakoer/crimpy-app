import 'package:crimpy/models/training.dart';
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

  group('Load in kilograms', () {
    test('percent of bodyweight needs a bodyweight to resolve', () {
      const load = Load(value: 80, unit: 'percent_bw');
      expect(load.needsBodyweight, isTrue);
      expect(load.kilograms(70), closeTo(56, 0.001));
      expect(load.kilograms(null), isNull);
    });

    test('kilograms and pounds do not depend on the bodyweight', () {
      expect(const Load(value: 35, unit: 'kg').needsBodyweight, isFalse);
      expect(const Load(value: 35, unit: 'kg').kilograms(null), 35);
      expect(
        const Load(value: 10, unit: 'lbs').kilograms(null),
        closeTo(4.536, 0.001),
      );
    });

    test('a max effort rep has no load', () {
      expect(const Load(value: 0, unit: 'max').kilograms(70), isNull);
      expect(const Load(value: 0, unit: 'max').label(bodyweightKg: 70), 'MAX');
    });

    test('label adds what the gauge will ask for, in kilograms', () {
      expect(
        const Load(value: 80, unit: 'percent_bw').label(bodyweightKg: 70),
        '80 %BW (56 kg)',
      );
      expect(const Load(value: 80, unit: 'percent_bw').label(), '80 %BW');
      expect(
        const Load(value: 35, unit: 'kg').label(bodyweightKg: 70),
        '35 kg',
      );
      // The gauge prints kilograms whatever the coach set the load in, so a
      // pound load without the conversion left the two screens disagreeing.
      expect(const Load(value: 20, unit: 'lbs').label(), '20 lbs (9.1 kg)');
    });

    test('a plain bodyweight hang has no number to hit', () {
      // Reading these as a target would put the athlete bodyweight on the
      // gauge for a rep the coach set as an unloaded hang.
      for (final load in const [
        Load(value: 0, unit: 'bw'),
        Load(value: 0, unit: 'percent_bw'),
        Load(value: 0, unit: 'kg'),
      ]) {
        expect(load.kilograms(70), isNull, reason: '$load resolved a target');
        expect(load.label(bodyweightKg: 70), 'BW');
      }
    });

    test('every load resolved against the bodyweight also asks for one', () {
      // The two used to be listed separately, so a unit could resolve against
      // a bodyweight the athlete was never prompted for.
      for (final unit in const ['kg', 'lbs', 'percent_bw', 'bw', 'max']) {
        for (final value in const [0.0, 80.0]) {
          final load = Load(value: value, unit: unit);
          final resolvesAgainstBodyweight =
              load.kilograms(null) == null && load.kilograms(70) != null;
          expect(
            load.needsBodyweight,
            resolvesAgainstBodyweight,
            reason: '$value $unit disagrees',
          );
        }
      }
    });
  });

  group('TrainingItem.needsBodyweight', () {
    test('is true when any rep is loaded in percent of the bodyweight', () {
      final item = TrainingItem(
        id: 'i',
        type: TrainingItemType.repeater,
        position: 0,
        loads: const [Load(value: 35, unit: 'kg')],
        leftLoads: const [Load(value: 80, unit: 'percent_bw')],
      );
      expect(item.needsBodyweight, isTrue);
    });

    test('is false for absolute loads', () {
      final item = TrainingItem(
        id: 'i',
        type: TrainingItemType.hangboardRep,
        position: 0,
        loads: const [Load(value: 35, unit: 'kg')],
      );
      expect(item.needsBodyweight, isFalse);
    });
  });

  group('Training.needsBodyweight', () {
    TrainingItem percentBwRep() => TrainingItem(
      id: 'rep',
      type: TrainingItemType.hangboardRep,
      position: 0,
      loads: const [Load(value: 80, unit: 'percent_bw')],
    );

    test('finds a percent of bodyweight load nested in a group', () {
      // Coaches wrap hangboard work in groups and circuits, so a prompt that
      // only looked at the top level never fired for a real program.
      final training = Training(
        id: 't',
        title: 'Nested',
        items: [
          TrainingItem(
            id: 'group',
            type: TrainingItemType.group,
            position: 0,
            items: [
              TrainingItem(
                id: 'circuit',
                type: TrainingItemType.circuit,
                position: 0,
                items: [percentBwRep()],
              ),
            ],
          ),
        ],
      );
      expect(training.needsBodyweight, isTrue);
    });

    test('is false for a training with only absolute loads', () {
      final training = Training(
        id: 't',
        title: 'Absolute',
        items: [
          TrainingItem(
            id: 'group',
            type: TrainingItemType.group,
            position: 0,
            items: [
              TrainingItem(
                id: 'rep',
                type: TrainingItemType.hangboardRep,
                position: 0,
                loads: const [Load(value: 35, unit: 'kg')],
              ),
            ],
          ),
        ],
      );
      expect(training.needsBodyweight, isFalse);
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
