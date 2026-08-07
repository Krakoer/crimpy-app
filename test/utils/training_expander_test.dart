import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/utils/training_expander.dart';
import 'package:flutter_test/flutter_test.dart';

Training _training(List<TrainingItem> items) =>
    Training(id: 't', title: 'T', items: items);

void main() {
  test('circuit repeats children with cycle rest between cycles', () {
    final training = _training([
      TrainingItem(
        id: 'c',
        type: TrainingItemType.circuit,
        position: 0,
        cycles: 2,
        cycleRestSeconds: 60,
        items: [
          TrainingItem(
            id: 'e1',
            type: TrainingItemType.exercise,
            position: 0,
            reps: 10,
          ),
          TrainingItem(
            id: 'e2',
            type: TrainingItemType.exercise,
            position: 1,
            duration: 30,
          ),
        ],
      ),
    ]);

    final out = expandTrainingItems(training, useSensor: false);

    expect(out.map((e) => e.runtimeType).toList(), [
      ConfirmItem, // cycle 1, reps exercise
      TimedItem, // cycle 1, duration exercise
      RestItem, // cycle rest
      ConfirmItem, // cycle 2
      TimedItem,
    ]);
    expect((out[0] as ConfirmItem).reps, 10);
    expect((out[1] as TimedItem).durationSeconds, 30);
    expect((out[2] as RestItem).durationSeconds, 60);
    // Round context per cycle.
    expect((out[0] as ConfirmItem).subtitle, 'ROUND 1/2');
    expect((out[3] as ConfirmItem).subtitle, 'ROUND 2/2');
  });

  test('repeater hangs carry set/rep context', () {
    final training = _training([
      TrainingItem(
        id: 'r',
        type: TrainingItemType.repeater,
        position: 0,
        cycles: 2,
        reps: 3,
        hand: 'right',
        worktimeSeconds: 7,
        restSeconds: 3,
      ),
    ]);

    final out = expandTrainingItems(
      training,
      useSensor: false,
    ).whereType<TimedItem>().toList();
    expect(out.first.subtitle, 'SET 1/2 - REP 1/3');
    expect(out.last.subtitle, 'SET 2/2 - REP 3/3');
  });

  test('section flattens its children', () {
    final training = _training([
      TrainingItem(
        id: 's',
        type: TrainingItemType.group,
        position: 0,
        groupTitle: 'Warmup',
        items: [
          TrainingItem(
            id: 'e1',
            type: TrainingItemType.exercise,
            position: 0,
            duration: 20,
          ),
        ],
      ),
    ]);

    final out = expandTrainingItems(training, useSensor: false);
    expect(out, hasLength(1));
    expect(out.first, isA<TimedItem>());
  });

  test('hangboard collects sensor data only when useSensor is true', () {
    final hb = TrainingItem(
      id: 'h',
      type: TrainingItemType.hangboardRep,
      position: 0,
      hand: 'right',
      worktimeSeconds: 7,
      restSeconds: 3,
      loads: const [Load(value: 35, unit: 'kg')],
    );

    final withSensor = expandTrainingItems(_training([hb]), useSensor: true);
    expect((withSensor.first as TimedItem).collectSensorData, isTrue);

    final without = expandTrainingItems(_training([hb]), useSensor: false);
    expect((without.first as TimedItem).collectSensorData, isFalse);
  });

  test('exercise comment propagates to the execution item', () {
    final repsExercise = TrainingItem(
      id: 'e1',
      type: TrainingItemType.exercise,
      position: 0,
      reps: 8,
      comment: 'First rep in pronation, second in supination',
    );
    final timedExercise = TrainingItem(
      id: 'e2',
      type: TrainingItemType.exercise,
      position: 1,
      duration: 30,
      comment: 'Keep hips level',
    );

    final out = expandTrainingItems(
      _training([repsExercise, timedExercise]),
      useSensor: false,
    );

    expect(
      (out[0] as ConfirmItem).comment,
      'First rep in pronation, second in supination',
    );
    expect((out[1] as TimedItem).comment, 'Keep hips level');
  });

  test('hangboard and repeater hangs carry their comment', () {
    final training = _training([
      TrainingItem(
        id: 'h',
        type: TrainingItemType.hangboardRep,
        position: 0,
        hand: 'right',
        comment: 'Shoulders engaged',
      ),
      TrainingItem(
        id: 'r',
        type: TrainingItemType.repeater,
        position: 1,
        cycles: 1,
        reps: 2,
        hand: 'split',
        comment: 'Stop at the first slip',
      ),
    ]);

    final out = expandTrainingItems(
      training,
      useSensor: false,
    ).whereType<TimedItem>().toList();

    expect(out.first.comment, 'Shoulders engaged');
    expect(
      out.skip(1).every((item) => item.comment == 'Stop at the first slip'),
      isTrue,
    );
  });

  test('circuit comment applies to children without their own', () {
    final training = _training([
      TrainingItem(
        id: 'c',
        type: TrainingItemType.circuit,
        position: 0,
        cycles: 1,
        comment: 'Alternate sides each round',
        items: [
          TrainingItem(
            id: 'e1',
            type: TrainingItemType.exercise,
            position: 0,
            duration: 35,
          ),
          TrainingItem(
            id: 'e2',
            type: TrainingItemType.exercise,
            position: 1,
            duration: 35,
            comment: 'Right leg',
          ),
        ],
      ),
    ]);

    final out = expandTrainingItems(
      training,
      useSensor: false,
    ).whereType<TimedItem>().toList();

    expect(out[0].comment, 'Alternate sides each round');
    expect(out[1].comment, 'Right leg');
  });

  test('group comment reaches children nested in a circuit', () {
    final training = _training([
      TrainingItem(
        id: 'c',
        type: TrainingItemType.circuit,
        position: 0,
        cycles: 1,
        comment: 'Circuit note',
        items: [
          TrainingItem(
            id: 'g',
            type: TrainingItemType.group,
            position: 0,
            groupTitle: 'Left side',
            comment: 'Group note',
            items: [
              TrainingItem(
                id: 'e1',
                type: TrainingItemType.exercise,
                position: 0,
                duration: 20,
              ),
              TrainingItem(
                id: 'e2',
                type: TrainingItemType.exercise,
                position: 1,
                duration: 20,
                comment: 'Own note',
              ),
            ],
          ),
        ],
      ),
    ]);

    final out = expandTrainingItems(
      training,
      useSensor: false,
    ).whereType<TimedItem>().toList();

    // The closest enclosing comment wins, and an item with one of its own keeps
    // it rather than inheriting.
    expect(out[0].comment, 'Group note');
    expect(out[1].comment, 'Own note');
  });

  test('a comment is trimmed before it is carried', () {
    final training = _training([
      TrainingItem(
        id: 'e1',
        type: TrainingItemType.exercise,
        position: 0,
        duration: 20,
        comment: '\n  Right leg  ',
      ),
    ]);

    final out = expandTrainingItems(training, useSensor: false);

    expect((out.first as TimedItem).comment, 'Right leg');
  });

  test('blank comment does not shadow the enclosing one', () {
    final training = _training([
      TrainingItem(
        id: 'c',
        type: TrainingItemType.circuit,
        position: 0,
        cycles: 1,
        comment: 'Slow tempo',
        items: [
          TrainingItem(
            id: 'e1',
            type: TrainingItemType.exercise,
            position: 0,
            duration: 20,
            comment: '   ',
          ),
        ],
      ),
    ]);

    final out = expandTrainingItems(training, useSensor: false);

    expect((out.first as TimedItem).comment, 'Slow tempo');
  });

  test('split hand repeater never emits a negative rest', () {
    // A cycle rest shorter than one hand's set leaves nothing to split.
    final training = _training([
      TrainingItem(
        id: 'r',
        type: TrainingItemType.repeater,
        position: 0,
        cycles: 2,
        reps: 6,
        worktimeSeconds: 7,
        restSeconds: 3,
        cycleRestSeconds: 30,
        hand: 'split',
      ),
    ]);

    final out = expandTrainingItems(training, useSensor: false);

    expect(out.whereType<RestItem>().every((r) => r.durationSeconds > 0), true);
  });

  group('hangboard granularity', () {
    List<TimedItem> hangs(Map<String, dynamic> itemJson) => expandTrainingItems(
      _training([TrainingItem.fromJson(itemJson)]),
      useSensor: false,
    ).whereType<TimedItem>().toList();

    Map<String, dynamic> load(double value) => {'value': value, 'unit': 'kg'};

    Map<String, dynamic> repeater({
      required int cycles,
      required int reps,
      required String hand,
      List<int>? edges,
      List<Map<String, dynamic>>? loads,
      List<Map<String, dynamic>>? leftLoads,
      dynamic handPositions,
    }) => {
      'id': 'r',
      'type': 'repeater',
      'position': 0,
      'cycles': cycles,
      'reps': reps,
      'hand': hand,
      'worktime_seconds': 7,
      'rest_seconds': 3,
      if (edges != null) 'edge_sizes_mm': edges,
      if (loads != null) 'loads': loads,
      if (leftLoads != null) 'left_loads': leftLoads,
      if (handPositions != null) 'hand_positions': handPositions,
    };

    test('uniform config applies to every set and rep', () {
      final out = hangs(
        repeater(
          cycles: 2,
          reps: 2,
          hand: 'both',
          edges: [20],
          loads: [load(30)],
          handPositions: [
            ['FC'],
          ],
        ),
      );

      expect(out.map((h) => h.targetLoad).toSet(), {30.0});
      expect(out.map((h) => h.edgeSizeMm).toSet(), {20});
      expect(out.map((h) => h.gripPosition).toSet(), {GripPosition.fullCrimp});
    });

    test('per-rep config replays the same values in every set', () {
      final out = hangs(
        repeater(
          cycles: 2,
          reps: 3,
          hand: 'right',
          edges: [20, 18, 15],
          loads: [load(10), load(20), load(30)],
          handPositions: [
            ['HC', 'FC', 'OC'],
          ],
        ),
      );

      // A non-split repeater hangs each hand in turn, so one row per rep is
      // read twice; the right-hand hangs alone show the progression.
      final right = out.where((h) => h.handSide == HandSide.right).toList();
      expect(right.map((h) => h.targetLoad).toList(), [
        10.0,
        20.0,
        30.0,
        10.0,
        20.0,
        30.0,
      ]);
      expect(right.map((h) => h.edgeSizeMm).toList(), [20, 18, 15, 20, 18, 15]);
      expect(right.map((h) => h.gripPosition).take(3).toList(), [
        GripPosition.halfCrimp,
        GripPosition.fullCrimp,
        GripPosition.openHand,
      ]);
    });

    test('per-set config gives each set its own values', () {
      final out = hangs(
        repeater(
          cycles: 3,
          reps: 2,
          hand: 'right',
          // sets x reps entries, indexed set * reps + rep.
          edges: [20, 20, 18, 18, 15, 15],
          loads: [load(60), load(60), load(70), load(70), load(80), load(80)],
          handPositions: [
            ['HC', 'HC', 'FC', 'FC', 'OC', 'OC'],
          ],
        ),
      );

      // The regression this card fixes: set 2 and 3 used to replay set 1.
      final right = out.where((h) => h.handSide == HandSide.right).toList();
      expect(right.map((h) => h.targetLoad).toList(), [
        60.0,
        60.0,
        70.0,
        70.0,
        80.0,
        80.0,
      ]);
      expect(right.map((h) => h.edgeSizeMm).toList(), [20, 20, 18, 18, 15, 15]);
      expect(right.map((h) => h.gripPosition).toList(), [
        GripPosition.halfCrimp,
        GripPosition.halfCrimp,
        GripPosition.fullCrimp,
        GripPosition.fullCrimp,
        GripPosition.openHand,
        GripPosition.openHand,
      ]);
    });

    test('both hands share the row of their rep', () {
      final out = hangs(
        repeater(
          cycles: 2,
          reps: 1,
          hand: 'both',
          edges: [20, 15],
          loads: [load(40), load(50)],
          handPositions: [
            ['HC', 'OC'],
          ],
        ),
      );

      // Right then left for each rep, both on the same configuration row.
      expect(out.map((h) => h.handSide).toList(), [
        HandSide.right,
        HandSide.left,
        HandSide.right,
        HandSide.left,
      ]);
      expect(out.map((h) => h.targetLoad).toList(), [40.0, 40.0, 50.0, 50.0]);
      expect(out.map((h) => h.edgeSizeMm).toList(), [20, 20, 15, 15]);
    });

    test('split per-set reads the interleaved portal loads and grips', () {
      final out = hangs(
        repeater(
          cycles: 2,
          reps: 2,
          hand: 'split',
          edges: [20, 20, 15, 15],
          // Left at 2 * row, right at 2 * row + 1.
          loads: [
            load(1),
            load(2),
            load(3),
            load(4),
            load(5),
            load(6),
            load(7),
            load(8),
          ],
          handPositions: [
            ['HC', 'HC', 'FC', 'FC'],
            ['OC', 'OC', '3FD', '3FD'],
          ],
        ),
      );

      final right = out.where((h) => h.handSide == HandSide.right).toList();
      final left = out.where((h) => h.handSide == HandSide.left).toList();
      expect(right.map((h) => h.targetLoad).toList(), [2.0, 4.0, 6.0, 8.0]);
      expect(left.map((h) => h.targetLoad).toList(), [1.0, 3.0, 5.0, 7.0]);
      // hand_positions holds the left hand first.
      expect(right.first.gripPosition, GripPosition.openHand);
      expect(left.first.gripPosition, GripPosition.halfCrimp);
      expect(right.map((h) => h.edgeSizeMm).toList(), [20, 20, 15, 15]);
    });

    test('split per-rep is not mistaken for per-set when 2 sets collide', () {
      // With 2 sets, an interleaved per-rep loads array and a per-set one both
      // hold sets x reps entries; only the per-hand split tells them apart.
      final out = hangs(
        repeater(
          cycles: 2,
          reps: 2,
          hand: 'split',
          edges: [20, 15],
          loads: [load(1), load(2), load(3), load(4)],
          handPositions: [
            ['HC', 'FC'],
            ['OC', '3FD'],
          ],
        ),
      );

      final right = out.where((h) => h.handSide == HandSide.right).toList();
      final left = out.where((h) => h.handSide == HandSide.left).toList();
      // Both sets replay the same two rows.
      expect(right.map((h) => h.targetLoad).toList(), [2.0, 4.0, 2.0, 4.0]);
      expect(left.map((h) => h.targetLoad).toList(), [1.0, 3.0, 1.0, 3.0]);
      expect(right.map((h) => h.edgeSizeMm).toList(), [20, 15, 20, 15]);
      expect(right.map((h) => h.gripPosition).toList(), [
        GripPosition.openHand,
        GripPosition.threeFinger,
        GripPosition.openHand,
        GripPosition.threeFinger,
      ]);
    });

    test('left_loads wins over the interleaved layout when present', () {
      final out = hangs(
        repeater(
          cycles: 2,
          reps: 1,
          hand: 'split',
          edges: [20, 15],
          loads: [load(60), load(70)],
          leftLoads: [load(50), load(55)],
          handPositions: [
            ['HC', 'HC'],
          ],
        ),
      );

      final right = out.where((h) => h.handSide == HandSide.right).toList();
      final left = out.where((h) => h.handSide == HandSide.left).toList();
      expect(right.map((h) => h.targetLoad).toList(), [60.0, 70.0]);
      expect(left.map((h) => h.targetLoad).toList(), [50.0, 55.0]);
    });

    test('app-created item without edge sizes keeps its per-rep loads', () {
      final training = _training([
        TrainingItem(
          id: 'r',
          type: TrainingItemType.repeater,
          position: 0,
          cycles: 2,
          reps: 3,
          hand: 'right',
          worktimeSeconds: 7,
          restSeconds: 3,
          loads: const [
            Load(value: 10, unit: 'kg'),
            Load(value: 20, unit: 'kg'),
            Load(value: 30, unit: 'kg'),
          ],
          handPositions: const ['openHand', 'openHand', 'openHand'],
        ),
      ]);

      final out = expandTrainingItems(
        training,
        useSensor: false,
      ).whereType<TimedItem>().toList();

      final right = out.where((h) => h.handSide == HandSide.right).toList();
      expect(right.map((h) => h.targetLoad).toList(), [
        10.0,
        20.0,
        30.0,
        10.0,
        20.0,
        30.0,
      ]);
      expect(out.map((h) => h.edgeSizeMm).toSet(), {null});
      expect(out.map((h) => h.gripPosition).toSet(), {GripPosition.openHand});
    });

    test('app-created split item keeps left_loads and a flat grip list', () {
      final training = _training([
        TrainingItem(
          id: 'r',
          type: TrainingItemType.repeater,
          position: 0,
          cycles: 1,
          reps: 2,
          hand: 'split',
          worktimeSeconds: 7,
          restSeconds: 3,
          loads: const [
            Load(value: 60, unit: 'kg'),
            Load(value: 65, unit: 'kg'),
          ],
          leftLoads: const [
            Load(value: 50, unit: 'kg'),
            Load(value: 55, unit: 'kg'),
          ],
          handPositions: const ['halfCrimp', 'halfCrimp'],
        ),
      ]);

      final out = expandTrainingItems(
        training,
        useSensor: false,
      ).whereType<TimedItem>().toList();

      final right = out.where((h) => h.handSide == HandSide.right).toList();
      final left = out.where((h) => h.handSide == HandSide.left).toList();
      expect(right.map((h) => h.targetLoad).toList(), [60.0, 65.0]);
      expect(left.map((h) => h.targetLoad).toList(), [50.0, 55.0]);
      expect(out.map((h) => h.gripPosition).toSet(), {GripPosition.halfCrimp});
    });

    test('hangboard rep reads its single configuration row', () {
      final out = expandTrainingItems(
        _training([
          TrainingItem.fromJson({
            'id': 'h',
            'type': 'hangboard_rep',
            'position': 0,
            'hand': 'right',
            'worktime_seconds': 10,
            'rest_seconds': 5,
            'edge_sizes_mm': [12],
            'loads': [load(25)],
            'hand_positions': [
              ['3FD'],
            ],
          }),
        ]),
        useSensor: false,
      ).whereType<TimedItem>().toList();

      expect(out.single.targetLoad, 25.0);
      expect(out.single.edgeSizeMm, 12);
      expect(out.single.gripPosition, GripPosition.threeFinger);
    });
  });
}
