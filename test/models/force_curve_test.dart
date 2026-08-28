import 'package:crimpy/models/ble_data_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime.utc(2026, 8, 27, 9, 12, 3);

  group('a force curve on its way to the API', () {
    test('carries one start instant and an offset per reading', () {
      final json = ForceCurve.toJson([
        BleDataPoint(0, t0),
        BleDataPoint(12.5, t0.add(const Duration(milliseconds: 125))),
        BleDataPoint(31.25, t0.add(const Duration(milliseconds: 250))),
      ])!;

      expect(json['t0'], '2026-08-27T09:12:03.000Z');
      expect(json['ms'], [0, 125, 250]);
      expect(json['kg'], [0, 12.5, 31.25]);
    });

    // The offsets are read against the first sample, not against midnight or
    // the session date, so a run that started at any hour comes back where it
    // was recorded.
    test('measures the offsets from the first sample', () {
      final json = ForceCurve.toJson([
        BleDataPoint(5, t0.add(const Duration(seconds: 30))),
        BleDataPoint(6, t0.add(const Duration(seconds: 31))),
      ])!;

      expect(json['t0'], '2026-08-27T09:12:33.000Z');
      expect(json['ms'], [0, 1000]);
    });

    // A reading is a raw double and the API keeps a float32, so the digits past
    // the hundredth are thrown away on arrival and cost bytes on the way.
    test('rounds the readings to the precision the API keeps', () {
      final json = ForceCurve.toJson([BleDataPoint(12.313739386739588, t0)])!;

      expect(json['kg'], [12.31]);
    });

    test('is nothing at all when the run recorded no samples', () {
      expect(ForceCurve.toJson([]), isNull);
    });

    test('survives the round trip', () {
      final points = [
        BleDataPoint(0, t0),
        BleDataPoint(12.5, t0.add(const Duration(milliseconds: 125))),
      ];

      final read = ForceCurve.fromJson(ForceCurve.toJson(points));

      expect(read.map((p) => p.value), points.map((p) => p.value));
      for (final (index, point) in read.indexed) {
        expect(point.timestamp.isAtSameMomentAs(points[index].timestamp), true);
      }
    });
  });

  group('a force curve read back off the API', () {
    test('is empty when the session carries none', () {
      expect(ForceCurve.fromJson(null), isEmpty);
    });

    // The API refuses to store a curve whose arrays disagree, but a row written
    // before it did could still hold one, and half a curve is worse than none.
    test('is empty when the two arrays disagree', () {
      final read = ForceCurve.fromJson({
        't0': '2026-08-27T09:12:03.000Z',
        'ms': [0, 125],
        'kg': [12.5],
      });

      expect(read, isEmpty);
    });

    // The API sends the start instant in UTC and the raw data card formats the
    // point timestamps with no zone conversion of its own, so a run recorded at
    // 09:12 in UTC+2 reads back as 07:12 unless the curve lands local here.
    test('carries the local time the run was recorded at', () {
      final read = ForceCurve.fromJson({
        't0': '2026-08-27T09:12:03.000Z',
        'ms': [0, 125],
        'kg': [12.5, 13.0],
      });

      expect(read.first.timestamp.isUtc, false);
      expect(read.first.timestamp.isAtSameMomentAs(t0), true);
      expect(
        read.last.timestamp.isAtSameMomentAs(
          t0.add(const Duration(milliseconds: 125)),
        ),
        true,
      );
    });

    test('is empty when the start instant is not a date', () {
      final read = ForceCurve.fromJson({
        't0': 'not a date',
        'ms': [0],
        'kg': [12.5],
      });

      expect(read, isEmpty);
    });
  });
}
