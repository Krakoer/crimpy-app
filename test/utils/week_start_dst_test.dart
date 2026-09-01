import 'package:crimpy/utils/datetimes.dart';
import 'package:flutter_test/flutter_test.dart';

// A week start is a map key: the declared week, the home card and the reminder
// planner all decide by comparing one against another. Built by adding a
// Duration, which is elapsed time, a week start lands an hour either side of
// midnight across a DST change and stops comparing equal to itself.
//
// These run in whatever zone the machine is in, so they cannot force a
// transition. What they pin is the property that makes the arithmetic safe
// everywhere: every result is local midnight on a Monday, and stepping a week
// lands on the next Monday rather than 168 hours later.
void main() {
  group('getStartOfWeek', () {
    test('is local midnight on the Monday of that week', () {
      for (var offset = 0; offset < 400; offset++) {
        final day = DateTime(2026, 1, 1 + offset, 13, 37);
        final monday = getStartOfWeek(day);

        expect(monday.weekday, DateTime.monday, reason: 'day $day');
        expect(monday.hour, 0, reason: 'day $day');
        expect(monday.minute, 0, reason: 'day $day');
      }
    });

    test('is idempotent, so a stored week start reads back equal', () {
      for (var offset = 0; offset < 400; offset++) {
        final monday = getStartOfWeek(DateTime(2026, 1, 1 + offset));

        expect(getStartOfWeek(monday), monday);
      }
    });
  });

  group('getStartOfNextWeek', () {
    test(
      'lands on the following Monday at midnight, every week of the year',
      () {
        for (var offset = 0; offset < 400; offset++) {
          final day = DateTime(2026, 1, 1 + offset);
          final next = getStartOfNextWeek(day);

          expect(next.weekday, DateTime.monday, reason: 'day $day');
          expect(next.hour, 0, reason: 'day $day');
          expect(next, getStartOfWeek(next), reason: 'day $day');
        }
      },
    );

    test('is exactly one week on from this one, in calendar days', () {
      for (var offset = 0; offset < 400; offset++) {
        final day = DateTime(2026, 1, 1 + offset);
        final monday = getStartOfWeek(day);
        final next = getStartOfNextWeek(day);

        expect(next.difference(monday).inDays, inInclusiveRange(6, 8));
        expect(getStartOfWeek(next.subtract(const Duration(days: 1))), monday);
      }
    });
  });
}
