import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/builtin_training.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/utils/training_expander.dart';
import 'package:crimpy/utils/training_intensity.dart';

/// Represents a training item in the list that can be either regular or builtin.
class TrainingListItem {
  final Training? training;
  final BuiltinTrainingModel? builtinTraining;
  final bool isAvailable;
  final List<AssessmentRequirement> missingAssessments;
  final bool isPinned;

  /// How hard the training is against the athlete's max, null when nothing in
  /// it resolves to a percentage of one.
  final TrainingIntensity? intensity;

  TrainingListItem._({
    this.training,
    this.builtinTraining,
    required this.isAvailable,
    required this.missingAssessments,
    required this.isPinned,
    this.intensity,
  });

  /// Create a regular training item.
  factory TrainingListItem.regular(
    Training training, {
    TrainingIntensity? intensity,
  }) {
    return TrainingListItem._(
      training: training,
      isAvailable: true,
      missingAssessments: [],
      isPinned: training.isFavorite,
      intensity: intensity,
    );
  }

  /// Create a builtin training item.
  factory TrainingListItem.builtin(
    BuiltinTrainingModel builtinTraining,
    bool isAvailable,
    List<AssessmentRequirement> missingAssessments,
    Training? generatedTraining,
    bool isPinned, {
    TrainingIntensity? intensity,
  }) {
    return TrainingListItem._(
      builtinTraining: builtinTraining,
      training: generatedTraining,
      isAvailable: isAvailable,
      missingAssessments: missingAssessments,
      isPinned: isPinned,
      intensity: intensity,
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
