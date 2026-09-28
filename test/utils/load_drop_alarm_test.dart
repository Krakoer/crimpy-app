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

/// A fresh alarm for [target] whose rep has already got on target, at 0 ms.
/// The samples a test feeds it then start at 100 ms.
LoadDropAlarm _armed(double target) {
  final alarm = LoadDropAlarm(target);
  alarm.update(target, _at(0));
  return alarm;
}

void main() {
  // Target 40 kg: fires under 36 kg, clears at 38 kg.
  group('the threshold', () {
    test('holds at the target and just under it', () {
      final alarm = _armed(40);
      expect(_feed(alarm, List.filled(20, 40), from: 100), isFalse);
      expect(_feed(alarm, List.filled(20, 36), from: 2100), isFalse);
    });

    test('fires under 90 % of the target', () {
      final alarm = _armed(40);
      expect(_feed(alarm, List.filled(6, 35.9), from: 100), isTrue);
    });

    test('scales with the target', () {
      final alarm = _armed(20);
      expect(_feed(alarm, List.filled(6, 18.5), from: 100), isFalse);
      expect(_feed(alarm, List.filled(6, 17.9), from: 1100), isTrue);
    });
  });

  group('the dwell', () {
    test('lets a dip shorter than half a second pass', () {
      final alarm = _armed(40);
      // 0 to 400 ms under the line: 0.4 s, short of the dwell.
      expect(_feed(alarm, [30, 30, 30, 30, 30, 40], from: 100), isFalse);
    });

    test('fires once the load has stayed under for half a second', () {
      final alarm = _armed(40);
      expect(alarm.update(30, _at(100)), isFalse);
      expect(alarm.update(30, _at(599)), isFalse);
      expect(alarm.update(30, _at(600)), isTrue);
    });

    test('starts over when the load comes back above the fire line', () {
      final alarm = _armed(40);
      // Under for 400 ms, back at 37 kg, which is above the fire line and
      // under the clear one, then under again for 400 ms: never 0.5 s in a
      // row.
      expect(
        _feed(alarm, [30, 30, 30, 30, 30, 37, 30, 30, 30, 30, 30], from: 100),
        isFalse,
      );
    });

    test('counts from the first sample under the line once on target', () {
      final alarm = LoadDropAlarm(40);
      expect(_feed(alarm, [20, 30, 38, 40, 40, 20, 20, 20, 20, 20]), isFalse);
      expect(alarm.update(20, _at(1000)), isTrue);
    });
  });

  // Only a load that got on target can drop below it.
  group('the arming', () {
    test('lets a slow load-up pass', () {
      final alarm = LoadDropAlarm(40);
      // Two seconds climbing from nothing to the target, all of it under the
      // fire line until the last few samples.
      final ramp = [for (var i = 0; i <= 20; i++) 40.0 * i / 20];
      expect(_feed(alarm, ramp), isFalse);
    });

    test('lets a hang that never reaches the target pass', () {
      final alarm = LoadDropAlarm(40);
      expect(_feed(alarm, List.filled(70, 20)), isFalse);
    });

    test('is not armed by a load between the two lines', () {
      final alarm = LoadDropAlarm(40);
      expect(_feed(alarm, [37, 37, 37, 30, 30, 30, 30, 30, 30, 30]), isFalse);
    });

    test('arms at 95 % of the target, short of the target itself', () {
      final alarm = LoadDropAlarm(40);
      expect(_feed(alarm, [38, 30, 30, 30, 30, 30, 30]), isTrue);
    });
  });

  group('the clear', () {
    test('holds between 90 and 95 % of the target', () {
      final alarm = _armed(40);
      expect(_feed(alarm, List.filled(6, 30), from: 100), isTrue);
      expect(_feed(alarm, List.filled(20, 37.9), from: 700), isTrue);
    });

    test('clears once the load is back at 95 % of the target', () {
      final alarm = _armed(40);
      expect(_feed(alarm, List.filled(6, 30), from: 100), isTrue);
      expect(alarm.update(38, _at(700)), isFalse);
    });

    test('fires again only after a fresh dwell', () {
      final alarm = _armed(40);
      _feed(alarm, List.filled(6, 30), from: 100);
      alarm.update(40, _at(700));
      expect(_feed(alarm, [30, 30, 30, 30, 30], from: 800), isFalse);
      expect(alarm.update(30, _at(1300)), isTrue);
    });
  });

  // A sensor that reconnects mid-rep starts the watch over.
  group('the reset', () {
    test('disarms it, so a low first sample after it cannot fire', () {
      final alarm = _armed(40);
      alarm.reset();
      expect(_feed(alarm, List.filled(10, 20), from: 100), isFalse);
    });

    test('watches afresh once the load is back on target', () {
      final alarm = _armed(40);
      _feed(alarm, [20, 20, 20, 20], from: 100);
      alarm.reset();
      alarm.update(40, _at(500));
      expect(_feed(alarm, [20, 20, 20, 20, 20], from: 600), isFalse);
      expect(alarm.update(20, _at(1100)), isTrue);
    });

    test('puts a raised alarm down', () {
      final alarm = _armed(40);
      expect(_feed(alarm, List.filled(6, 20), from: 100), isTrue);
      alarm.reset();
      expect(alarm.raised, isFalse);
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
