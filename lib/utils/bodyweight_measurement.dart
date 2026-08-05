import 'package:crimpy/models/ble_data_model.dart';

/// Whether [kilograms] can be an athlete bodyweight. A typed weight is what
/// every %BW load is scaled by, so a slipped decimal point would put a target
/// on the gauge that can never be matched.
bool isPlausibleBodyweight(double kilograms) =>
    kilograms >= BodyweightMeasurement.minimumPlausibleKg &&
    kilograms <= BodyweightMeasurement.maximumPlausibleKg;

enum BodyweightMeasurementPhase {
  /// Nothing usable on the sensor yet, or the reading is still moving.
  waiting,

  /// The reading has settled and the clean window is running.
  holding,

  /// A full clean window was recorded and [BodyweightMeasurement.result] holds
  /// the weight.
  done,
}

/// Turns a stream of sensor samples into a bodyweight.
///
/// A hang is loaded dynamically, so the peak of a fixed window measures the
/// overshoot of stepping onto the board rather than the athlete weight. This
/// waits for the reading to hold still instead, and only then records a clean
/// window, so the result is a plateau and not a transient.
///
/// Anything that breaks the hold, a pull up, a foot back on the ground, letting
/// go, puts the reading outside the band and starts the window over rather than
/// keeping the part already recorded.
class BodyweightMeasurement {
  /// How long the reading must hold still before the window starts. Covers the
  /// walk from the phone to the board, which a fixed countdown would spend
  /// measuring.
  static const Duration settleDuration = Duration(milliseconds: 1200);

  /// How long the reading must stay still to be recorded.
  static const Duration holdDuration = Duration(seconds: 5);

  /// A single sample outside the band is sensor noise. It only counts as
  /// leaving the band once it persists, so the window is not restarted by a
  /// lone spike.
  static const Duration _toleratedDeviation = Duration(milliseconds: 200);

  /// A gap longer than this means the samples stopped coming, because the
  /// sensor dropped or the app was sent to the background. The window covers a
  /// continuous hold, so it starts over rather than counting across the hole.
  static const Duration _maxSampleGap = Duration(milliseconds: 500);

  /// Below this the sensor is not carrying an athlete: unloaded, or being held
  /// by hand. Above it, the reading cannot be a bodyweight.
  static const double minimumPlausibleKg = 20;
  static const double maximumPlausibleKg = 250;

  /// Half width of the band the reading must stay in. Loose enough for the
  /// sway and breathing of someone standing still, far tighter than the tens of
  /// kilograms a pull up moves.
  static const double _absoluteToleranceKg = 2.0;
  static const double _relativeTolerance = 0.03;

  final List<BleDataPoint> _samples = [];
  DateTime? _outOfBandSince;
  double? _result;

  double? get result => _result;

  BodyweightMeasurementPhase get phase {
    if (_result != null) return BodyweightMeasurementPhase.done;
    if (_elapsed < settleDuration) return BodyweightMeasurementPhase.waiting;
    return BodyweightMeasurementPhase.holding;
  }

  /// What the reading currently averages, or null before it has settled. Shown
  /// as the value being recorded.
  double? get stableValue =>
      phase == BodyweightMeasurementPhase.waiting ? null : _reference;

  /// Seconds still to hold, counting down from [holdDuration] once the reading
  /// has settled.
  int get secondsRemaining {
    if (_result != null) return 0;
    final held = _elapsed - settleDuration;
    if (held.isNegative) return holdDuration.inSeconds;
    final left = holdDuration - held;
    return left.isNegative ? 0 : (left.inMilliseconds / 1000).ceil();
  }

  /// How much of the clean window is recorded, 0 to 1.
  double get progress {
    if (_result != null) return 1;
    final held = _elapsed - settleDuration;
    if (held.isNegative) return 0;
    return (held.inMilliseconds / holdDuration.inMilliseconds).clamp(0.0, 1.0);
  }

  void add(BleDataPoint sample) {
    if (_result != null) return;

    if (!_isPlausible(sample.value)) {
      _restart();
      return;
    }
    if (_samples.isEmpty) {
      _samples.add(sample);
      _outOfBandSince = null;
      return;
    }
    if (sample.timestamp.difference(_samples.last.timestamp) > _maxSampleGap) {
      _restart();
      _samples.add(sample);
      return;
    }

    final reference = _reference!;
    if ((sample.value - reference).abs() > _toleranceFor(reference)) {
      _outOfBandSince ??= sample.timestamp;
      if (sample.timestamp.difference(_outOfBandSince!) >=
          _toleratedDeviation) {
        _restart();
        _samples.add(sample);
      }
      return;
    }

    _outOfBandSince = null;
    _samples.add(sample);
    if (_elapsed >= settleDuration + holdDuration) _result = _plateau();
  }

  void reset() {
    _restart();
    _result = null;
  }

  void _restart() {
    _samples.clear();
    _outOfBandSince = null;
  }

  bool _isPlausible(double value) => isPlausibleBodyweight(value);

  double _toleranceFor(double reference) =>
      _absoluteToleranceKg > reference * _relativeTolerance
      ? _absoluteToleranceKg
      : reference * _relativeTolerance;

  Duration get _elapsed => _samples.length < 2
      ? Duration.zero
      : _samples.last.timestamp.difference(_samples.first.timestamp);

  double? get _reference {
    if (_samples.isEmpty) return null;
    final total = _samples.fold<double>(0, (sum, s) => sum + s.value);
    return total / _samples.length;
  }

  /// The weight the athlete held, taken over the clean window only. The median
  /// rather than the mean, so a stray sample cannot move it.
  double _plateau() {
    final windowStart = _samples.first.timestamp.add(settleDuration);
    final held =
        _samples
            .where((s) => !s.timestamp.isBefore(windowStart))
            .map((s) => s.value)
            .toList()
          ..sort();
    if (held.isEmpty) return _reference!;
    final middle = held.length ~/ 2;
    return held.length.isOdd
        ? held[middle]
        : (held[middle - 1] + held[middle]) / 2;
  }
}
