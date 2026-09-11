import 'package:crimpy/models/assessment_model.dart';
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

  test('circuit rests between its children but not after the last one', () {
    final training = _training([
      TrainingItem(
        id: 'c',
        type: TrainingItemType.circuit,
        position: 0,
        cycles: 2,
        cycleRestSeconds: 60,
        restSeconds: 15,
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
            reps: 10,
          ),
        ],
      ),
    ]);

    final out = expandTrainingItems(training, useSensor: false);

    expect(out.map((e) => e.runtimeType).toList(), [
      ConfirmItem,
      RestItem, // between the two children
      ConfirmItem,
      RestItem, // cycle rest, the last child is not followed by an item rest
      ConfirmItem,
      RestItem,
      ConfirmItem,
    ]);
    expect((out[1] as RestItem).durationSeconds, 15);
    expect((out[3] as RestItem).durationSeconds, 60);
  });

  // The shape the manual editor builds: hang reps carry a rest of their own, so
  // this is where a circuit rest could end up running twice over.
  test('a circuit rest replaces the rest its hang reps carry', () {
    TrainingItem rep(String id, int position) => TrainingItem(
      id: id,
      type: TrainingItemType.hangboardRep,
      position: position,
      worktimeSeconds: 7,
      restSeconds: 3,
      hand: HangboardHand.both,
    );

    final training = _training([
      TrainingItem(
        id: 'c',
        type: TrainingItemType.circuit,
        position: 0,
        cycles: 2,
        cycleRestSeconds: 120,
        restSeconds: 15,
        items: [rep('h1', 0), rep('h2', 1)],
      ),
    ]);

    final out = expandTrainingItems(training, useSensor: false);

    expect(out.map((e) => e.runtimeType).toList(), [
      TimedItem,
      RestItem,
      TimedItem,
      RestItem,
      TimedItem,
      RestItem,
      TimedItem,
      RestItem,
    ]);
    // 15s between items and 120s between cycles, not 3 + 15 and 3 + 120.
    expect((out[1] as RestItem).durationSeconds, 15);
    expect((out[3] as RestItem).durationSeconds, 120);
    expect((out[5] as RestItem).durationSeconds, 15);
    // Nothing follows the last cycle, so the last rep keeps its own rest.
    expect((out[7] as RestItem).durationSeconds, 3);
  });

  test('hang reps in a circuit carry the round context', () {
    final training = _training([
      TrainingItem(
        id: 'c',
        type: TrainingItemType.circuit,
        position: 0,
        cycles: 3,
        cycleRestSeconds: 60,
        items: [
          TrainingItem(
            id: 'h1',
            type: TrainingItemType.hangboardRep,
            position: 0,
            worktimeSeconds: 7,
            restSeconds: 3,
            hand: HangboardHand.both,
          ),
        ],
      ),
    ]);

    final hangs = expandTrainingItems(
      training,
      useSensor: false,
    ).whereType<TimedItem>().toList();

    expect(hangs.map((h) => h.subtitle).toList(), [
      'ROUND 1/3',
      'ROUND 2/3',
      'ROUND 3/3',
    ]);
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

  test('percent of bodyweight loads become kilograms', () {
    final training = _training([
      TrainingItem(
        id: 'h',
        type: TrainingItemType.hangboardRep,
        position: 0,
        hand: 'right',
        loads: const [Load(value: 80, unit: 'percent_bw')],
      ),
      TrainingItem(
        id: 'r',
        type: TrainingItemType.repeater,
        position: 1,
        cycles: 1,
        reps: 1,
        hand: 'split',
        loads: const [Load(value: 50, unit: 'percent_bw')],
        leftLoads: const [Load(value: 40, unit: 'percent_bw')],
      ),
    ]);

    final out = expandTrainingItems(
      training,
      useSensor: false,
      bodyweightKg: 70,
    ).whereType<TimedItem>().toList();

    expect(out[0].targetLoad, closeTo(56, 0.001));
    expect(out[1].targetLoad, closeTo(35, 0.001));
    expect(out[2].targetLoad, closeTo(28, 0.001));
  });

  test('percent of bodyweight loads have no target without a bodyweight', () {
    final training = _training([
      TrainingItem(
        id: 'h',
        type: TrainingItemType.hangboardRep,
        position: 0,
        hand: 'right',
        loads: const [Load(value: 80, unit: 'percent_bw')],
      ),
    ]);

    final out = expandTrainingItems(training, useSensor: false);

    expect((out.first as TimedItem).targetLoad, 0);
  });

  test('exercise load label shows the resolved kilograms', () {
    final training = _training([
      TrainingItem(
        id: 'e',
        type: TrainingItemType.exercise,
        position: 0,
        reps: 8,
        loads: const [Load(value: 30, unit: 'percent_bw')],
      ),
    ]);

    final out = expandTrainingItems(
      training,
      useSensor: false,
      bodyweightKg: 60,
    );

    expect((out.first as ConfirmItem).load, '30 %BW (18 kg)');
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

  group('hangboard layout', () {
    List<TimedItem> hangs(Map<String, dynamic> itemJson) => expandTrainingItems(
      _training([TrainingItem.fromJson(itemJson)]),
      useSensor: false,
    ).whereType<TimedItem>().toList();

    Map<String, dynamic> load(double value) => {'value': value, 'unit': 'kg'};

    Map<String, dynamic> repeater({
      required int cycles,
      required int reps,
      required String hand,
      required String granularity,
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
      'granularity': granularity,
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
          hand: HangboardHand.both,
          granularity: HangboardGranularity.uniform,
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
          hand: HangboardHand.right,
          granularity: HangboardGranularity.perRep,
          edges: [20, 18, 15],
          loads: [load(10), load(20), load(30)],
          handPositions: [
            ['HC', 'FC', 'OC'],
          ],
        ),
      );

      expect(out.map((h) => h.targetLoad).toList(), [
        10.0,
        20.0,
        30.0,
        10.0,
        20.0,
        30.0,
      ]);
      expect(out.map((h) => h.edgeSizeMm).toList(), [20, 18, 15, 20, 18, 15]);
      expect(out.map((h) => h.gripPosition).take(3).toList(), [
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
          hand: HangboardHand.right,
          granularity: HangboardGranularity.perSet,
          edges: [20, 20, 18, 18, 15, 15],
          loads: [load(60), load(60), load(70), load(70), load(80), load(80)],
          handPositions: [
            ['HC', 'HC', 'FC', 'FC', 'OC', 'OC'],
          ],
        ),
      );

      expect(out.map((h) => h.targetLoad).toList(), [
        60.0,
        60.0,
        70.0,
        70.0,
        80.0,
        80.0,
      ]);
      expect(out.map((h) => h.edgeSizeMm).toList(), [20, 20, 18, 18, 15, 15]);
      expect(out.map((h) => h.gripPosition).toList(), [
        GripPosition.halfCrimp,
        GripPosition.halfCrimp,
        GripPosition.fullCrimp,
        GripPosition.fullCrimp,
        GripPosition.openHand,
        GripPosition.openHand,
      ]);
    });

    // The classical fixed hangboard: one hang per rep with both hands on the
    // board, which no single-hand sensor can measure.
    test('both hands hang together once per rep', () {
      final out = hangs(
        repeater(
          cycles: 2,
          reps: 2,
          hand: HangboardHand.both,
          granularity: HangboardGranularity.perSet,
          edges: [20, 20, 15, 15],
          loads: [load(40), load(41), load(50), load(51)],
          handPositions: [
            ['HC', 'HC', 'OC', 'OC'],
          ],
        ),
      );

      expect(out.map((h) => h.handSide).toList(), [
        HandSide.both,
        HandSide.both,
        HandSide.both,
        HandSide.both,
      ]);
      expect(out.map((h) => h.targetLoad).toList(), [40.0, 41.0, 50.0, 51.0]);
      expect(out.map((h) => h.label).toSet(), {'Hang'});
    });

    // The "Max force" shape: right then left inside every rep.
    test('alternate hangs each hand in turn within a rep', () {
      final out = hangs(
        repeater(
          cycles: 2,
          reps: 1,
          hand: HangboardHand.alternate,
          granularity: HangboardGranularity.perSet,
          edges: [20, 15],
          loads: [load(40), load(50)],
          handPositions: [
            ['HC', 'OC'],
          ],
        ),
      );

      expect(out.map((h) => h.handSide).toList(), [
        HandSide.right,
        HandSide.left,
        HandSide.right,
        HandSide.left,
      ]);
      // Both hands read the configuration row of their rep.
      expect(out.map((h) => h.targetLoad).toList(), [40.0, 40.0, 50.0, 50.0]);
      expect(out.map((h) => h.edgeSizeMm).toList(), [20, 20, 15, 15]);
    });

    test('alternate reads the left load when the item carries one', () {
      final out = hangs(
        repeater(
          cycles: 1,
          reps: 2,
          hand: HangboardHand.alternate,
          granularity: HangboardGranularity.perRep,
          edges: [20, 15],
          loads: [load(60), load(65)],
          leftLoads: [load(50), load(55)],
          handPositions: [
            ['HC', 'HC'],
          ],
        ),
      );

      final right = out.where((h) => h.handSide == HandSide.right).toList();
      final left = out.where((h) => h.handSide == HandSide.left).toList();
      expect(right.map((h) => h.targetLoad).toList(), [60.0, 65.0]);
      expect(left.map((h) => h.targetLoad).toList(), [50.0, 55.0]);
    });

    // The split shape: a whole set on one hand before the other.
    test('split runs a whole set per hand from the per-hand arrays', () {
      final out = hangs(
        repeater(
          cycles: 2,
          reps: 2,
          hand: HangboardHand.split,
          granularity: HangboardGranularity.perSet,
          edges: [20, 20, 15, 15],
          loads: [load(2), load(4), load(6), load(8)],
          leftLoads: [load(1), load(3), load(5), load(7)],
          handPositions: [
            ['HC', 'HC', 'FC', 'FC'],
            ['OC', 'OC', '3FD', '3FD'],
          ],
        ),
      );

      // Every rep of a set on the right, then the same set on the left.
      expect(out.map((h) => h.handSide).toList(), [
        HandSide.right,
        HandSide.right,
        HandSide.left,
        HandSide.left,
        HandSide.right,
        HandSide.right,
        HandSide.left,
        HandSide.left,
      ]);

      final right = out.where((h) => h.handSide == HandSide.right).toList();
      final left = out.where((h) => h.handSide == HandSide.left).toList();
      expect(right.map((h) => h.targetLoad).toList(), [2.0, 4.0, 6.0, 8.0]);
      expect(left.map((h) => h.targetLoad).toList(), [1.0, 3.0, 5.0, 7.0]);
      // hand_positions holds the left hand first.
      expect(right.first.gripPosition, GripPosition.openHand);
      expect(left.first.gripPosition, GripPosition.halfCrimp);
      expect(right.map((h) => h.edgeSizeMm).toList(), [20, 20, 15, 15]);
    });

    test('a per-rep split replays its rows in every set', () {
      final out = hangs(
        repeater(
          cycles: 2,
          reps: 2,
          hand: HangboardHand.split,
          granularity: HangboardGranularity.perRep,
          edges: [20, 15],
          loads: [load(2), load(4)],
          leftLoads: [load(1), load(3)],
          handPositions: [
            ['HC', 'FC'],
            ['OC', '3FD'],
          ],
        ),
      );

      final right = out.where((h) => h.handSide == HandSide.right).toList();
      final left = out.where((h) => h.handSide == HandSide.left).toList();
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

    // Only a hang on one hand goes through the sensor.
    test('a two-handed hang never collects sensor data', () {
      List<TimedItem> withSensor(String hand) => expandTrainingItems(
        _training([
          TrainingItem.fromJson(
            repeater(
              cycles: 1,
              reps: 1,
              hand: hand,
              granularity: HangboardGranularity.uniform,
              edges: [20],
              loads: [load(30)],
            ),
          ),
        ]),
      ).whereType<TimedItem>().toList();

      expect(
        withSensor(HangboardHand.both).map((h) => h.collectSensorData).toSet(),
        {false},
      );
      expect(
        withSensor(
          HangboardHand.alternate,
        ).map((h) => h.collectSensorData).toSet(),
        {true},
      );
    });

    test('an item without edge sizes keeps its per-rep loads', () {
      final training = _training([
        TrainingItem(
          id: 'r',
          type: TrainingItemType.repeater,
          position: 0,
          cycles: 2,
          reps: 3,
          hand: HangboardHand.right,
          granularity: HangboardGranularity.perRep,
          worktimeSeconds: 7,
          restSeconds: 3,
          loads: const [
            Load(value: 10, unit: 'kg'),
            Load(value: 20, unit: 'kg'),
            Load(value: 30, unit: 'kg'),
          ],
          handPositions: const [
            ['openHand', 'openHand', 'openHand'],
          ],
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

    test('a split item reads its two load arrays', () {
      final training = _training([
        TrainingItem(
          id: 'r',
          type: TrainingItemType.repeater,
          position: 0,
          cycles: 1,
          reps: 2,
          hand: HangboardHand.split,
          granularity: HangboardGranularity.perRep,
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
          handPositions: const [
            ['halfCrimp', 'halfCrimp'],
          ],
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

  group('assessment-relative loads', () {
    final results = AssessmentResults.fromHistory([
      AssessmentModel(
        definition: BuiltinAssessmentIds.definitionOf(AssessmentType.mvc),
        id: 'a1',
        date: DateTime(2026, 1, 1),
        rightValue: 50,
        leftValue: 40,
      ),
      AssessmentModel(
        definition: BuiltinAssessmentIds.definitionOf(
          AssessmentType.endurance60,
        ),
        id: 'a2',
        date: DateTime(2026, 1, 1),
        rightValue: 120,
        leftValue: 120,
      ),
    ]);

    const relativeLoad = Load(
      value: 80,
      unit: percentAssessmentUnit,
      assessmentId: BuiltinAssessmentIds.maxForce,
      fallback: 25,
    );

    test('a repeater targets each hand against its own result', () {
      final repeater = TrainingItem(
        id: 'r',
        type: TrainingItemType.repeater,
        position: 0,
        cycles: 1,
        reps: 1,
        worktimeSeconds: 7,
        restSeconds: 0,
        hand: HangboardHand.alternate,
        loads: const [relativeLoad],
      );

      final out = expandTrainingItems(
        _training([repeater]),
        useSensor: false,
        results: results,
      );
      final hangs = out.whereType<TimedItem>().toList();

      expect(
        hangs.firstWhere((h) => h.handSide == HandSide.right).targetLoad,
        40,
      );
      expect(
        hangs.firstWhere((h) => h.handSide == HandSide.left).targetLoad,
        32,
      );
    });

    test('a hangboard rep falls back without the assessment', () {
      final hangboard = TrainingItem(
        id: 'h',
        type: TrainingItemType.hangboardRep,
        position: 0,
        hand: 'right',
        worktimeSeconds: 7,
        restSeconds: 0,
        loads: const [relativeLoad],
      );

      final out = expandTrainingItems(_training([hangboard]), useSensor: false);

      expect((out.first as TimedItem).targetLoad, 25);
    });

    test('an exercise duration follows the assessment', () {
      final exercise = TrainingItem(
        id: 'e',
        type: TrainingItemType.exercise,
        position: 0,
        duration: 60,
        variableTargets: const {
          'duration': VariableTarget(
            assessmentId: BuiltinAssessmentIds.endurance60,
            percent: 75,
            fallback: 60,
          ),
        },
      );

      final out = expandTrainingItems(
        _training([exercise]),
        useSensor: false,
        results: results,
      );

      expect((out.first as TimedItem).durationSeconds, 90);
    });
  });

  test('every step names the training item it came from', () {
    final training = _training([
      TrainingItem(
        id: 'block-20mm',
        type: TrainingItemType.hangboardRep,
        position: 0,
        reps: 1,
        worktimeSeconds: 7,
        restSeconds: 3,
        hand: HangboardHand.right,
        granularity: HangboardGranularity.uniform,
        edgeSizesMm: const [20],
      ),
      TrainingItem(
        id: 'block-14mm',
        type: TrainingItemType.hangboardRep,
        position: 1,
        reps: 1,
        worktimeSeconds: 7,
        restSeconds: 3,
        hand: HangboardHand.right,
        granularity: HangboardGranularity.uniform,
        edgeSizesMm: const [14],
      ),
    ]);

    final out = expandTrainingItems(training, useSensor: false);

    // Hang and the rest that follows it both belong to the block that set them.
    expect(out.map((e) => e.trainingItemId).toList(), [
      'block-20mm',
      'block-20mm',
      'block-14mm',
      'block-14mm',
    ]);
  });

  test('a circuit rest belongs to the circuit that set it', () {
    final training = _training([
      TrainingItem(
        id: 'circuit',
        type: TrainingItemType.circuit,
        position: 0,
        cycles: 2,
        cycleRestSeconds: 60,
        items: [
          TrainingItem(
            id: 'pullups',
            type: TrainingItemType.exercise,
            position: 0,
            reps: 10,
          ),
        ],
      ),
    ]);

    final out = expandTrainingItems(training, useSensor: false);

    expect(out.map((e) => e.trainingItemId).toList(), [
      'pullups',
      'circuit',
      'pullups',
    ]);
  });

  test('an item that was never saved carries no link', () {
    // Builtin trainings and freshly duplicated items hold a blank id, which is
    // not an item anything can be grouped under.
    final training = _training([
      TrainingItem(
        id: '',
        type: TrainingItemType.hangboardRep,
        position: 0,
        reps: 1,
        worktimeSeconds: 7,
        restSeconds: 3,
        hand: HangboardHand.right,
        granularity: HangboardGranularity.uniform,
        edgeSizesMm: const [20],
      ),
    ]);

    final out = expandTrainingItems(training, useSensor: false);

    expect(out, isNotEmpty);
    expect(out.every((e) => e.trainingItemId == null), isTrue);
  });

  group('emom', () {
    TrainingItem pullUps({bool amrap = false, int? reps = 5}) => TrainingItem(
      id: 'pullup',
      type: TrainingItemType.exercise,
      position: 0,
      exerciseName: 'Pull up',
      reps: reps,
      repsIsMax: amrap,
    );

    test('runs each round then rests out the interval', () {
      final training = _training([
        TrainingItem(
          id: 'emom',
          type: TrainingItemType.emom,
          position: 0,
          cycles: 3,
          intervalSeconds: 60,
          items: [pullUps()],
        ),
      ]);

      final out = expandTrainingItems(training, useSensor: false);

      expect(out.map((e) => e.runtimeType).toList(), [
        ConfirmItem,
        IntervalRestItem,
        ConfirmItem,
        IntervalRestItem,
        ConfirmItem,
        IntervalRestItem,
      ]);
      // The work is self paced, so the whole interval is what is left of it
      // until the run measures how long the round actually took.
      expect((out[1] as IntervalRestItem).durationSeconds, 60);
      expect((out[1] as IntervalRestItem).intervalSeconds, 60);
      expect((out[0] as ConfirmItem).subtitle, 'ROUND 1/3');
      expect((out[4] as ConfirmItem).subtitle, 'ROUND 3/3');
    });

    test('takes the timed work of a round out of the rest that closes it', () {
      final training = _training([
        TrainingItem(
          id: 'emom',
          type: TrainingItemType.emom,
          position: 0,
          cycles: 2,
          intervalSeconds: 90,
          items: [
            TrainingItem(
              id: 'plank',
              type: TrainingItemType.exercise,
              position: 0,
              exerciseName: 'Plank',
              duration: 30,
            ),
          ],
        ),
      ]);

      final out = expandTrainingItems(training, useSensor: false);

      expect((out[1] as IntervalRestItem).durationSeconds, 60);
    });

    test('keys every step to its block and its round', () {
      final training = _training([
        TrainingItem(
          id: 'emom',
          type: TrainingItemType.emom,
          position: 0,
          cycles: 2,
          intervalSeconds: 60,
          items: [pullUps()],
        ),
      ]);

      final out = expandTrainingItems(training, useSensor: false);

      expect(out.every((step) => step.emom?.blockKey == 'emom#0'), isTrue);
      // Where a round starts is read off this list rather than stamped on a
      // step: the run watches for the round changing.
      expect(out.map((step) => step.emom!.round).toList(), [0, 0, 1, 1]);
      expect(out[0].emom!.isSameRoundAs(out[1].emom), isTrue);
      expect(out[1].emom!.isSameRoundAs(out[2].emom), isFalse);
    });

    test('leaves an open rep count for the athlete to answer', () {
      final training = _training([
        TrainingItem(
          id: 'emom',
          type: TrainingItemType.emom,
          position: 0,
          cycles: 2,
          intervalSeconds: 60,
          items: [pullUps(amrap: true, reps: null)],
        ),
      ]);

      final out = expandTrainingItems(training, useSensor: false);
      final first = out[0] as ConfirmItem;

      expect(first.repsAreOpen, isTrue);
      expect(first.reps, isNull);
      // Each round is its own pass through the exercise, so the counts the
      // athlete gives can be told apart.
      expect((out[2] as ConfirmItem).occurrence, 1);
    });

    test('numbers the passes of an item a circuit plays more than once', () {
      final training = _training([
        TrainingItem(
          id: 'c',
          type: TrainingItemType.circuit,
          position: 0,
          cycles: 3,
          items: [pullUps(amrap: true, reps: null)],
        ),
      ]);

      final out = expandTrainingItems(training, useSensor: false);

      expect(out.map((step) => step.occurrence).toList(), [0, 1, 2]);
    });

    test('does not offer to record an item that was never saved', () {
      final training = _training([
        TrainingItem(
          id: '',
          type: TrainingItemType.exercise,
          position: 0,
          exerciseName: 'Pull up',
          repsIsMax: true,
        ),
      ]);

      final out = expandTrainingItems(training, useSensor: false);

      expect((out[0] as ConfirmItem).repsAreOpen, isFalse);
    });
  });

  // The run reads the step, not the training tree, so the link has to travel
  // onto every kind of step an exercise can expand into.
  group('exercise video link', () {
    test('reaches a self paced step', () {
      final out = expandTrainingItems(
        _training([
          const TrainingItem(
            id: 'e1',
            type: TrainingItemType.exercise,
            position: 0,
            reps: 8,
            exerciseName: 'Pull up',
            exerciseVideoLink: 'https://example.com/pull-up',
          ),
        ]),
        useSensor: false,
      );

      final step = out.whereType<ConfirmItem>().single;
      expect(step.videoLink, 'https://example.com/pull-up');
    });

    test('reaches a timed step', () {
      final out = expandTrainingItems(
        _training([
          const TrainingItem(
            id: 'e1',
            type: TrainingItemType.exercise,
            position: 0,
            duration: 30,
            exerciseName: 'Plank',
            exerciseVideoLink: 'https://example.com/plank',
          ),
        ]),
        useSensor: false,
      );

      final step = out.whereType<TimedItem>().single;
      expect(step.videoLink, 'https://example.com/plank');
    });

    test('reaches a hang', () {
      final out = expandTrainingItems(
        _training([
          const TrainingItem(
            id: 'h1',
            type: TrainingItemType.hangboardRep,
            position: 0,
            hand: 'right',
            worktimeSeconds: 7,
            restSeconds: 0,
            loads: [Load(value: 30, unit: 'kg')],
            exerciseName: 'Half crimp hang',
            exerciseVideoLink: 'https://example.com/hang',
          ),
        ]),
        useSensor: false,
      );

      final step = out.whereType<TimedItem>().single;
      expect(step.videoLink, 'https://example.com/hang');
    });

    // A circuit has no exercise behind it, so its children keep their own link
    // instead of inheriting one the container never had.
    test('is not inherited from a container', () {
      final out = expandTrainingItems(
        _training([
          const TrainingItem(
            id: 'c1',
            type: TrainingItemType.circuit,
            position: 0,
            cycles: 1,
            items: [
              TrainingItem(
                id: 'e1',
                type: TrainingItemType.exercise,
                position: 0,
                reps: 5,
                exerciseName: 'Push up',
              ),
            ],
          ),
        ]),
        useSensor: false,
      );

      expect(out.whereType<ConfirmItem>().single.videoLink, isNull);
    });
  });
}
