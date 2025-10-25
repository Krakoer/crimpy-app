import "package:crimpy/database/database.dart";
import "package:crimpy/logger.dart";
import "package:crimpy/models/common.dart";
import "package:crimpy/models/training_feedback_model.dart";

import "ble_data_model.dart";
import "assessment_model.dart";

/// Represents a required assessment with optional grip position.
class AssessmentRequirement {
  final AssessmentType type;
  final GripPosition? gripPosition;

  const AssessmentRequirement({required this.type, this.gripPosition});

  @override
  bool operator ==(Object other) {
    return other is AssessmentRequirement &&
        other.type == type &&
        other.gripPosition == gripPosition;
  }

  @override
  int get hashCode => Object.hash(type, gripPosition);
}

class SessionModel {
  final int? id;
  final String name;
  final String? notes;
  final DateTime date;
  final List<BleDataPoint>? dataPoints;
  final List<RepData>? reps;
  final bool isAssessment;
  final SessionType sessionType;
  final int? durationInSeconds;

  SessionModel({
    this.id,
    this.notes,
    this.dataPoints,
    this.reps,
    required this.name,
    required this.isAssessment,
    this.sessionType = SessionType.crimpy,
    this.durationInSeconds,
    date,
  }) : date = date ?? DateTime.now();

  int get duration =>
      durationInSeconds ??
      (reps == null ? 0 : reps!.fold(0, (prev, r) => prev + r.duration));
}

class RepModel {
  int? id;
  int durationInSeconds;
  bool isRest;
  HandSide handSide;
  double targetWeight;
  int index;
  GripPosition gripPosition;

  RepModel({
    this.id,
    required this.durationInSeconds,
    required this.isRest,
    required this.handSide,
    required this.targetWeight,
    required this.index,
    this.gripPosition = GripPosition.halfCrimp, // Default to half crimp
  });
}

class TrainingWithReps {
  final int id;
  final String name;
  final List<RepModel> reps;
  final RepeaterModel? repeater;
  final bool isFav;
  // Used by builtin trainings
  final LoadAdjustmentFunction? computeNewWeights;

  TrainingWithReps({
    required this.id,
    required this.name,
    required this.reps,
    required this.isFav,
    this.repeater,
    this.computeNewWeights,
  });

  Duration get totalDuration =>
      Duration(seconds: reps.fold(0, (prev, r) => prev + r.durationInSeconds));
}

class RepDataModel {
  final double averageWeight;
  final bool isRest;
  final HandSide handSide;
  final int duration;
  final double targetWeight;
  final int index;
  final GripPosition gripPosition;

  RepDataModel({
    required this.averageWeight,
    required this.duration,
    required this.index,
    required this.isRest,
    required this.handSide,
    required this.targetWeight,
    this.gripPosition = GripPosition.halfCrimp, // Default to half crimp
  });
}

class RepeaterTraining {
  final RepeaterModel repeater;
  final int id;
  final String name;

  RepeaterTraining({
    required this.id,
    required this.name,
    required this.repeater,
  });
}

class RepeaterModel {
  final int sets;
  final int restBteweenSets;
  final int repsBySet;
  final int workTime;
  final int restTime;
  final bool splitHand;
  final double? weightRight;
  final double? weightLeft;
  final GripPosition gripPosition;

  RepeaterModel({
    required this.sets,
    required this.restBteweenSets,
    required this.repsBySet,
    required this.workTime,
    required this.restTime,
    required this.splitHand,
    this.weightRight,
    this.weightLeft,
    this.gripPosition = GripPosition.halfCrimp, // Default to half crimp
  });

  bool isValid() {
    // Validation checks
    if (sets <= 0 || repsBySet <= 0 || workTime <= 0) {
      AppLoggerHelper.warning("INVALID Repeater model");
      return false; // Invalid basic parameters
    }

    if (splitHand) {
      // For split hand, calculate the duration of one hand's set
      int setDuration = repsBySet * workTime + (repsBySet - 1) * restTime;

      // Check if restBteweenSets is sufficient for split hand training
      // We need at least enough time for the other hand to complete their set
      if (restBteweenSets < setDuration) {
        AppLoggerHelper.warning("INVALID Repeater model");
        return false; // Impossible timing for split hand
      }

      // Check if we have weights for both hands
      if (weightRight == null || weightLeft == null) {
        AppLoggerHelper.warning("INVALID Repeater model");
        return false; // Split hand requires weights for both hands
      }
    }

    return true;
  }

  /// Generate the repetitions list for the repeater training.
  List<RepTemplate> generateReps() {
    List<RepTemplate> reps = [];
    int currentIndex = 0;

    if (!isValid()) {
      return [];
    }

    if (splitHand) {
      int setDuration = repsBySet * workTime + (repsBySet - 1) * restTime;
      // For split hand, we alternate between right and left hand sets
      // with rest between sets of the same hand distributed evenly
      int restBetweenHandSets =
          (restBteweenSets - setDuration) ~/
          2; // Divide rest time between the two transitions

      for (int set = 0; set < sets; set++) {
        // Right hand set
        for (int rep = 0; rep < repsBySet; rep++) {
          reps.add(
            RepTemplate(
              duration: workTime,
              isRest: false,
              handSide: HandSide.right,
              targetWeight: weightRight ?? 0.0,
              index: currentIndex++,
              id: 0,
              trainingId: 0,
              gripPosition: gripPosition,
            ),
          );

          // Rest between reps within the set (if not the last rep)
          if (rep < repsBySet - 1) {
            reps.add(
              RepTemplate(
                duration: restTime,
                isRest: true,
                handSide: HandSide.left,
                targetWeight: 0.0,
                index: currentIndex++,
                id: 0,
                trainingId: 0,
              ),
            );
          }
        }

        // Rest between right hand set and left hand set
        reps.add(
          RepTemplate(
            duration: restBetweenHandSets,
            isRest: true,
            handSide: HandSide.left,
            targetWeight: 0.0,
            index: currentIndex++,
            id: 0,
            trainingId: 0,
          ),
        );

        // Left hand set
        for (int rep = 0; rep < repsBySet; rep++) {
          reps.add(
            RepTemplate(
              duration: workTime,
              isRest: false,
              handSide: HandSide.left,
              targetWeight: weightLeft ?? 0.0,
              index: currentIndex++,
              id: 0,
              trainingId: 0,
              gripPosition: gripPosition,
            ),
          );

          // Rest between reps within the set (if not the last rep)
          if (rep < repsBySet - 1) {
            reps.add(
              RepTemplate(
                duration: restTime,
                isRest: true,
                handSide: HandSide.left,
                targetWeight: 0.0,
                index: currentIndex++,
                id: 0,
                trainingId: 0,
              ),
            );
          }
        }

        // Rest between left hand set and next right hand set (if not the last set)
        if (set < sets - 1) {
          reps.add(
            RepTemplate(
              duration: restBetweenHandSets,
              isRest: true,
              handSide: HandSide.left,
              targetWeight: 0.0,
              index: currentIndex++,
              id: 0,
              trainingId: 0,
            ),
          );
        }
      }
    } else {
      // Non-split hand logic remains the same
      for (int set = 0; set < sets; set++) {
        for (int rep = 0; rep < repsBySet; rep++) {
          // Both hands work rep
          reps.add(
            RepTemplate(
              duration: workTime,
              isRest: false,
              handSide: HandSide.right, // Default to right hand when not split
              targetWeight: weightRight ?? weightLeft ?? 0.0,
              index: currentIndex++,
              id: 0,
              trainingId: 0,
              gripPosition: gripPosition,
            ),
          );

          // Rest between reps (if not the last rep of the set)
          if (rep < repsBySet - 1) {
            reps.add(
              RepTemplate(
                duration: restTime,
                isRest: true,
                handSide: HandSide.left,
                targetWeight: 0.0,
                index: currentIndex++,
                id: 0,
                trainingId: 0,
              ),
            );
          }
        }

        // Rest between sets (if not the last set)
        if (set < sets - 1) {
          reps.add(
            RepTemplate(
              duration: restBteweenSets,
              isRest: true,
              handSide: HandSide.left,
              targetWeight: 0.0,
              index: currentIndex++,
              id: 0,
              trainingId: 0,
            ),
          );
        }
      }
    }

    return reps;
  }
}

/// Represents a built-in training with assessment requirements.
class BuiltinTrainingModel {
  final int id;
  final String name;
  final String description;
  final List<AssessmentRequirement> requiredAssessments;
  final List<RepeaterModel> Function(
    List<AssessmentResultModel> assessmentValues, {
    double? customLoadRight,
    double? customLoadLeft,
  })
  trainingGenerator;
  final bool Function(List<AssessmentResultModel> assessmentValues) isAvailable;
  final LoadAdjustmentFunction? computeNewWeights;

  BuiltinTrainingModel({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredAssessments,
    required this.trainingGenerator,
    required this.isAvailable,
    this.computeNewWeights,
  });

  /// Generate the training based on assessment values.
  TrainingWithReps? generateTraining(
    List<AssessmentResultModel> assessmentValues, {
    double? customLoadRight,
    double? customLoadLeft,
  }) {
    if (!isAvailable(assessmentValues)) {
      return null;
    }

    final repeaters = trainingGenerator(
      assessmentValues,
      customLoadRight: customLoadRight,
      customLoadLeft: customLoadLeft,
    );

    // Combine all repeater reps into a single list
    List<RepModel> allReps = [];
    int globalIndex = 0;
    for (final repeater in repeaters) {
      final repeaterReps = repeater.generateReps();
      for (final rep in repeaterReps) {
        allReps.add(
          RepModel(
            durationInSeconds: rep.duration,
            isRest: rep.isRest,
            handSide: rep.handSide,
            targetWeight: rep.targetWeight,
            id: rep.id,
            index: globalIndex++,
            gripPosition: rep.gripPosition,
          ),
        );
      }
    }

    return TrainingWithReps(
      id: id,
      name: name,
      isFav: false,
      reps: allReps,
      repeater: repeaters.isNotEmpty ? repeaters.first : null,
      computeNewWeights: computeNewWeights,
    );
  }
}

/// Represents a training item in the list that can be either regular or builtin.
class TrainingListItem {
  final TrainingWithReps? training;
  final BuiltinTrainingModel? builtinTraining;
  final bool isAvailable;
  final List<AssessmentRequirement> missingAssessments;

  TrainingListItem._({
    this.training,
    this.builtinTraining,
    required this.isAvailable,
    required this.missingAssessments,
  });

  /// Create a regular training item.
  factory TrainingListItem.regular(TrainingWithReps training) {
    return TrainingListItem._(
      training: training,
      isAvailable: true,
      missingAssessments: [],
    );
  }

  /// Create a builtin training item.
  factory TrainingListItem.builtin(
    BuiltinTrainingModel builtinTraining,
    bool isAvailable,
    List<AssessmentRequirement> missingAssessments,
    TrainingWithReps? generatedTraining,
  ) {
    return TrainingListItem._(
      builtinTraining: builtinTraining,
      training: generatedTraining,
      isAvailable: isAvailable,
      missingAssessments: missingAssessments,
    );
  }

  bool get isBuiltin => builtinTraining != null;
  bool get isRegular => !isBuiltin;

  String get name => training?.name ?? builtinTraining?.name ?? '';
  String get description => builtinTraining?.description ?? '';
  Duration get totalDuration => training?.totalDuration ?? Duration.zero;
  int get id => training?.id ?? builtinTraining?.id ?? 0;
}

/// Template for a rep in a training (used for generation).
class RepTemplate {
  final int duration;
  final bool isRest;
  final HandSide handSide;
  final double targetWeight;
  final int index;
  final int id;
  final int trainingId;
  final GripPosition gripPosition;

  RepTemplate({
    required this.duration,
    required this.isRest,
    required this.handSide,
    required this.targetWeight,
    required this.index,
    required this.id,
    required this.trainingId,
    this.gripPosition = GripPosition.halfCrimp, // Default to half crimp
  });
}
