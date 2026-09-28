import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

/// The phase a step of a timed assessment run (Max Force, Critical Force) is
/// painted in, from the one map the training run screen reads. See
/// Krakoer/crimpy#176.
///
/// A rest before the first pull is the lead-in, the athlete getting into
/// position, so it is armed like the training's READY. A rest after a pull is
/// recovery, so it is calm. A pull is armed too: these tests pull all out with
/// no target load to hold, and sage means on target, so a pull without one
/// stays on the neutral working ink. A lost sensor is the alarm on any step,
/// since both tests record every step and a pull with no sensor measures
/// nothing.
RunPhase assessmentStepPhase({
  required List<TrainingExecutionItem> steps,
  required int stepIndex,
  required bool sensorLost,
}) {
  if (sensorLost) return RunPhase.alarm;
  if (steps[stepIndex] is! RestItem) return RunPhase.armed;
  final isLeadIn = !steps.take(stepIndex).any((step) => step is! RestItem);
  return isLeadIn ? RunPhase.armed : RunPhase.calm;
}

/// The phase of the 60% Endurance hold, which has a target band: sage while
/// the load sits inside it, whether or not the clock has started yet, and ink
/// while it is outside. Leaving the band is how the test ends, the measurement
/// itself rather than something gone wrong, so it is not the alarm. Only a
/// lost sensor is. See Krakoer/crimpy#176.
RunPhase enduranceHoldPhase({required bool inZone, required bool sensorLost}) {
  if (sensorLost) return RunPhase.alarm;
  return inZone ? RunPhase.engaged : RunPhase.armed;
}
