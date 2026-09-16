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

    test('a week retimes a duration and moves an emom clock', () {
      final plank = TrainingItem.fromJson({
        'id': 'p1',
        'type': 'exercise',
        'position': 0,
        'duration': 30,
      });
      final emom = TrainingItem.fromJson({
        'id': 'e1',
        'type': 'emom',
        'position': 0,
        'cycles': 10,
        'interval_seconds': 60,
      });

      expect(plank.applyOverride({'duration': 45}).duration, 45);
      expect(emom.applyOverride({'interval_seconds': 90}).intervalSeconds, 90);
    });

    test('a week opens a rep count and lowers a max effort', () {
      final reps = TrainingItem.fromJson({
        'id': 'r1',
        'type': 'exercise',
        'position': 0,
        'reps': 8,
      });
      final hang = TrainingItem.fromJson({
        'id': 'h1',
        'type': 'hangboard_rep',
        'position': 0,
        'load_is_max': true,
        'loads': [
          {'unit': 'max', 'value': 0},
        ],
      });

      final open = reps.applyOverride({'reps_is_max': true});
      expect(open.repsIsMax, isTrue);
      expect(open.applyOverride({'reps_is_max': false}).repsIsMax, isFalse);
      // The item level marker still stands in for a max effort on older
      // clients, so a week that prescribes kilograms has to clear it or the app
      // reads MAX where the plan reads the number.
      final lowered = hang.applyOverride({
        'load_is_max': false,
        'loads': [
          {'unit': 'kg', 'value': 25},
        ],
      });
      expect(lowered.loadIsMax, isFalse);
      expect(lowered.loadLabel(), '25 kg');
    });

    test('a key the week leaves out keeps the base marker', () {
      final hang = TrainingItem.fromJson({
        'id': 'h1',
        'type': 'hangboard_rep',
        'position': 0,
        'load_is_max': true,
      });

      expect(hang.applyOverride({'hb_worktime_seconds': 10}).loadIsMax, isTrue);
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

  group('TrainingItem.reportKey', () {
    // The two answer different questions: where the item is stored, and what a
    // report written against it is called. A generated step has the second and
    // not the first, and that is the whole point of keeping them apart.
    test('falls back to the stored id', () {
      const stored = TrainingItem(
        id: 'stored-item',
        type: TrainingItemType.repeater,
        position: 0,
      );

      expect(stored.reportKey, 'stored-item');
    });

    test('is the generated key when the item was never stored', () {
      const generated = TrainingItem(
        id: '',
        stableKey: 'builtin:mvc:0',
        type: TrainingItemType.repeater,
        position: 0,
      );

      expect(generated.reportKey, 'builtin:mvc:0');
      // Still unstored, which is what an insert and the backend both read.
      expect(generated.id, isEmpty);
    });

    test('is empty on an item with neither', () {
      const added = TrainingItem(
        id: '',
        type: TrainingItemType.repeater,
        position: 0,
      );

      expect(added.reportKey, isEmpty);
    });

    // The reports of a session are keyed on it, and the frozen prescription is
    // what heads them when they are read back, so it has to survive the round
    // trip through the snapshot.
    test('survives the prescription snapshot', () {
      const generated = TrainingItem(
        id: '',
        stableKey: 'builtin:mvc:0',
        type: TrainingItemType.repeater,
        position: 0,
        items: [
          TrainingItem(
            id: '',
            stableKey: 'builtin:mvc:0.1',
            type: TrainingItemType.hangboardRep,
            position: 1,
          ),
        ],
      );

      final read = TrainingItem.fromJson(generated.toPrescriptionJson());

      expect(read.reportKey, 'builtin:mvc:0');
      expect(read.items.single.reportKey, 'builtin:mvc:0.1');
    });

    // The API names its own items and parses the field as a uuid, so a key the
    // app generated has no business in the payload it takes.
    test('is left out of the API payload', () {
      const generated = TrainingItem(
        id: '',
        stableKey: 'builtin:mvc:0',
        type: TrainingItemType.repeater,
        position: 0,
      );

      expect(generated.toJson().containsKey('stable_key'), isFalse);
    });

    test('is dropped by duplicate, which is a step of nothing', () {
      const generated = TrainingItem(
        id: '',
        stableKey: 'builtin:mvc:0',
        type: TrainingItemType.repeater,
        position: 0,
      );

      expect(generated.duplicate().reportKey, isEmpty);
    });

    // An override rewrites the prescription of a step, not which step it is.
    test('is carried over by copyWith', () {
      const generated = TrainingItem(
        id: '',
        stableKey: 'builtin:mvc:0',
        type: TrainingItemType.repeater,
        position: 0,
      );

      expect(generated.copyWith(position: 4).reportKey, 'builtin:mvc:0');
    });
  });

  group('TrainingItem.toJson id', () {
    test('sends the id back so an update keeps the stored row', () {
      final item = TrainingItem.fromJson({
        'id': 'stored-item',
        'type': 'repeater',
        'position': 0,
        'items': [
          {'id': 'nested-item', 'type': 'hangboard_rep', 'position': 0},
        ],
      });

      final json = item.toJson();
      expect(json['id'], 'stored-item');
      expect((json['items'] as List).single['id'], 'nested-item');
    });

    // An item the editor just added, or a duplicate, has no stored row yet, and
    // an empty id would be refused rather than read as "give me one".
    test('omits the id of an item that was never stored', () {
      final added = TrainingItem.fromJson({
        'id': 'stored-item',
        'type': 'repeater',
        'position': 0,
      }).duplicate();

      expect(added.toJson().containsKey('id'), isFalse);
    });
  });

  // The athlete cannot read the coach's exercise, so the link only ever arrives
  // denormalized onto the item, and has to survive the snapshot a played
  // session freezes: without that the run loses what the schedule screen shows.
  group('TrainingItem exercise video', () {
    const json = {
      'id': 'e1',
      'type': 'exercise',
      'position': 0,
      'reps': 8,
      'exercise_id': 'x1',
      'exercise_name': 'Pull up',
      'exercise_description': 'Dead hang start.',
      'exercise_comment': 'Shoulders engaged.',
      'exercise_video_link': 'https://example.com/pull-up',
    };

    test('is read off the item payload', () {
      final item = TrainingItem.fromJson(json);

      expect(item.exerciseDescription, 'Dead hang start.');
      expect(item.exerciseComment, 'Shoulders engaged.');
      expect(item.exerciseVideoLink, 'https://example.com/pull-up');
    });

    test('survives the prescription snapshot', () {
      final frozen = TrainingItem.fromJson(
        TrainingItem.fromJson(json).toPrescriptionJson(),
      );

      expect(frozen.exerciseDescription, 'Dead hang start.');
      expect(frozen.exerciseComment, 'Shoulders engaged.');
      expect(frozen.exerciseVideoLink, 'https://example.com/pull-up');
    });

    test('is absent when the exercise carries none', () {
      final item = TrainingItem.fromJson({
        'id': 'e1',
        'type': 'exercise',
        'position': 0,
        'reps': 8,
      });

      expect(item.exerciseDescription, isNull);
      expect(item.exerciseComment, isNull);
      expect(item.exerciseVideoLink, isNull);
      expect(
        item.toPrescriptionJson().containsKey('exercise_video_link'),
        isFalse,
      );
    });
  });
}
