import 'package:crimpy/utils/datetimes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('trainingDayOf', () {
    test('an evening belongs to its own day', () {
      expect(
        trainingDayOf(DateTime(2026, 9, 28, 23, 47)),
        DateTime(2026, 9, 28),
      );
    });

    test('until 03:59 it is still the day before', () {
      expect(trainingDayOf(DateTime(2026, 9, 29)), DateTime(2026, 9, 28));
      expect(
        trainingDayOf(DateTime(2026, 9, 29, 3, 59, 59)),
        DateTime(2026, 9, 28),
      );
    });

    test('the day turns at 04:00', () {
      expect(trainingDayOf(DateTime(2026, 9, 29, 4)), DateTime(2026, 9, 29));
    });

    test('rolls back across a month and a year', () {
      expect(trainingDayOf(DateTime(2026, 10, 1, 1)), DateTime(2026, 9, 30));
      expect(trainingDayOf(DateTime(2027, 1, 1, 2)), DateTime(2026, 12, 31));
    });

    // These run in whatever zone the machine is in, so they cannot force a
    // transition. What they pin is what keeps a DST night safe anywhere: the
    // result is always a local midnight, one or zero calendar days back.
    test('is a local midnight at most one calendar day back, all year', () {
      for (var offset = 0; offset < 400 * 24; offset++) {
        final instant = DateTime(2026, 1, 1, offset);
        final day = trainingDayOf(instant);

        expect(day.hour, 0, reason: 'instant $instant');
        expect(day.minute, 0, reason: 'instant $instant');
        expect(
          calendarDaysBetween(day, instant),
          instant.hour < trainingDayStartHour ? 1 : 0,
          reason: 'instant $instant',
        );
      }
    });
  });
}
