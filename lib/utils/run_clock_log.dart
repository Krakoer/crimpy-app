/// Pairs the wall clock with a run's own clock, which stops whenever the run
/// is paused. A reading timestamped on the wall clock can then be placed on
/// the run's clock, and a reading taken while the run was stopped is left out
/// rather than stretching the step it was paused in.
class RunClockLog {
  final List<_Stretch> _stretches = [];

  /// The run clock started at [wallAt], reading [runClockMs].
  void started(DateTime wallAt, int runClockMs) {
    if (_stretches.isNotEmpty && _stretches.last.wallEnd == null) return;
    _stretches.add(_Stretch(wallAt, runClockMs));
  }

  /// The run clock stopped at [wallAt].
  void stopped(DateTime wallAt) {
    final last = _stretches.lastOrNull;
    if (last != null && last.wallEnd == null) last.wallEnd = wallAt;
  }

  /// The run clock reading, in milliseconds, when [wallAt] happened, or null
  /// when the run clock was not running then.
  double? runClockAt(DateTime wallAt) {
    for (final stretch in _stretches.reversed) {
      if (wallAt.isBefore(stretch.wallStart)) continue;
      final end = stretch.wallEnd;
      if (end != null && !wallAt.isBefore(end)) return null;
      return stretch.runClockStartMs +
          wallAt.difference(stretch.wallStart).inMicroseconds / 1000;
    }
    return null;
  }

  /// How long the run clock stood stopped after it had passed [runClockMs], in
  /// milliseconds. A stop that ended right at [runClockMs] came before it.
  int pausedMsAfter(int runClockMs) {
    var paused = 0;
    for (var i = 0; i + 1 < _stretches.length; i++) {
      final stoppedAt = _stretches[i].wallEnd;
      final resumed = _stretches[i + 1];
      if (stoppedAt == null || resumed.runClockStartMs <= runClockMs) continue;
      paused += resumed.wallStart.difference(stoppedAt).inMilliseconds;
    }
    return paused;
  }
}

class _Stretch {
  _Stretch(this.wallStart, this.runClockStartMs);

  final DateTime wallStart;
  final int runClockStartMs;
  DateTime? wallEnd;
}
