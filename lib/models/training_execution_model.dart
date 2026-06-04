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

// Defined for future use (section headers, free items without duration, exercise reps with no
// timed countdown). Not yet wired to the play screen UI.
final class ConfirmItem extends TrainingExecutionItem {
  final String label;
  final String? instructions;

  const ConfirmItem({required this.label, this.instructions});

  @override
  int get durationSeconds => 0;
}
