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

  /// Seconds the athlete stayed on the edge after the bell that ended this
  /// pull, without letting go, or null for the final pull, which has no rest
  /// after it. Taking the edge again later in the rest does not count.
  final double? heldAfterBellSeconds;

  const CriticalForcePull({
    required this.index,
    required this.start,
    required this.end,
    required this.meanKg,
    required this.peakKg,
    required this.endKg,
    required this.impulseKgS,
    required this.coverage,
    required this.heldAfterBellSeconds,
  });

  /// Whether the athlete stayed on the edge well into the rest after the bell.
  /// That force counts for nothing, and the rest it ate was not kept.
  bool get lateOff =>
      heldAfterBellSeconds != null &&
      heldAfterBellSeconds! > CriticalForceRules.restKeptLimitSeconds;
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

  /// 1-based, inclusive: the last pulls, which [criticalForce] is the mean
  /// of.
  final int firstCountedPull;
  final int lastCountedPull;

  /// How many of those pulls carried enough data to be averaged. Fewer than
  /// the span holds when the sensor left holes in some of them.
  final int averagedPullCount;

  const CriticalForceResults({
    required this.criticalForce,
    required this.wPrime,
    required this.peakKg,
    required this.endForceKg,
    required this.pulls,
    required this.firstCountedPull,
    required this.lastCountedPull,
    required this.averagedPullCount,
  });

  /// How many pulls were held on into the following rest.
  int get lateOffCount => pulls.where((p) => p.lateOff).length;

  /// What the result stores beside the Critical Force (Krakoer/crimpy#145):
  /// W', the end force of the last pulls and the numbers of every pull, so
  /// they can be shown later and another definition recomputed from them.
  /// [workSeconds] and [restSeconds] name the protocol the pulls were run on.
  Map<String, Object?> toDetails({
    required int workSeconds,
    required int restSeconds,
  }) => {
    'definition': 'last${CriticalForceRules.countedPulls}',
    'protocol': '$workSeconds:${restSeconds}x${pulls.length}',
    'w_prime_kg_s': _rounded(wPrime),
    'end_force_kg': _roundedOrNull(endForceKg),
    'peak_kg': _rounded(peakKg),
    'first_counted_pull': firstCountedPull,
    'last_counted_pull': lastCountedPull,
    'averaged_pull_count': averagedPullCount,
    'pulls': [
      for (final pull in pulls)
        {
          'mean_kg': _roundedOrNull(pull.meanKg),
          'peak_kg': _rounded(pull.peakKg),
          'end_kg': _roundedOrNull(pull.endKg),
          'impulse_kg_s': _rounded(pull.impulseKgS),
          'coverage': _rounded(pull.coverage),
          'held_after_bell_s': _roundedOrNull(pull.heldAfterBellSeconds),
          'late_off': pull.lateOff,
        },
    ],
  };

  /// The W' a stored result carries in its details, or null when it has none.
  static double? wPrimeOf(Map<String, Object?>? details) {
    final value = details?['w_prime_kg_s'];
    return value is num ? value.toDouble() : null;
  }

  static double _rounded(double value) => (value * 100).round() / 100;
  static double? _roundedOrNull(double? value) =>
      value == null ? null : _rounded(value);
}

/// Every tunable of the Critical Force analysis, named once.
abstract final class CriticalForceRules {
  /// Critical Force is the mean force of this many final pulls.
  static const countedPulls = 6;

  /// Of those final pulls, at least this many need enough data to average,
  /// or all of them in a test shorter than that. A pull lost to the radio is
  /// not a pull the athlete failed.
  static const minValidCountedPulls = 4;

  /// End force: the last second of each of the last three pulls.
  static const endForcePulls = 3;
  static const endWindowSeconds = 1.0;

  /// On the edge, for counting load held after the bell, and the least a Critical
  /// Force can be for the test to count as pulled at all.
  static const onEdgeKg = 2.0;

  /// Holding on for more than this after the bell means the rest was not
  /// kept.
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
