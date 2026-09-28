import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/utils/load_drop_alarm.dart';
import 'package:flutter_test/flutter_test.dart';

final _start = DateTime(2026, 9, 28, 10);

DateTime _at(int milliseconds) =>
    _start.add(Duration(milliseconds: milliseconds));

/// Feeds [loads] to [alarm] one every 100 ms from [from], the rate of the
/// simulated sensor, and answers what the alarm said after the last one.
bool _feed(LoadDropAlarm alarm, List<double> loads, {int from = 0}) {
  var raised = alarm.raised;
  for (var i = 0; i < loads.length; i++) {
    raised = alarm.update(loads[i], _at(from + i * 100));
  }
  return raised;
}

TimedItem _hang({
  double targetLoad = 40,
  bool collectSensorData = true,
  bool isHang = true,
}) => TimedItem(
  label: 'Right hang',
  durationSeconds: 7,
  targetLoad: targetLoad,
  handSide: HandSide.right,
  gripPosition: GripPosition.halfCrimp,
  collectSensorData: collectSensorData,
  isHang: isHang,
);

void main() {
  // Target 40 kg: fires under 36 kg, clears at 38 kg.
  group('the threshold', () {
    test('holds at the target and just under it', () {
      final alarm = LoadDropAlarm(40);
      expect(_feed(alarm, List.filled(20, 40)), isFalse);
      expect(_feed(alarm, List.filled(20, 36), from: 2000), isFalse);
    });

    test('fires under 90 % of the target', () {
      final alarm = LoadDropAlarm(40);
      expect(_feed(alarm, List.filled(6, 35.9)), isTrue);
    });

    test('scales with the target', () {
      final alarm = LoadDropAlarm(20);
      expect(_feed(alarm, List.filled(6, 18.5)), isFalse);
      expect(_feed(alarm, List.filled(6, 17.9), from: 1000), isTrue);
    });
  });

  group('the dwell', () {
    test('lets a dip shorter than half a second pass', () {
      final alarm = LoadDropAlarm(40);
      // 0 to 400 ms under the line: 0.4 s, short of the dwell.
      expect(_feed(alarm, [30, 30, 30, 30, 30, 40]), isFalse);
    });

    test('fires once the load has stayed under for half a second', () {
      final alarm = LoadDropAlarm(40);
      expect(alarm.update(30, _at(0)), isFalse);
      expect(alarm.update(30, _at(499)), isFalse);
      expect(alarm.update(30, _at(500)), isTrue);
    });

    test('starts over when the load comes back above the fire line', () {
      final alarm = LoadDropAlarm(40);
      // Under for 400 ms, back at 37 kg, which is above the fire line and
      // under the clear one, then under again for 400 ms: never 0.5 s in a
      // row.
      expect(_feed(alarm, [30, 30, 30, 30, 30, 37, 30, 30, 30, 30, 30]), false);
    });

    test('counts from the first sample of the rep', () {
      // A hang that never gets on target is below it all the same.
      final alarm = LoadDropAlarm(40);
      expect(_feed(alarm, List.filled(6, 20)), isTrue);
    });
  });

  group('the clear', () {
    test('holds between 90 and 95 % of the target', () {
      final alarm = LoadDropAlarm(40);
      expect(_feed(alarm, List.filled(6, 30)), isTrue);
      expect(_feed(alarm, List.filled(20, 37.9), from: 600), isTrue);
    });

    test('clears once the load is back at 95 % of the target', () {
      final alarm = LoadDropAlarm(40);
      expect(_feed(alarm, List.filled(6, 30)), isTrue);
      expect(alarm.update(38, _at(600)), isFalse);
    });

    test('fires again only after a fresh dwell', () {
      final alarm = LoadDropAlarm(40);
      _feed(alarm, List.filled(6, 30));
      alarm.update(40, _at(600));
      expect(_feed(alarm, [30, 30, 30, 30, 30], from: 700), isFalse);
      expect(alarm.update(30, _at(1200)), isTrue);
    });
  });

  group('the steps it watches', () {
    test('a hang reading the sensor with a target load', () {
      expect(loadDropTargetOf(_hang()), 40);
    });

    test('not a hang without a target load', () {
      expect(loadDropTargetOf(_hang(targetLoad: 0)), 0);
    });

    test('not a hang the sensor does not read', () {
      expect(loadDropTargetOf(_hang(collectSensorData: false)), 0);
    });

    test('not a step that is not a hang', () {
      expect(loadDropTargetOf(_hang(isHang: false)), 0);
    });

    test('not a rest, and not nothing', () {
      expect(loadDropTargetOf(const RestItem(durationSeconds: 3)), 0);
      expect(loadDropTargetOf(null), 0);
    });
  });
}
