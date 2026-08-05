import 'dart:math';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/utils/bodyweight_measurement.dart';
import 'package:flutter_test/flutter_test.dart';

const _sampleInterval = Duration(milliseconds: 50);
final _start = DateTime(2026, 1, 1, 12);

/// Feeds [measurement] with [seconds] worth of samples produced by [valueAt],
/// starting at [from]. Returns the timestamp just past the last sample.
DateTime _feed(
  BodyweightMeasurement measurement,
  DateTime from,
  double seconds,
  double Function(double elapsedSeconds) valueAt,
) {
  final samples = (seconds * 1000 / _sampleInterval.inMilliseconds).round();
  var at = from;
  for (var i = 0; i < samples; i++) {
    final elapsed = i * _sampleInterval.inMilliseconds / 1000;
    measurement.add(BleDataPoint(valueAt(elapsed), at));
    at = at.add(_sampleInterval);
  }
  return at;
}

DateTime _feedSteady(
  BodyweightMeasurement measurement,
  DateTime from,
  double seconds,
  double value,
) => _feed(measurement, from, seconds, (_) => value);

void main() {
  group('bodyweight measurement', () {
    test('records the plateau once the reading has held still', () {
      final measurement = BodyweightMeasurement();
      _feedSteady(measurement, _start, 8, 70.0);

      expect(measurement.phase, BodyweightMeasurementPhase.done);
      expect(measurement.result, closeTo(70.0, 0.01));
    });

    test('does not start until the reading has settled', () {
      final measurement = BodyweightMeasurement();
      _feedSteady(measurement, _start, 0.5, 70.0);

      expect(measurement.phase, BodyweightMeasurementPhase.waiting);
      expect(measurement.progress, 0);
      expect(measurement.secondsRemaining, 5);
      expect(measurement.result, isNull);
    });

    test('a short hold is not enough to produce a weight', () {
      final measurement = BodyweightMeasurement();
      _feedSteady(measurement, _start, 4, 70.0);

      expect(measurement.phase, BodyweightMeasurementPhase.holding);
      expect(measurement.result, isNull);
      expect(measurement.secondsRemaining, greaterThan(0));
    });

    test('the overshoot of stepping onto the board stays out of the result', () {
      // The regression this guards: taking the peak of a fixed window read the
      // drop onto the board rather than the athlete weight.
      final measurement = BodyweightMeasurement();
      var at = _feed(measurement, _start, 1.0, (t) => 70 + 25 * (1 - t));
      _feedSteady(measurement, at, 8, 70.0);

      expect(measurement.result, closeTo(70.0, 0.5));
    });

    test('a pull up during the window starts it over', () {
      final measurement = BodyweightMeasurement();
      var at = _feedSteady(measurement, _start, 4, 70.0);
      expect(measurement.progress, greaterThan(0));

      at = _feedSteady(measurement, at, 1, 110.0);
      expect(measurement.result, isNull);
      expect(measurement.progress, 0);
    });

    test('stepping back onto the ground starts it over', () {
      final measurement = BodyweightMeasurement();
      var at = _feedSteady(measurement, _start, 4, 70.0);

      at = _feedSteady(measurement, at, 1, 0.5);
      expect(measurement.result, isNull);
      expect(measurement.phase, BodyweightMeasurementPhase.waiting);

      // And it can still be measured afterwards without touching reset.
      _feedSteady(measurement, at, 8, 70.0);
      expect(measurement.result, closeTo(70.0, 0.01));
    });

    test('normal sway and breathing do not restart the window', () {
      final measurement = BodyweightMeasurement();
      final noise = Random(7);
      _feed(
        measurement,
        _start,
        8,
        (_) => 70 + (noise.nextDouble() - 0.5) * 2.4,
      );

      expect(measurement.phase, BodyweightMeasurementPhase.done);
      expect(measurement.result, closeTo(70.0, 1.0));
    });

    test('a lone spike is treated as noise rather than a broken hold', () {
      final measurement = BodyweightMeasurement();
      var at = _feedSteady(measurement, _start, 4, 70.0);
      // One sample well outside the band, shorter than the tolerated deviation.
      measurement.add(BleDataPoint(95.0, at));
      at = at.add(_sampleInterval);
      _feedSteady(measurement, at, 4, 70.0);

      expect(measurement.result, closeTo(70.0, 0.5));
    });

    test('a hold interrupted by a stalled stream does not count', () {
      // Backgrounding the app or losing the sensor stops the samples. Reading
      // the window from timestamps alone would let the hold resume across the
      // hole and complete on two samples several seconds apart.
      final measurement = BodyweightMeasurement();
      final at = _feedSteady(measurement, _start, 1.5, 70.0);

      _feedSteady(measurement, at.add(const Duration(seconds: 10)), 1, 70.0);

      expect(measurement.result, isNull);
    });

    test('an unloaded sensor never produces a weight', () {
      final measurement = BodyweightMeasurement();
      _feedSteady(measurement, _start, 10, 0.2);

      expect(measurement.phase, BodyweightMeasurementPhase.waiting);
      expect(measurement.result, isNull);
    });

    test('a reading too heavy to be an athlete is refused', () {
      final measurement = BodyweightMeasurement();
      _feedSteady(measurement, _start, 10, 300.0);

      expect(measurement.result, isNull);
    });

    test('reset clears a recorded weight so it can be measured again', () {
      final measurement = BodyweightMeasurement();
      _feedSteady(measurement, _start, 8, 70.0);
      expect(measurement.result, isNotNull);

      measurement.reset();
      expect(measurement.result, isNull);
      expect(measurement.phase, BodyweightMeasurementPhase.waiting);
    });
  });
}
