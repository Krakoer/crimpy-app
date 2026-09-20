import 'package:crimpy/utils/availability_window.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AvailabilityWindow', () {
    // The bounds are written as dates rather than derived from
    // editableAvailabilityWeeks, so this fails if the window ever stops being
    // this week and the next two rather than agreeing with whatever the
    // constant became.
    test('the editable window runs from this Monday to two Mondays on', () {
      final window = AvailabilityWindow.editable(DateTime(2026, 9, 16));

      expect(window.from, DateTime(2026, 9, 14));
      expect(window.to, DateTime(2026, 9, 28));
    });

    test('a day late in the week still opens the window on its Monday', () {
      final window = AvailabilityWindow.editable(DateTime(2026, 9, 20, 23, 30));

      expect(window.from, DateTime(2026, 9, 14));
      expect(window.to, DateTime(2026, 9, 28));
    });

    test('covers both of its bounds and neither week outside them', () {
      final window = AvailabilityWindow(
        from: DateTime(2026, 9, 14),
        to: DateTime(2026, 9, 28),
      );

      // One week before the near bound, and the last day of it.
      expect(window.covers(DateTime(2026, 9, 7)), isFalse);
      expect(window.covers(DateTime(2026, 9, 13)), isFalse);
      // The near bound itself, and a day inside the week it opens.
      expect(window.covers(DateTime(2026, 9, 14)), isTrue);
      expect(window.covers(DateTime(2026, 9, 20)), isTrue);
      expect(window.covers(DateTime(2026, 9, 21)), isTrue);
      // The far bound itself, and the last day of the week it closes.
      expect(window.covers(DateTime(2026, 9, 28)), isTrue);
      expect(window.covers(DateTime(2026, 10, 4)), isTrue);
      // One week after the far bound.
      expect(window.covers(DateTime(2026, 10, 5)), isFalse);
    });

    test('a single week window covers that week and nothing either side', () {
      final window = AvailabilityWindow.single(DateTime(2026, 9, 23));

      expect(window.from, DateTime(2026, 9, 21));
      expect(window.to, DateTime(2026, 9, 21));
      expect(window.covers(DateTime(2026, 9, 21)), isTrue);
      expect(window.covers(DateTime(2026, 9, 27)), isTrue);
      expect(window.covers(DateTime(2026, 9, 20)), isFalse);
      expect(window.covers(DateTime(2026, 9, 28)), isFalse);
    });
  });
}
