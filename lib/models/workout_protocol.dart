import 'package:crimpy/models/common.dart';

class RepModel {
  String? id;
  int durationInSeconds;
  bool isRest;
  HandSide handSide;
  double targetWeight;
  int index;
  GripPosition gripPosition;

  /// Whether the live force gauge is shown and sensor data collected.
  final bool showGauge;

  /// Self-paced step: no countdown, the user taps "Done" to advance.
  final bool isConfirm;

  /// Optional label shown during the step (e.g. exercise name).
  final String? label;

  /// Optional rep count shown for self-paced exercises.
  final int? reps;

  /// Optional load label shown for self-paced exercises (e.g. "+10 kg").
  final String? load;

  /// Position context shown during the step, e.g. "SET 2/3 - REP 4/6".
  final String? subtitle;

  /// Optional coach comment shown to the athlete during the step.
  final String? comment;

  RepModel({
    this.id,
    required this.durationInSeconds,
    required this.isRest,
    required this.handSide,
    required this.targetWeight,
    required this.index,
    this.gripPosition = GripPosition.halfCrimp, // Default to half crimp
    this.showGauge = false,
    this.isConfirm = false,
    this.label,
    this.reps,
    this.load,
    this.subtitle,
    this.comment,
  });
}

/// A flat sequence of steps, as used by the assessment protocols.
///
/// Assessments are a straight run of pulls and rests with no nesting, so they
/// keep this shape rather than the [Training] item tree.
class TrainingWithReps {
  final String id;
  final String name;
  final List<RepModel> reps;

  TrainingWithReps({required this.id, required this.name, required this.reps});

  Duration get totalDuration =>
      Duration(seconds: reps.fold(0, (prev, r) => prev + r.durationInSeconds));
}
