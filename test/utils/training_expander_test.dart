import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training_model.dart';
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
        type: TrainingItemType.section,
        position: 0,
        sectionTitle: 'Warmup',
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
}
