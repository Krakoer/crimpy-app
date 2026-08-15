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
      expect(load.kilograms(bodyweightKg: 70), closeTo(56, 0.001));
      expect(load.kilograms(bodyweightKg: null), isNull);
    });

    test('kilograms do not depend on the bodyweight', () {
      expect(const Load(value: 35, unit: 'kg').needsBodyweight, isFalse);
      expect(
        const Load(value: 35, unit: 'kg').kilograms(bodyweightKg: null),
        35,
      );
    });

    test('a unit the app does not read gives no target', () {
      // Kilograms is the only absolute unit. Falling back to the bare number
      // would put "20" on the gauge for a load that does not mean 20 kg.
      for (final unit in const ['lbs', 'stone', '']) {
        final load = Load(value: 20, unit: unit);
        expect(
          load.kilograms(bodyweightKg: 70),
          isNull,
          reason: '$unit resolved a target',
        );
        expect(
          load.needsBodyweight,
          isFalse,
          reason: '$unit asked for a weight',
        );
      }
    });

    test('a max effort rep has no load', () {
      expect(
        const Load(value: 0, unit: 'max').kilograms(bodyweightKg: 70),
        isNull,
      );
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
      // A unit with no conversion still names itself rather than claiming a
      // kilogram figure the app cannot work out.
      expect(
        const Load(value: 20, unit: 'lbs').label(bodyweightKg: 70),
        '20 lbs',
      );
    });

    test('a plain bodyweight hang has no number to hit', () {
      // Reading these as a target would put the athlete bodyweight on the
      // gauge for a rep the coach set as an unloaded hang.
      for (final load in const [
        Load(value: 0, unit: 'bw'),
        Load(value: 0, unit: 'percent_bw'),
        Load(value: 0, unit: 'kg'),
      ]) {
        expect(
          load.kilograms(bodyweightKg: 70),
          isNull,
          reason: '$load resolved a target',
        );
        expect(load.label(bodyweightKg: 70), 'BW');
      }
    });

    test('every load resolved against the bodyweight also asks for one', () {
      // The two used to be listed separately, so a unit could resolve against
      // a bodyweight the athlete was never prompted for.
      for (final unit in const ['kg', 'percent_bw', 'bw', 'max', 'lbs']) {
        for (final value in const [0.0, 80.0]) {
          final load = Load(value: value, unit: unit);
          final resolvesAgainstBodyweight =
              load.kilograms(bodyweightKg: null) == null &&
              load.kilograms(bodyweightKg: 70) != null;
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

    test('is false for an exercise at 100 percent of the bodyweight', () {
      // The label is deliberately hidden for a plain set of pull ups, so
      // nothing would use the answer and the prompt would be unexplained.
      final item = TrainingItem(
        id: 'i',
        type: TrainingItemType.exercise,
        position: 0,
        loads: const [Load(value: 100, unit: 'percent_bw')],
      );
      expect(item.loadLabel(bodyweightKg: 70), isNull);
      expect(item.needsBodyweight, isFalse);
    });

    test('is true for an exercise loaded above the bodyweight', () {
      final item = TrainingItem(
        id: 'i',
        type: TrainingItemType.exercise,
        position: 0,
        loads: const [Load(value: 120, unit: 'percent_bw')],
      );
      expect(item.loadLabel(bodyweightKg: 70), '120 %BW (84 kg)');
      expect(item.needsBodyweight, isTrue);
    });

    test('a hangboard rep at 100 percent still asks, it hits the gauge', () {
      final item = TrainingItem(
        id: 'i',
        type: TrainingItemType.hangboardRep,
        position: 0,
        loads: const [Load(value: 100, unit: 'percent_bw')],
      );
      expect(item.needsBodyweight, isTrue);
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

  group('TrainingItem.copyWith group title', () {
    const group = TrainingItem(
      id: 'g',
      type: TrainingItemType.group,
      position: 0,
      groupTitle: 'Warm-up',
    );

    test('leaves the title alone when none is given', () {
      expect(group.copyWith(position: 3).groupTitle, 'Warm-up');
    });

    test('trims a new title and clears a blank one', () {
      expect(group.copyWith(groupTitle: '  Pull  ').groupTitle, 'Pull');
      expect(group.copyWith(groupTitle: '   ').groupTitle, isNull);
    });
  });

  group('TrainingItem.duplicate', () {
    test('drops the ids of the whole subtree and keeps everything else', () {
      const original = TrainingItem(
        id: 'c',
        type: TrainingItemType.circuit,
        position: 2,
        cycles: 3,
        cycleRestSeconds: 120,
        restSeconds: 15,
        groupTitle: 'Pull block',
        comment: 'Slow down',
        items: [
          TrainingItem(
            id: 'h',
            type: TrainingItemType.hangboardRep,
            position: 0,
            worktimeSeconds: 7,
            loads: [Load(value: 20, unit: 'kg')],
          ),
        ],
      );

      final copy = original.duplicate();

      expect(copy.id, isEmpty);
      expect(copy.items.single.id, isEmpty);
      expect(copy.cycles, 3);
      expect(copy.cycleRestSeconds, 120);
      expect(copy.restSeconds, 15);
      expect(copy.groupTitle, 'Pull block');
      expect(copy.comment, 'Slow down');
      expect(copy.items.single.worktimeSeconds, 7);
      expect(copy.items.single.loads?.single.value, 20);
      // The original is untouched, so duplicating never moves what it copied.
      expect(original.id, 'c');
      expect(original.items.single.id, 'h');
    });
  });
}
