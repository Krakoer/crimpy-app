import 'package:crimpy/logger.dart';
import 'package:vibration/vibration.dart';

/// The moments the run screen marks with a beep, each felt as a pattern of its
/// own so they can be told apart with the phone on the floor.
enum RunCue {
  /// One of the last seconds of a step, warning that the next is coming.
  countdown,

  /// A pull, or any other effort, starts.
  pullStart,

  /// A pull ends and a rest starts: let go.
  letGo,
}

/// Plays [RunCue]s as vibrations.
abstract class RunHaptics {
  Future<void> play(RunCue cue);
}

/// Vibrates through the phone's vibrator, which on Android needs the VIBRATE
/// permission: without it the calls fail silently.
class VibrationRunHaptics extends RunHaptics {
  /// Alternating off and on times, in milliseconds, starting with off.
  static const patterns = {
    // A tick, as short as the beep it doubles.
    RunCue.countdown: [0, 60],
    // One long buzz: go.
    RunCue.pullStart: [0, 450],
    // Two short buzzes: let go.
    RunCue.letGo: [0, 140, 110, 140],
  };

  @override
  Future<void> play(RunCue cue) async {
    try {
      await Vibration.vibrate(pattern: patterns[cue]!);
    } catch (e) {
      // A cue that cannot be felt must never stop the run.
      AppLoggerHelper.warning("Could not vibrate: $e");
    }
  }
}

/// Plays through [inner] only while [enabled] says so. It is asked at every
/// cue, so a setting still loading when the run starts is honoured as soon as
/// it lands, and one changed mid-run takes effect on the next cue.
class GatedRunHaptics extends RunHaptics {
  GatedRunHaptics(this.inner, {required this.enabled});

  final RunHaptics inner;
  final bool Function() enabled;

  @override
  Future<void> play(RunCue cue) async {
    if (enabled()) await inner.play(cue);
  }
}
