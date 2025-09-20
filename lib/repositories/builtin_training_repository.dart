import 'package:collection/collection.dart';
import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/repositories/assessment_repository.dart';

class BuiltinTrainingRepository {
  final AssessmentRepository _assessmentRepository = AssessmentRepository();

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
  Future<TrainingWithReps?> generateTraining(
    BuiltinTrainingModel training, {
    double? customLoadRight,
    double? customLoadLeft,
  }) async {
    final assessmentValues = await _getAssessmentValues(
      training.requiredAssessments,
    );
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
}
