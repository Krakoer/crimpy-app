import "package:crimpy/database/database.dart";
import "package:crimpy/logger.dart";
import "package:crimpy/models/common.dart";
import "package:crimpy/models/training_feedback_model.dart";
import "package:crimpy/models/training_item_model.dart";

import "ble_data_model.dart";
import "assessment_model.dart";

/// Unified training with a structured list of items.
class Training {
  final String id;
  final String title;
  final String? description;
  final bool isFavorite;
  final List<TrainingItem> items;

  const Training({
    required this.id,
    required this.title,
    this.description,
    this.isFavorite = false,
    this.items = const [],
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return Training(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      items: rawItems
          .map((e) => TrainingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    'is_favorite': isFavorite,
    'items': items.map((i) => i.toJson()).toList(),
  };
}

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

/// Stores repeater configuration for a session.
/// This is saved with the session so we can properly display sets later,
/// even if the original training template is modified or deleted.
class RepeaterConfig {
  final int sets;
  final int repsPerSet;
  final int workTime;
  final int restTime;
  final int setRest;
  final bool splitHand;

  const RepeaterConfig({
    required this.sets,
    required this.repsPerSet,
    required this.workTime,
    required this.restTime,
    required this.setRest,
    required this.splitHand,
  });

  /// Create from RepeaterModel
  factory RepeaterConfig.fromRepeaterModel(RepeaterModel model) {
    return RepeaterConfig(
      sets: model.sets,
      repsPerSet: model.repsBySet,
      workTime: model.workTime,
      restTime: model.restTime,
      setRest: model.restBteweenSets,
      splitHand: model.splitHand,
    );
  }
}

class SessionModel {
  final String? id;
  final String name;
  final String? notes;
  final DateTime date;
  final List<BleDataPoint>? dataPoints;
  final List<RepData>? reps;
  final bool isAssessment;
  final SessionType sessionType;
  final int? durationInSeconds;
  final RepeaterConfig? repeaterConfig;

  SessionModel({
    this.id,
    this.notes,
    this.dataPoints,
    this.reps,
    required this.name,
    required this.isAssessment,
    this.sessionType = SessionType.crimpy,
    this.durationInSeconds,
    this.repeaterConfig,
    date,
  }) : date = date ?? DateTime.now();

  int get duration =>
      durationInSeconds ??
      (reps == null ? 0 : reps!.fold(0, (prev, r) => prev + r.duration));
}

class RepModel {
  String? id;
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
  final String id;
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
              id: "",
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
                id: "",
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
            id: "",
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
              id: "",
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
                id: "",
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
              id: "",
              trainingId: 0,
            ),
          );
        }
      }
    } else {
      // Non-split hand: each rep is performed with both hands (right, then left)
      for (int set = 0; set < sets; set++) {
        for (int rep = 0; rep < repsBySet; rep++) {
          // Right hand work rep
          reps.add(
            RepTemplate(
              duration: workTime,
              isRest: false,
              handSide: HandSide.right,
              targetWeight: weightRight ?? 0.0,
              index: currentIndex++,
              id: "",
              trainingId: 0,
              gripPosition: gripPosition,
            ),
          );

          // Rest after right hand
          reps.add(
            RepTemplate(
              duration: restTime,
              isRest: true,
              handSide: HandSide.right,
              targetWeight: 0.0,
              index: currentIndex++,
              id: "",
              trainingId: 0,
            ),
          );

          // Left hand work rep
          reps.add(
            RepTemplate(
              duration: workTime,
              isRest: false,
              handSide: HandSide.left,
              targetWeight: weightLeft ?? 0.0,
              index: currentIndex++,
              id: "",
              trainingId: 0,
              gripPosition: gripPosition,
            ),
          );

          // Rest after left hand (if not the last rep of the set)
          if (rep < repsBySet - 1) {
            reps.add(
              RepTemplate(
                duration: restTime,
                isRest: true,
                handSide: HandSide.left,
                targetWeight: 0.0,
                index: currentIndex++,
                id: "",
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
              handSide: HandSide.right,
              targetWeight: 0.0,
              index: currentIndex++,
              id: "",
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
  final String id;
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

  /// Generate a unified Training with repeater items from assessment values.
  Training? generateNewFormatTraining(
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

    final items = repeaters.indexed.map((indexed) {
      final pos = indexed.$1;
      final r = indexed.$2;
      final loadsPerRep = List.filled(
        r.repsBySet,
        Load(value: r.weightRight ?? 0.0, unit: 'kg'),
      );
      final leftLoadsPerRep = r.splitHand
          ? List.filled(
              r.repsBySet,
              Load(value: r.weightLeft ?? 0.0, unit: 'kg'),
            )
          : null;
      final positionsPerRep = List.filled(r.repsBySet, r.gripPosition.name);

      return TrainingItem(
        id: '',
        type: TrainingItemType.repeater,
        position: pos,
        cycles: r.sets,
        reps: r.repsBySet,
        worktimeSeconds: r.workTime,
        restSeconds: r.restTime,
        cycleRestSeconds: r.restBteweenSets,
        hand: r.splitHand ? 'split' : 'both',
        loads: loadsPerRep,
        leftLoads: leftLoadsPerRep,
        handPositions: positionsPerRep,
      );
    }).toList();

    return Training(id: id, title: name, isFavorite: false, items: items);
  }
}

/// Represents a training item in the list that can be either regular or builtin.
class TrainingListItem {
  final Training? training;
  final BuiltinTrainingModel? builtinTraining;
  final bool isAvailable;
  final List<AssessmentRequirement> missingAssessments;
  final bool isPinned;

  TrainingListItem._({
    this.training,
    this.builtinTraining,
    required this.isAvailable,
    required this.missingAssessments,
    required this.isPinned,
  });

  /// Create a regular training item.
  factory TrainingListItem.regular(Training training) {
    return TrainingListItem._(
      training: training,
      isAvailable: true,
      missingAssessments: [],
      isPinned: training.isFavorite,
    );
  }

  /// Create a builtin training item.
  factory TrainingListItem.builtin(
    BuiltinTrainingModel builtinTraining,
    bool isAvailable,
    List<AssessmentRequirement> missingAssessments,
    Training? generatedTraining,
    bool isPinned,
  ) {
    return TrainingListItem._(
      builtinTraining: builtinTraining,
      training: generatedTraining,
      isAvailable: isAvailable,
      missingAssessments: missingAssessments,
      isPinned: isPinned,
    );
  }

  bool get isBuiltin => builtinTraining != null;
  bool get isRegular => !isBuiltin;

  String get name => training?.title ?? builtinTraining?.name ?? '';
  String get description => builtinTraining?.description ?? '';
  Duration get totalDuration => Duration.zero;
  String get id => training?.id ?? builtinTraining?.id ?? '';
}

/// Template for a rep in a training (used for generation).
class RepTemplate {
  final int duration;
  final bool isRest;
  final HandSide handSide;
  final double targetWeight;
  final int index;
  final String id;
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
