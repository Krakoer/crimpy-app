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

  /// What a duration set as a percentage of an assessment resolves against,
  /// so the card's length is the one the training's detail and run give.
  final AssessmentResults results;

  TrainingListItem._({
    this.training,
    this.builtinTraining,
    required this.isAvailable,
    required this.missingAssessments,
    required this.isPinned,
    this.intensity,
    this.results = AssessmentResults.none,
  });

  /// Create a regular training item.
  factory TrainingListItem.regular(
    Training training, {
    TrainingIntensity? intensity,
    AssessmentResults results = AssessmentResults.none,
  }) {
    return TrainingListItem._(
      training: training,
      isAvailable: true,
      missingAssessments: [],
      isPinned: training.isFavorite,
      intensity: intensity,
      results: results,
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
    AssessmentResults results = AssessmentResults.none,
  }) {
    return TrainingListItem._(
      builtinTraining: builtinTraining,
      training: generatedTraining,
      isAvailable: isAvailable,
      missingAssessments: missingAssessments,
      isPinned: isPinned,
      intensity: intensity,
      results: results,
    );
  }

  bool get isBuiltin => builtinTraining != null;
  bool get isRegular => !isBuiltin;

  String get name => training?.title ?? builtinTraining?.name ?? '';
  String get description => builtinTraining?.description ?? '';

  Duration get totalDuration {
    final t = training;
    if (t == null) return Duration.zero;
    return Duration(seconds: trainingDurationSeconds(t, results: results));
  }

  String get id => training?.id ?? builtinTraining?.id ?? '';
}
