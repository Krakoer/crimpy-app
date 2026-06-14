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

  const TimedItem({
    required this.label,
    required this.durationSeconds,
    required this.targetLoad,
    required this.handSide,
    required this.gripPosition,
    required this.collectSensorData,
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

  const ConfirmItem({
    required this.label,
    this.instructions,
    this.reps,
    this.load,
  });

  @override
  int get durationSeconds => 0;
}
