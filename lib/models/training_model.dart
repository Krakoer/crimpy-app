import "package:crimpy/models/common.dart";
import "package:crimpy/models/training_feedback_model.dart";
import "package:crimpy/models/training_item_model.dart";
import "package:crimpy/utils/training_expander.dart";

import "ble_data_model.dart";
import "assessment_model.dart";

/// Unified training with a structured list of items.
class Training {
  final String id;
  final String title;
  final String? description;
  final String? goal;
  final String? comment;
  final bool isFavorite;
  final List<TrainingItem> items;

  const Training({
    required this.id,
    required this.title,
    this.description,
    this.goal,
    this.comment,
    this.isFavorite = false,
    this.items = const [],
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    String? cleaned(dynamic raw) {
      final value = raw as String?;
      return (value == null || value.trim().isEmpty) ? null : value;
    }

    return Training(
      id: json['id'] as String,
      title: json['title'] as String,
      description: cleaned(json['description']),
      goal: cleaned(json['goal']),
      comment: cleaned(json['comment']),
      isFavorite: json['is_favorite'] as bool? ?? false,
      items: rawItems
          .map((e) => TrainingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    if (goal != null) 'goal': goal,
    if (comment != null) 'comment': comment,
    'is_favorite': isFavorite,
    'items': items.map((i) => i.toJson()).toList(),
  };

  /// Whether any exercise in the tree can be performed with the force sensor.
  bool get canUseSensor {
    bool any(List<TrainingItem> items) =>
        items.any((item) => item.usesSensor || any(item.items));
    return any(items);
  }
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

  /// Builds the config from an API session payload, or null when that session
  /// was not a repeater. The API returns these fields in PascalCase.
  static RepeaterConfig? fromJson(Map<String, dynamic> json) {
    const keys = [
      'RepeaterSets',
      'RepeaterReps',
      'RepeaterWorkTime',
      'RepeaterRestTime',
      'RepeaterSetRest',
      'RepeaterSplitHand',
    ];
    if (keys.any((k) => json[k] == null)) return null;
    return RepeaterConfig(
      sets: (json['RepeaterSets'] as num).toInt(),
      repsPerSet: (json['RepeaterReps'] as num).toInt(),
      workTime: (json['RepeaterWorkTime'] as num).toInt(),
      restTime: (json['RepeaterRestTime'] as num).toInt(),
      setRest: (json['RepeaterSetRest'] as num).toInt(),
      splitHand: json['RepeaterSplitHand'] as bool,
    );
  }

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
  final List<RepDataModel>? reps;
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

  /// Parses a session as returned by the API, which uses PascalCase keys.
  factory SessionModel.fromJson(
    Map<String, dynamic> json, {
    List<RepDataModel>? reps,
  }) => SessionModel(
    id: json['ID'] as String,
    name: json['Name'] as String,
    notes: json['Notes'] as String? ?? '',
    date: DateTime.parse(json['Date'] as String),
    reps: reps,
    isAssessment: json['IsAssessment'] as bool? ?? false,
    sessionType: enumFromIndex(
      SessionType.values,
      json['SessionType'] as num?,
      SessionType.crimpy,
    ),
    durationInSeconds: (json['Duration'] as num? ?? 0).toInt(),
    repeaterConfig: RepeaterConfig.fromJson(json),
  );

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

  /// Parses a repetition as returned by the API, which uses PascalCase keys.
  factory RepDataModel.fromJson(Map<String, dynamic> json) => RepDataModel(
    averageWeight: (json['AverageWeight'] as num).toDouble(),
    duration: (json['Duration'] as num).toInt(),
    index: (json['Index'] as num).toInt(),
    isRest: json['IsRest'] as bool,
    handSide: (json['RightHand'] as bool) ? HandSide.right : HandSide.left,
    targetWeight: (json['TargetWeight'] as num).toDouble(),
    gripPosition: enumFromIndex(
      GripPosition.values,
      json['GripPosition'] as num?,
      GripPosition.halfCrimp,
    ),
  );
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

  Duration get totalDuration {
    final t = training;
    if (t == null) return Duration.zero;
    return Duration(seconds: trainingDurationSeconds(t));
  }

  String get id => training?.id ?? builtinTraining?.id ?? '';
}
