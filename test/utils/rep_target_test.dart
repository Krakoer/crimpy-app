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
    test('is the prescribed load when the step is measured', () {
      expect(_hang(collectSensorData: true).recordedTargetLoad, 30);
    });

    test('is none when the step collects no sensor data', () {
      expect(_hang(collectSensorData: false).recordedTargetLoad, 0);
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
  });
}
