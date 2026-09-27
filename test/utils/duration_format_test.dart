import 'package:crimpy/utils/duration_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatClock', () {
    test('reads minutes and two-digit seconds', () {
      expect(formatClock(const Duration(seconds: 3)), '0:03');
      expect(formatClock(const Duration(seconds: 191)), '3:11');
      expect(formatClock(const Duration(minutes: 12, seconds: 5)), '12:05');
    });

    test('reads zero as a clock at rest', () {
      expect(formatClock(Duration.zero), '0:00');
    });

    test('drops what is below a second rather than rounding up', () {
      expect(formatClock(const Duration(milliseconds: 4999)), '0:04');
    });

    test('leads with the hours past an hour', () {
      expect(formatClock(const Duration(hours: 1, seconds: 125)), '1:02:05');
      expect(formatClock(const Duration(hours: 2)), '2:00:00');
    });

    test('never counts below zero', () {
      expect(formatClock(const Duration(seconds: -5)), '0:00');
    });
  });

  group('formatLength', () {
    test('rounds to the nearest minute', () {
      expect(formatLength(const Duration(minutes: 25)), '25 min');
      expect(formatLength(const Duration(minutes: 25, seconds: 29)), '25 min');
      expect(formatLength(const Duration(minutes: 25, seconds: 37)), '26 min');
    });

    test('reads hours once it passes one', () {
      expect(formatLength(const Duration(hours: 1)), '1 h');
      expect(formatLength(const Duration(minutes: 90)), '1 h 30 min');
      expect(formatLength(const Duration(minutes: 59, seconds: 45)), '1 h');
    });

    test('keeps the seconds under a minute so a short one is not nothing', () {
      expect(formatLength(const Duration(seconds: 45)), '45s');
      expect(formatLength(const Duration(seconds: 1)), '1s');
    });

    test('reads none as zero minutes', () {
      expect(formatLength(Duration.zero), '0 min');
      expect(formatLength(const Duration(seconds: -30)), '0 min');
    });
  });

  group('formatMinutes', () {
    test('reads whole minutes as formatLength does', () {
      expect(formatMinutes(0), '0 min');
      expect(formatMinutes(45), '45 min');
      expect(formatMinutes(125), '2 h 5 min');
    });
  });

  group('formatExactLength', () {
    test('keeps every second', () {
      expect(formatExactLength(7), '7s');
      expect(formatExactLength(90), '1 min 30s');
      expect(formatExactLength(191), '3 min 11s');
    });

    test('drops the seconds on a whole minute', () {
      expect(formatExactLength(60), '1 min');
      expect(formatExactLength(120), '2 min');
    });

    test('reads hours past an hour', () {
      expect(formatExactLength(3600), '1 h');
      expect(formatExactLength(3661), '1 h 1 min 1s');
    });

    test('never reads below zero', () {
      expect(formatExactLength(0), '0s');
      expect(formatExactLength(-4), '0s');
    });
  });
}
