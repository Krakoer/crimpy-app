import 'package:collection/collection.dart';
import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/repositories/assessment_repository.dart';

class BuiltinTrainingRepository {
  final AssessmentRepository _assessmentRepository = AssessmentRepository();
  final AppDatabase _database = gDatabase;

  /// Get all built-in trainings with their availability status.
  Future<List<BuiltinTrainingModel>> getBuiltinTrainings() async {
    return builtinTrainings;
  }

  /// Check if a builtin training is available based on assessments.
  Future<bool> isTrainingAvailable(BuiltinTrainingModel training) async {
    final assessmentValues = await _getAssessmentValues(
      training.requiredAssessments,
    );
    return training.isAvailable(assessmentValues);
  }

  /// Generate a training if available, returns null if not.
  /// If custom weights are not provided, it will try to load them from the database.
  Future<TrainingWithReps?> generateTraining(
    BuiltinTrainingModel training, {
    double? customLoadRight,
    double? customLoadLeft,
  }) async {
    final assessmentValues = await _getAssessmentValues(
      training.requiredAssessments,
    );

    // If custom weights are not provided, try to load them from database
    if (customLoadRight == null || customLoadLeft == null) {
      final savedWeights = await _database.getBuiltinTrainingWeights(
        training.id,
      );
      customLoadRight ??= savedWeights?.customWeightRight;
      customLoadLeft ??= savedWeights?.customWeightLeft;
    }

    return training.generateTraining(
      assessmentValues,
      customLoadRight: customLoadRight,
      customLoadLeft: customLoadLeft,
    );
  }

  /// Get the missing assessments for a training.
  Future<List<AssessmentType>> getMissingAssessments(
    BuiltinTrainingModel training,
  ) async {
    final assessmentValues = await _getAssessmentValues(
      training.requiredAssessments,
    );
    final missing = <AssessmentType>[];

    for (final requiredType in training.requiredAssessments) {
      final value = assessmentValues.lastWhereOrNull(
        (ass) => ass.type == requiredType,
      );
      if (value == null ||
          value.leftValue == null ||
          value.rightValue == null) {
        missing.add(requiredType);
      }
    }

    return missing;
  }

  /// Private method to get assessment values for required types.
  Future<List<AssessmentResultModel>> _getAssessmentValues(
    List<AssessmentType> requiredTypes,
  ) async {
    final List<AssessmentResultModel> values = [];

    for (final type in requiredTypes) {
      final rightValue = await _assessmentRepository.getLastValueForHand(
        type,
        HandSide.right,
      );
      final leftValue = await _assessmentRepository.getLastValueForHand(
        type,
        HandSide.left,
      );
      values.add(
        AssessmentResultModel(
          type: type,
          rightValue: rightValue,
          leftValue: leftValue,
        ),
      );
    }

    return values;
  }

  /// Update the target weights for a builtin training based on feedback.
  Future<void> updateTargetWeights({
    required BuiltinTrainingModel training,
    required double currentWeightRight,
    required double currentWeightLeft,
    required double newWeightRight,
    required double newWeightLeft,
  }) async {
    await _database.saveBuiltinTrainingWeights(
      builtinTrainingId: training.id,
      customWeightRight: newWeightRight,
      customWeightLeft: newWeightLeft,
    );
  }

  /// Get the current custom weights for a builtin training.
  Future<({double? weightRight, double? weightLeft})> getCustomWeights(
    int builtinTrainingId,
  ) async {
    final weights = await _database.getBuiltinTrainingWeights(
      builtinTrainingId,
    );
    return (
      weightRight: weights?.customWeightRight,
      weightLeft: weights?.customWeightLeft,
    );
  }
}
