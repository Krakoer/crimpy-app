// The approach follows Get a Grip's critical force analysis
// (https://github.com/plumbmybumb/get-a-grip, docs/CRITICAL_FORCE.md,
// sections 3, 4 and 7): every number comes from the force inside each pull's
// window, and Critical Force is the mean of the last six windows.
import 'dart:math';

import 'package:crimpy/models/critical_force_result.dart';

/// Computes Critical Force from a recorded test.
///
/// [samples] are the readings, sorted by time. [windows] are the pulls as the
/// metronome ran them, in order, on the same time footing. The window is the
/// pull: there is no force threshold to find one, and a pull that sags is
/// recorded as low force, which is the truthful value in an all-out test.
///
/// Throws a [CriticalForceAnalysisException] when the last pulls carry too
/// little data to average, or when nobody pulled.
CriticalForceResults analyseCriticalForce(
  List<CriticalForceSample> samples,
  List<CriticalForceWindow> windows,
) {
  if (windows.isEmpty) {
    throw const CriticalForceAnalysisException('No pull was run.');
  }

  final pulls = [
    for (var i = 0; i < windows.length; i++)
      summarisePull(
        i,
        samples,
        windows[i],
        nextStart: i + 1 < windows.length ? windows[i + 1].start : null,
      ),
  ];

  final firstCounted = max(0, pulls.length - CriticalForceRules.countedPulls);
  final countedMeans = pulls
      .sublist(firstCounted)
      .map((p) => p.meanKg)
      .nonNulls
      .toList();
  final countedSpan = pulls.length - firstCounted;
  if (countedMeans.length <
      min(CriticalForceRules.minValidCountedPulls, countedSpan)) {
    throw const CriticalForceAnalysisException(
      'The sensor sent too little data during the last pulls to compute a '
      'Critical Force.',
    );
  }
  final criticalForce = _mean(countedMeans);
  if (criticalForce < CriticalForceRules.onEdgeKg) {
    throw const CriticalForceAnalysisException(
      'No pull was recorded during the last pulls.',
    );
  }

  final endValues = pulls
      .sublist(max(0, pulls.length - CriticalForceRules.endForcePulls))
      .map((p) => p.endKg)
      .nonNulls
      .toList();

  var wPrime = 0.0;
  for (final window in windows) {
    wPrime += integrate(
      samples,
      window.start,
      window.end,
      above: criticalForce,
    ).area;
  }

  return CriticalForceResults(
    criticalForce: criticalForce,
    wPrime: wPrime,
    peakKg: pulls.map((p) => p.peakKg).reduce(max),
    endForceKg: endValues.isEmpty ? null : _mean(endValues),
    pulls: pulls,
    firstCountedPull: firstCounted + 1,
    lastCountedPull: pulls.length,
    averagedPullCount: countedMeans.length,
  );
}

/// One window's numbers. [nextStart] is when the following pull starts, which
/// closes the rest after this one; null for the final pull.
CriticalForcePull summarisePull(
  int index,
  List<CriticalForceSample> samples,
  CriticalForceWindow window, {
  double? nextStart,
}) {
  final length = window.end - window.start;
  final whole = integrate(samples, window.start, window.end);
  final tailStart = max(
    window.start,
    window.end - CriticalForceRules.endWindowSeconds,
  );
  final tail = integrate(samples, tailStart, window.end);
  final coverage = length > 0 ? whole.covered / length : 0.0;
  final tailEnough =
      tail.covered >= (window.end - tailStart) * CriticalForceRules.minCoverage;
  return CriticalForcePull(
    index: index,
    start: window.start,
    end: window.end,
    meanKg: coverage >= CriticalForceRules.minCoverage && whole.covered > 0
        ? whole.area / whole.covered
        : null,
    peakKg: whole.peak,
    endKg: tailEnough && tail.covered > 0 ? tail.area / tail.covered : null,
    impulseKgS: whole.area,
    coverage: min(1, coverage),
    heldAfterBellSeconds: nextStart == null
        ? null
        : timeHeldFrom(
            CriticalForceRules.onEdgeKg,
            samples,
            window.end,
            nextStart,
          ),
  );
}

/// The area, covered time and peak of the force trace inside [from, to).
typedef ForceIntegral = ({double area, double covered, double peak});

/// Trapezoids between neighbouring readings, clipped to [from, to). With
/// [above], only the area of the part over that line counts, crossings
/// included. Two readings further apart than [CriticalForceRules.gapSeconds]
/// leave a hole: no area and no coverage.
ForceIntegral integrate(
  List<CriticalForceSample> samples,
  double from,
  double to, {
  double above = 0,
}) {
  var area = 0.0;
  var covered = 0.0;
  var peak = 0.0;
  if (to <= from || samples.length < 2) {
    return (area: area, covered: covered, peak: peak);
  }
  for (
    var i = max(0, _firstIndexNotBefore(samples, from) - 1);
    i + 1 < samples.length && samples[i].t < to;
    i++
  ) {
    final a = samples[i];
    final b = samples[i + 1];
    final dt = b.t - a.t;
    if (dt <= 0 || dt > CriticalForceRules.gapSeconds) continue;
    final s = max(a.t, from);
    final e = min(b.t, to);
    if (e <= s) continue;
    final ks = a.kg + (b.kg - a.kg) * (s - a.t) / dt;
    final ke = a.kg + (b.kg - a.kg) * (e - a.t) / dt;
    covered += e - s;
    area += _areaAbove(above, ks, ke, e - s);
    if (a.t >= from) peak = max(peak, a.kg);
    if (b.t < to) peak = max(peak, b.kg);
  }
  return (area: area, covered: covered, peak: peak);
}

/// Seconds the linear force trace stays at or above [threshold] from [from]
/// on, up to [to], before it first drops under it. A hole in the readings
/// ends the count, since nothing says the athlete was still on the edge.
double timeHeldFrom(
  double threshold,
  List<CriticalForceSample> samples,
  double from,
  double to,
) {
  var seconds = 0.0;
  if (to <= from || samples.length < 2) return seconds;
  var at = from;
  for (
    var i = max(0, _firstIndexNotBefore(samples, from) - 1);
    i + 1 < samples.length && samples[i].t < to;
    i++
  ) {
    final a = samples[i];
    final b = samples[i + 1];
    final dt = b.t - a.t;
    if (b.t <= at) continue;
    if (dt <= 0 || dt > CriticalForceRules.gapSeconds || a.t > at) break;
    final e = min(b.t, to);
    final ks = a.kg + (b.kg - a.kg) * (at - a.t) / dt;
    final ke = a.kg + (b.kg - a.kg) * (e - a.t) / dt;
    if (ks < threshold) break;
    if (ke < threshold) {
      seconds += (e - at) * (ks - threshold) / (ks - ke);
      break;
    }
    seconds += e - at;
    at = e;
  }
  return seconds;
}

/// The integral of max(0, F - threshold) over one linear segment.
double _areaAbove(double threshold, double ks, double ke, double duration) {
  final a = ks - threshold;
  final b = ke - threshold;
  if (a >= 0 && b >= 0) return (a + b) / 2 * duration;
  if (a <= 0 && b <= 0) return 0;
  // One crossing: only the triangle above the line counts.
  final high = max(a, b);
  final fraction = high / (a.abs() + b.abs());
  return high * fraction * duration / 2;
}

/// Binary search: the index of the first reading at or after [t].
int _firstIndexNotBefore(List<CriticalForceSample> samples, double t) {
  var lo = 0;
  var hi = samples.length;
  while (lo < hi) {
    final mid = (lo + hi) ~/ 2;
    if (samples[mid].t < t) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  return lo;
}

double _mean(List<double> values) =>
    values.reduce((a, b) => a + b) / values.length;
