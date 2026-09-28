import 'package:crimpy/models/training_execution_model.dart';

/// Share of the target the load has to stay under for the alarm to fire.
const loadDropFireRatio = 0.90;

/// Share of the target the load has to be back at for the alarm to clear. Set
/// above [loadDropFireRatio] so a load wobbling around one line cannot flash
/// the alarm on and off. The load has to reach it once in the rep before the
/// alarm can fire at all.
const loadDropClearRatio = 0.95;

/// How long the load has to stay under [loadDropFireRatio] before the alarm
/// fires, so a single low sample does not raise it.
const loadDropDwell = Duration(milliseconds: 500);

/// The load [step] is watched against, or 0 when it is not watched: only a
/// hang that reads the sensor and prescribes a load can drop below it.
double loadDropTargetOf(TrainingExecutionItem? step) =>
    step is TimedItem &&
        step.isHang &&
        step.collectSensorData &&
        step.targetLoad > 0
    ? step.targetLoad
    : 0;

/// Whether the load of one rep has dropped below its target. Fed every sample
/// of the rep, in order, with the time it was taken. Only a load that got on
/// target can drop below it, so the alarm stays down while the athlete loads
/// up, and through a rep that never reaches the target. See Krakoer/crimpy#175.
class LoadDropAlarm {
  LoadDropAlarm(this.target) : assert(target > 0);

  final double target;

  bool _reachedTarget = false;
  DateTime? _belowSince;
  bool _raised = false;

  bool get raised => _raised;

  /// Takes the sample [load] read at [at] and answers whether the alarm is
  /// raised after it.
  bool update(double load, DateTime at) {
    if (load >= target * loadDropClearRatio) {
      _reachedTarget = true;
      _belowSince = null;
      _raised = false;
    } else if (!_reachedTarget) {
      return false;
    } else if (load < target * loadDropFireRatio) {
      final since = _belowSince ??= at;
      if (at.difference(since) >= loadDropDwell) _raised = true;
    } else {
      // Between the two lines the alarm holds whatever it was, and the dwell
      // starts over: the load has to stay under the fire line throughout.
      _belowSince = null;
    }
    return _raised;
  }
}
