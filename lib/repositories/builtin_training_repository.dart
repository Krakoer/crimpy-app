import 'package:collection/collection.dart';
import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/repositories/assessment_repository.dart';

class BuiltinTrainingRepository {
  final AssessmentRepository _assessmentRepository;
  final AppDatabase _database;

  BuiltinTrainingRepository({
    AssessmentRepository? assessmentRepository,
    AppDatabase? database,
  }) : _assessmentRepository =
           assessmentRepository ?? LocalAssessmentRepository(),
       _database = database ?? gDatabase;

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
  Future<List<AssessmentRequirement>> getMissingAssessments(
    BuiltinTrainingModel training,
  ) async {
    final assessmentValues = await _getAssessmentValues(
      training.requiredAssessments,
    );
    final missing = <AssessmentRequirement>[];

    for (final requirement in training.requiredAssessments) {
      final value = assessmentValues.lastWhereOrNull(
        (ass) =>
            ass.type == requirement.type &&
            ass.gripPosition == requirement.gripPosition,
      );
      if (value == null ||
          value.leftValue == null ||
          value.rightValue == null) {
        missing.add(requirement);
      }
    }

    return missing;
  }

  /// Private method to get assessment values for required assessments.
  Future<List<AssessmentResultModel>> _getAssessmentValues(
    List<AssessmentRequirement> requirements,
  ) async {
    final List<AssessmentResultModel> values = [];

    for (final requirement in requirements) {
      final rightValue = await _assessmentRepository.getLastValueForHand(
        requirement.type,
        HandSide.right,
        gripPosition: requirement.gripPosition,
      );
      final leftValue = await _assessmentRepository.getLastValueForHand(
        requirement.type,
        HandSide.left,
        gripPosition: requirement.gripPosition,
      );
      values.add(
        AssessmentResultModel(
          type: requirement.type,
          rightValue: rightValue,
          leftValue: leftValue,
          gripPosition: requirement.gripPosition,
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
    String builtinTrainingId,
  ) async {
    final weights = await _database.getBuiltinTrainingWeights(
      builtinTrainingId,
    );
    return (
      weightRight: weights?.customWeightRight,
      weightLeft: weights?.customWeightLeft,
    );
  }

  /// Get all pinned builtin training IDs.
  Future<List<String>> getPinnedBuiltinTrainingIds() async {
    return await _database.getPinnedBuiltinTrainingIds();
  }

  /// Pin a builtin training to the home screen.
  Future<void> pinBuiltinTraining(String builtinTrainingId) async {
    await _database.pinBuiltinTraining(builtinTrainingId);
  }

  /// Unpin a builtin training from the home screen.
  Future<void> unpinBuiltinTraining(String builtinTrainingId) async {
    await _database.unpinBuiltinTraining(builtinTrainingId);
  }

  /// Check if a builtin training is pinned.
  Future<bool> isBuiltinTrainingPinned(String builtinTrainingId) async {
    return await _database.isBuiltinTrainingPinned(builtinTrainingId);
  }
}
