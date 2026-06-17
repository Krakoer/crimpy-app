import 'package:crimpy/models/common.dart';

sealed class TrainingExecutionItem {
  const TrainingExecutionItem();
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

  /// Position context shown during the step, e.g. "SET 2/3 - REP 4/6" or
  /// "ROUND 1/3".
  final String? subtitle;

  /// Optional coach comment shown to the athlete during the step.
  final String? comment;

  const TimedItem({
    required this.label,
    required this.durationSeconds,
    required this.targetLoad,
    required this.handSide,
    required this.gripPosition,
    required this.collectSensorData,
    this.subtitle,
    this.comment,
  });
}

final class RestItem extends TrainingExecutionItem {
  @override
  final int durationSeconds;

  const RestItem({required this.durationSeconds});
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
  });

  @override
  int get durationSeconds => 0;
}
