/// One reading of a Critical Force test, [t] in seconds on the same footing as
/// the pull windows it is sorted into.
typedef CriticalForceSample = ({double t, double kg});

/// The span of one pull, in seconds on the samples' footing: from the bell
/// that starts it to the bell that ends it.
typedef CriticalForceWindow = ({double start, double end});

/// One pull, summarised from the force inside its window only. Force pulled
/// after the bell is not credited to it.
class CriticalForcePull {
  /// 0-based position of the pull in the test.
  final int index;

  /// When the pull's window opened and closed, in seconds on the samples'
  /// footing.
  final double start;
  final double end;

  /// Mean force over the part of the window that has data, or null when too
  /// little of the window was covered by readings to average.
  final double? meanKg;

  /// The hardest reading inside the window.
  final double peakKg;

  /// Mean force over the window's last second, or null when too little of it
  /// was covered.
  final double? endKg;

  /// Force times time measured inside the window, in kg.s.
  final double impulseKgS;

  /// Fraction of the window covered by readings, 0 to 1.
  final double coverage;

  /// Seconds spent on the edge during the rest after this pull, or null for
  /// the final pull, which has no rest after it.
  final double? restLoadSeconds;

  const CriticalForcePull({
    required this.index,
    required this.start,
    required this.end,
    required this.meanKg,
    required this.peakKg,
    required this.endKg,
    required this.impulseKgS,
    required this.coverage,
    required this.restLoadSeconds,
  });

  /// Whether the athlete stayed on the edge well into the rest after the bell.
  /// That force counts for nothing, and the rest it ate was not kept.
  bool get lateOff =>
      restLoadSeconds != null &&
      restLoadSeconds! > CriticalForceRules.restKeptLimitSeconds;
}

/// Output of the Critical Force analysis over a recorded test.
class CriticalForceResults {
  /// The mean force of the last pulls, the published definition (Giles 2021,
  /// also used by Tindeq and Lattice).
  final double criticalForce;

  /// Impulse above [criticalForce] inside the pull windows, in kg.s.
  final double wPrime;

  /// The hardest single reading of the test.
  final double peakKg;

  /// Mean end force of the last three pulls, or null when none had enough
  /// data. Closer to the load that can really be sustained than the mean.
  final double? endForceKg;

  /// Every pull run, in order.
  final List<CriticalForcePull> pulls;

  /// 1-based, inclusive: the pulls [criticalForce] is the mean of.
  final int firstCountedPull;
  final int lastCountedPull;

  const CriticalForceResults({
    required this.criticalForce,
    required this.wPrime,
    required this.peakKg,
    required this.endForceKg,
    required this.pulls,
    required this.firstCountedPull,
    required this.lastCountedPull,
  });

  /// How many pulls were held on into the following rest.
  int get lateOffCount => pulls.where((p) => p.lateOff).length;
}

/// Every tunable of the Critical Force analysis, named once.
abstract final class CriticalForceRules {
  /// Critical Force is the mean force of this many final pulls.
  static const countedPulls = 6;

  /// Of those final pulls, at least this many need enough data to average. A
  /// pull lost to the radio is not a pull the athlete failed.
  static const minValidCountedPulls = 4;

  /// End force: the last second of each of the last three pulls.
  static const endForcePulls = 3;
  static const endWindowSeconds = 1.0;

  /// On the edge, for counting load held into a rest, and the least a Critical
  /// Force can be for the test to count as pulled at all.
  static const onEdgeKg = 2.0;

  /// More than this spent on the edge during a rest means it was not kept.
  static const restKeptLimitSeconds = 1.0;

  /// Readings further apart than this leave a hole that nothing is
  /// interpolated across. Samples are timestamped on arrival, so this leaves
  /// room for the radio delivering them in bursts.
  static const gapSeconds = 0.5;

  /// A window covered by readings for less than this fraction has no mean.
  static const minCoverage = 0.5;
}

/// Why a recorded test cannot give a Critical Force.
class CriticalForceAnalysisException implements Exception {
  final String message;

  const CriticalForceAnalysisException(this.message);

  @override
  String toString() => message;
}
