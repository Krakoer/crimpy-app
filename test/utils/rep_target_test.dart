import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/utils/reps.dart';
import 'package:flutter_test/flutter_test.dart';

TimedItem _hang({required bool collectSensorData}) => TimedItem(
  label: 'Hang',
  durationSeconds: 7,
  targetLoad: 30,
  handSide: collectSensorData ? HandSide.right : HandSide.both,
  gripPosition: GripPosition.halfCrimp,
  collectSensorData: collectSensorData,
  isHang: true,
);

void main() {
  group('recorded target', () {
    test('is the prescribed load when the sensor measured the step', () {
      expect(
        _hang(
          collectSensorData: true,
        ).recordedTargetLoad(sensorDelivered: true),
        30,
      );
    });

    test('is none when the step collects no sensor data', () {
      expect(
        _hang(
          collectSensorData: false,
        ).recordedTargetLoad(sensorDelivered: true),
        0,
      );
    });

    test('is none when the sensor delivered nothing for the step', () {
      expect(
        _hang(
          collectSensorData: true,
        ).recordedTargetLoad(sensorDelivered: false),
        0,
      );
    });

    test('reaches the rep a measured step records', () {
      final reps = buildRepsData([25.0], [_hang(collectSensorData: true)]);

      expect(reps.single.targetWeight, 30);
    });

    test('is left off the rep a sensorless step records', () {
      final reps = buildRepsData([0.0], [_hang(collectSensorData: false)]);

      expect(reps.single.targetWeight, 0);
      expect(reps.single.averageWeight, 0);
    });

    test('is left off a step the averages ran out for', () {
      final reps = buildRepsData(
        [25.0],
        [_hang(collectSensorData: true), _hang(collectSensorData: true)],
      );

      expect(reps.first.targetWeight, 30);
      expect(reps.last.targetWeight, 0);
      expect(reps.last.averageWeight, 0);
    });
  });
}
