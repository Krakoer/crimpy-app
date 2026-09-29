import 'package:crimpy/models/critical_force_result.dart';
import 'package:crimpy/utils/critical_force_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

const _period = 0.1;

/// The windows of a 7:3 test of [pulls] pulls, starting at 0.
List<CriticalForceWindow> _windows(int pulls) => [
  for (var i = 0; i < pulls; i++) (start: i * 10.0, end: i * 10.0 + 7),
];

/// Readings every 100 ms over [pulls] cycles, the force at each time given by
/// [force].
List<CriticalForceSample> _trace(int pulls, double Function(double t) force) {
  final samples = <CriticalForceSample>[];
  final total = pulls * 10 - 3;
  for (var i = 0; i * _period <= total + 1e-9; i++) {
    final t = i * _period;
    samples.add((t: t, kg: force(t)));
  }
  return samples;
}

/// A square wave: [kgOf] for the pull the time falls in, 0 during rests.
double Function(double) _square(double Function(int pull) kgOf) =>
    (t) => t % 10 <= 7 + 1e-9 ? kgOf(t ~/ 10) : 0;

void main() {
  group('Critical Force analysis', () {
    test('is the mean of the last 6 pulls, with no duty factor', () {
      // Pull n holds 30 - n kg, so pulls 19-24 hold 11 down to 6 kg.
      final results = analyseCriticalForce(
        _trace(24, _square((pull) => 30.0 - (pull + 1))),
        _windows(24),
      );

      expect(
        results.criticalForce,
        closeTo((11 + 10 + 9 + 8 + 7 + 6) / 6, 0.01),
      );
      expect(results.firstCountedPull, 19);
      expect(results.lastCountedPull, 24);
      expect(results.pulls, hasLength(24));
    });

    test('counts a pull that sags under 7 kg as the low force it is', () {
      final results = analyseCriticalForce(
        _trace(24, _square((pull) => pull >= 18 ? 5 : 25)),
        _windows(24),
      );

      expect(results.criticalForce, closeTo(5, 0.05));
      expect(results.pulls.last.meanKg, closeTo(5, 0.05));
    });

    test('does not credit force held past the bell, and marks it late off', () {
      // Every pull at 10 kg, but pull 20 is held at 30 kg for 2 s after it.
      final results = analyseCriticalForce(
        _trace(24, (t) {
          if (t % 10 <= 7 + 1e-9) return 10;
          if (t >= 197 && t < 199) return 30;
          return 0;
        }),
        _windows(24),
      );

      expect(results.criticalForce, closeTo(10, 0.05));
      expect(results.pulls[19].lateOff, isTrue);
      expect(results.pulls[18].lateOff, isFalse);
      expect(results.lateOffCount, 1);
      expect(results.pulls.last.restLoadSeconds, isNull);
    });

    test('keeps each pull\'s mean, peak, end force and impulse', () {
      // Pull 1 ramps from 0 to 14 kg over its 7 s.
      final results = analyseCriticalForce(
        _trace(6, (t) => t < 7 ? t * 2 : _square((_) => 10)(t)),
        _windows(6),
      );
      final first = results.pulls.first;

      expect(first.meanKg, closeTo(48.8 / 7, 0.01));
      expect(first.peakKg, closeTo(13.8, 0.01));
      expect(first.impulseKgS, closeTo(48.8, 0.01));
      expect(first.endKg, closeTo(12.8, 0.01));
      expect(first.coverage, closeTo(1, 0.02));
    });

    test('gives W\' as the impulse above Critical Force inside the pulls', () {
      // Pulls 1-2 at 30 kg, then 10 kg: CF is 10 and each hard pull spends
      // 20 kg for 7 s above it.
      final results = analyseCriticalForce(
        _trace(12, _square((pull) => pull < 2 ? 30 : 10)),
        _windows(12),
      );

      expect(results.criticalForce, closeTo(10, 0.05));
      expect(results.wPrime, closeTo(2 * 20 * 7, 0.01));
      expect(results.peakKg, 30);
      expect(results.endForceKg, closeTo(10, 0.05));
    });

    test('leaves a pull with too little data without a mean', () {
      final samples = _trace(
        24,
        _square((_) => 10),
      ).where((s) => s.t < 230 || s.t > 236).toList();

      final results = analyseCriticalForce(samples, _windows(24));

      expect(results.pulls[23].meanKg, isNull);
      expect(results.criticalForce, closeTo(10, 0.05));
    });

    test('does not interpolate across a hole in the readings', () {
      final samples = _trace(
        24,
        _square((_) => 10),
      ).where((s) => s.t < 231 || s.t > 233).toList();

      final pull = analyseCriticalForce(samples, _windows(24)).pulls[23];

      // The readings either side of the hole are 2.2 s apart.
      expect(pull.coverage, closeTo(4.8 / 7, 0.01));
      expect(pull.impulseKgS, closeTo(48, 0.01));
    });

    test('fails when fewer than 4 of the last pulls have data', () {
      final samples = _trace(
        24,
        _square((_) => 10),
      ).where((s) => s.t < 200).toList();

      expect(
        () => analyseCriticalForce(samples, _windows(24)),
        throwsA(isA<CriticalForceAnalysisException>()),
      );
    });

    test('fails when nobody pulled', () {
      expect(
        () => analyseCriticalForce(_trace(24, (_) => 0.2), _windows(24)),
        throwsA(isA<CriticalForceAnalysisException>()),
      );
    });

    test('averages every pull of a test shorter than 6 pulls', () {
      final results = analyseCriticalForce(
        _trace(4, _square((pull) => 10.0 + pull)),
        _windows(4),
      );

      expect(results.criticalForce, closeTo(11.5, 0.05));
      expect(results.firstCountedPull, 1);
      expect(results.lastCountedPull, 4);
    });

    test('sorts the readings into the windows it is given', () {
      // A clock paused for 5 s during the rest after pull 1.
      final windows = <CriticalForceWindow>[
        (start: 0, end: 7),
        (start: 15, end: 22),
        (start: 25, end: 32),
        (start: 35, end: 42),
      ];
      final samples = [
        for (var i = 0; i <= 420; i++)
          (
            t: i * _period,
            kg:
                windows.any(
                  (w) =>
                      i * _period >= w.start - 1e-9 &&
                      i * _period <= w.end + 1e-9,
                )
                ? 12.0
                : 0.0,
          ),
      ];

      final results = analyseCriticalForce(samples, windows);

      expect(results.criticalForce, closeTo(12, 0.05));
      expect(results.lateOffCount, 0);
    });
  });
}
