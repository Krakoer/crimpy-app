import 'package:crimpy/models/common.dart';

sealed class TrainingExecutionItem {
  /// Id of the training item this step was expanded from, carried onto the rep
  /// it records so a played session can be read block by block instead of as
  /// one pooled list. Null for a step built outside a training.
  final String? trainingItemId;

  const TrainingExecutionItem({this.trainingItemId});

  int get durationSeconds;
}

final class TimedItem extends TrainingExecutionItem {
  final String label;
  @override
  final int durationSeconds;
  final double targetLoad;
  final HandSide handSide;
  final GripPosition gripPosition;
  final bool collectSensorData;

  /// Edge depth prescribed for this hang, when the coach set one.
  final int? edgeSizeMm;

  /// Whether the step is a hangboard hang, so its grip and edge are a real
  /// prescription rather than the filler a duration exercise carries.
  final bool isHang;

  /// Position context shown during the step, e.g. "SET 2/3 - REP 4/6" or
  /// "ROUND 1/3".
  final String? subtitle;

  /// Optional coach comment shown to the athlete during the step.
  final String? comment;

  /// Whether the step measured the athlete. Collecting sensor data is decided
  /// when the training is expanded, from the sensor the run started with, so a
  /// step still measures nothing when the sensor drops before it runs and
  /// [sensorDelivered] stays false for the rest of the session.
  bool measured({required bool sensorDelivered}) =>
      collectSensorData && sensorDelivered;

  /// Target to store on the rep this step records. A step that measured nothing
  /// carries no target: stored with one, it would read as a missed target to
  /// every screen that grades a run.
  double recordedTargetLoad({required bool sensorDelivered}) =>
      measured(sensorDelivered: sensorDelivered) ? targetLoad : 0;

  /// Whether the step prescribed a load the run failed to measure. It records
  /// the same empty target as a step nothing was meant to measure, so the rep
  /// carries this to say the target was lost rather than never given: a run is
  /// graded on the reps it could measure, and this one was performed blind.
  bool targetUnmeasured({required bool sensorDelivered}) =>
      collectSensorData && targetLoad > 0 && !sensorDelivered;

  const TimedItem({
    required this.label,
    required this.durationSeconds,
    required this.targetLoad,
    required this.handSide,
    required this.gripPosition,
    required this.collectSensorData,
    this.edgeSizeMm,
    this.isHang = false,
    this.subtitle,
    this.comment,
    super.trainingItemId,
  });
}

final class RestItem extends TrainingExecutionItem {
  @override
  final int durationSeconds;

  const RestItem({required this.durationSeconds, super.trainingItemId});
}

/// A self-paced step the user completes manually (e.g. a rep-based exercise or
/// a free item without a duration). The user taps "Done" to advance.
final class ConfirmItem extends TrainingExecutionItem {
  final String label;
  final String? instructions;
  final int? reps;
  final String? load;

  /// Position context shown during the step, e.g. "ROUND 1/3".
  final String? subtitle;

  /// Optional coach comment shown to the athlete during the step.
  final String? comment;

  const ConfirmItem({
    required this.label,
    this.instructions,
    this.reps,
    this.load,
    this.subtitle,
    this.comment,
    super.trainingItemId,
  });

  @override
  int get durationSeconds => 0;
}
