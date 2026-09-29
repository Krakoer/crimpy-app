import 'package:crimpy/utils/run_clock_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 9, 29, 10);
  DateTime at(int ms) => t0.add(Duration(milliseconds: ms));

  group('RunClockLog', () {
    test('places a reading on the run clock while it runs', () {
      final log = RunClockLog()..started(at(0), 0);

      expect(log.runClockAt(at(2500)), 2500);
    });

    test('leaves out what was read while the run clock was stopped', () {
      final log = RunClockLog()
        ..started(at(0), 0)
        ..stopped(at(3000))
        ..started(at(8000), 3000);

      expect(log.runClockAt(at(2999)), 2999);
      expect(log.runClockAt(at(5000)), isNull);
      // Resuming picks the run clock up where it stopped.
      expect(log.runClockAt(at(9000)), 4000);
    });

    test('knows nothing read before the run started', () {
      final log = RunClockLog()..started(at(1000), 0);

      expect(log.runClockAt(at(500)), isNull);
    });

    test('ignores a second start while running', () {
      final log = RunClockLog()
        ..started(at(0), 0)
        ..started(at(1000), 1000);

      expect(log.runClockAt(at(1500)), 1500);
    });
  });
}
