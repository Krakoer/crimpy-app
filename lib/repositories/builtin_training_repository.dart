import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
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
    final assessmentValues = await _getAssessmentValues(training.requiredAssessments);
    return training.isAvailable(assessmentValues);
  }

  /// Generate a training if available, returns null if not.
  Future<TrainingWithReps?> generateTraining(
    BuiltinTrainingModel training, {
    double? customLoad,
  }) async {
    final assessmentValues = await _getAssessmentValues(training.requiredAssessments);
    return training.generateTraining(assessmentValues, customLoad: customLoad);
  }

  /// Get the missing assessments for a training.
  Future<List<AssessmentType>> getMissingAssessments(BuiltinTrainingModel training) async {
    final assessmentValues = await _getAssessmentValues(training.requiredAssessments);
    final missing = <AssessmentType>[];
    
    for (final requiredType in training.requiredAssessments) {
      final value = assessmentValues[requiredType];
      if (value == null || value <= 0) {
        missing.add(requiredType);
      }
    }
    
    return missing;
  }

  /// Private method to get assessment values for required types.
  Future<Map<AssessmentType, double?>> _getAssessmentValues(
    List<AssessmentType> requiredTypes,
  ) async {
    final Map<AssessmentType, double?> values = {};
    
    for (final type in requiredTypes) {
      // For MVC types, try to get both hands and use the minimum for safety
      // If only one hand is available, use that value
      if (type == AssessmentType.mvc || type == AssessmentType.mvc3fd) {
        final rightValue = await _assessmentRepository.getLastValueForHand(type, true);
        final leftValue = await _assessmentRepository.getLastValueForHand(type, false);
        
        if (rightValue != null && leftValue != null) {
          // Use the minimum of both hands for safety
          values[type] = rightValue < leftValue ? rightValue : leftValue;
        } else if (rightValue != null) {
          // Use right hand value if available
          values[type] = rightValue;
        } else if (leftValue != null) {
          // Use left hand value if available
          values[type] = leftValue;
        } else {
          // No assessment values available
          values[type] = null;
        }
      } else {
        // For other assessment types, use right hand by default
        values[type] = await _assessmentRepository.getLastValueForHand(type, true);
      }
    }
    
    return values;
  }
}