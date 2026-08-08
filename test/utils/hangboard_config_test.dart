import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/hangboard_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HangboardConfig row counts', () {
    test('the granularity decides how many rows are configured', () {
      final config = HangboardConfig.initial()..reshape(sets: 3, reps: 4);

      expect(config.rowCount, 1);

      config.reshape(granularity: HangboardGranularity.perRep);
      expect(config.rowCount, 4);

      config.reshape(granularity: HangboardGranularity.perSet);
      expect(config.rowCount, 12);
      expect(config.rowOf(2, 1), 9);
      expect(config.coordinateOf(9), (2, 1));
      expect(config.labelOf(9), 'Set 3 - Rep 2');
    });
  });

  group('HangboardConfig reshape', () {
    test('a uniform value fills every row it expands into', () {
      final config = HangboardConfig.initial()
        ..reshape(sets: 2, reps: 2)
        ..edgeSizesMm[0] = 18
        ..loads[0] = const Load(value: 40, unit: 'kg');

      config.reshape(granularity: HangboardGranularity.perSet);

      expect(config.edgeSizesMm, [18, 18, 18, 18]);
      expect(config.loads.map((l) => l.value), [40, 40, 40, 40]);
    });

    test('per-rep values are replayed into every set', () {
      final config = HangboardConfig.initial()
        ..reshape(sets: 2, reps: 2, granularity: HangboardGranularity.perRep);
      config.edgeSizesMm[0] = 20;
      config.edgeSizesMm[1] = 15;

      config.reshape(granularity: HangboardGranularity.perSet);

      expect(config.edgeSizesMm, [20, 15, 20, 15]);
    });

    test('narrowing to uniform keeps the first row', () {
      final config = HangboardConfig.initial()
        ..reshape(sets: 1, reps: 3, granularity: HangboardGranularity.perRep);
      config.edgeSizesMm[0] = 22;
      config.edgeSizesMm[2] = 10;

      config.reshape(granularity: HangboardGranularity.uniform);

      expect(config.edgeSizesMm, [22]);
    });

    // Growing the rep count must not drop what was already typed.
    test('adding a rep keeps the earlier rows', () {
      final config = HangboardConfig.initial()
        ..reshape(sets: 1, reps: 2, granularity: HangboardGranularity.perRep);
      config.edgeSizesMm[0] = 20;
      config.edgeSizesMm[1] = 15;

      config.reshape(reps: 3);

      expect(config.edgeSizesMm, [20, 15, 15]);
    });
  });

  group('HangboardConfig fillDown', () {
    test('a per-set fill stays inside its own set', () {
      final config = HangboardConfig.initial()
        ..reshape(sets: 2, reps: 2, granularity: HangboardGranularity.perSet);
      config.edgeSizesMm.setAll(0, [20, 18, 15, 12]);

      config.fillDown(0);

      expect(config.edgeSizesMm, [20, 20, 15, 12]);
    });

    test('a per-rep fill reaches every row below', () {
      final config = HangboardConfig.initial()
        ..reshape(sets: 1, reps: 3, granularity: HangboardGranularity.perRep);
      config.edgeSizesMm.setAll(0, [20, 18, 15]);

      config.fillDown(0);

      expect(config.edgeSizesMm, [20, 20, 20]);
    });
  });

  group('HangboardConfig toItem', () {
    TrainingItem build(HangboardConfig config) => config.toItem(
      id: '',
      position: 0,
      worktimeSeconds: 7,
      restSeconds: 3,
      cycleRestSeconds: 180,
    );

    test('a mode working the hands together writes one of everything', () {
      final config = HangboardConfig.initial()
        ..reshape(sets: 2, reps: 2, hand: HangboardHand.both);

      final item = build(config);

      expect(item.hand, HangboardHand.both);
      expect(item.granularity, HangboardGranularity.uniform);
      expect(item.loads, hasLength(1));
      expect(item.leftLoads, isNull);
      expect(item.handPositions, hasLength(1));
    });

    test('a split mode writes a load and a grip array per hand', () {
      final config = HangboardConfig.initial()
        ..reshape(
          sets: 2,
          reps: 2,
          hand: HangboardHand.split,
          granularity: HangboardGranularity.perRep,
        );
      config.loads.setAll(0, const [
        Load(value: 60, unit: 'kg'),
        Load(value: 65, unit: 'kg'),
      ]);
      config.leftLoads.setAll(0, const [
        Load(value: 50, unit: 'kg'),
        Load(value: 55, unit: 'kg'),
      ]);
      config.grips.setAll(0, ['fullCrimp', 'fullCrimp']);
      config.leftGrips.setAll(0, ['openHand', 'openHand']);

      final item = build(config);

      expect(item.loads!.map((l) => l.value), [60, 65]);
      expect(item.leftLoads!.map((l) => l.value), [50, 55]);
      // The left hand comes first in hand_positions.
      expect(item.handPositions, [
        ['openHand', 'openHand'],
        ['fullCrimp', 'fullCrimp'],
      ]);
    });

    test('every array holds exactly one entry per declared row', () {
      final config = HangboardConfig.initial()
        ..reshape(
          sets: 3,
          reps: 2,
          hand: HangboardHand.alternate,
          granularity: HangboardGranularity.perSet,
        );

      final item = build(config);

      expect(item.edgeSizesMm, hasLength(6));
      expect(item.loads, hasLength(6));
      expect(item.leftLoads, hasLength(6));
      expect(item.handPositions!.every((h) => h.length == 6), isTrue);
    });

    test('an item is max effort only when every load is', () {
      final config = HangboardConfig.initial()
        ..reshape(hand: HangboardHand.right);
      expect(build(config).loadIsMax, isFalse);

      config.loads[0] = const Load(value: 0, unit: 'max');
      expect(build(config).loadIsMax, isTrue);
    });
  });

  group('HangboardConfig.fromItem', () {
    test('reads a per-set split item back row by row', () {
      final item = TrainingItem.fromJson({
        'id': 'r',
        'type': 'repeater',
        'position': 0,
        'cycles': 2,
        'reps': 2,
        'hand': 'split',
        'granularity': 'set',
        'edge_sizes_mm': [20, 20, 15, 15],
        'loads': List.generate(4, (i) => {'value': 10 + i, 'unit': 'kg'}),
        'left_loads': List.generate(4, (i) => {'value': 20 + i, 'unit': 'kg'}),
        'hand_positions': [
          ['HC', 'HC', 'FC', 'FC'],
          ['OC', 'OC', '3FD', '3FD'],
        ],
      });

      final config = HangboardConfig.fromItem(item);

      expect(config.rowCount, 4);
      expect(config.edgeSizesMm, [20, 20, 15, 15]);
      expect(config.loads.map((l) => l.value), [10, 11, 12, 13]);
      expect(config.leftLoads.map((l) => l.value), [20, 21, 22, 23]);
      expect(config.grips, ['OC', 'OC', '3FD', '3FD']);
      expect(config.leftGrips, ['HC', 'HC', 'FC', 'FC']);
    });

    // Editing an item and saving it again must not change what it prescribes.
    test('an item survives a read and write round trip', () {
      final original = TrainingItem.fromJson({
        'id': 'r',
        'type': 'repeater',
        'position': 0,
        'cycles': 2,
        'reps': 3,
        'hand': 'alternate',
        'granularity': 'rep',
        'edge_sizes_mm': [20, 18, 15],
        'loads': List.generate(3, (i) => {'value': 30 + i, 'unit': 'kg'}),
        'left_loads': List.generate(3, (i) => {'value': 40 + i, 'unit': 'kg'}),
        'hand_positions': [
          ['HC', 'FC', 'OC'],
          ['OC', 'HC', 'FC'],
        ],
      });

      final rebuilt = HangboardConfig.fromItem(original).toItem(
        id: original.id,
        position: original.position,
        worktimeSeconds: 7,
        restSeconds: 3,
        cycleRestSeconds: 180,
      );

      expect(rebuilt.hand, original.hand);
      expect(rebuilt.granularity, original.granularity);
      expect(rebuilt.edgeSizesMm, original.edgeSizesMm);
      expect(
        rebuilt.loads!.map((l) => l.value),
        original.loads!.map((l) => l.value),
      );
      expect(
        rebuilt.leftLoads!.map((l) => l.value),
        original.leftLoads!.map((l) => l.value),
      );
      expect(rebuilt.handPositions, original.handPositions);
    });
  });
}
