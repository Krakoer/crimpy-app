import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';

class AssessmentRepository {
  /// Get all assessments trainings.
  /// Dynamically generates assessment trainings from builtins (no DB storage).
  Future<List<AssessmentTrainingModel>> getAssessmentTrainings() async {
    return builtinAssessments.map((a) => a.generateAssessment()).toList();
  }

  /// Save an assessment given its model and a session ID.
  Future<void> saveAssessment(
    AssessmentResultModel assessment,
    int sessionId,
  ) async {
    await gDatabase.saveAssessment(assessment, sessionId);
  }

  /// Delete an assessment.
  Future<void> deleteAssessment(int id) async {
    await gDatabase.deleteAssessment(id);
  }

  /// Get all the assessments.
  /// Allow to filter on `type`.
  /// If the `handSide` parameter is set, only corresponding assessment will be retrieved.
  Future<List<AssessmentModel>> getAssessments({
    AssessmentType? type,
    HandSide? handSide,
  }) async {
    return await gDatabase.getAssessments(type: type, handSide: handSide);
  }

  /// Get the last value of an assessment given its type for a given hand.
  Future<double?> getLastValueForHand(
    AssessmentType type,
    HandSide handSide,
  ) async {
    final assessment =
        (await gDatabase.getAssessments(
          type: type,
          handSide: handSide,
        )).lastOrNull;
    return handSide.isRightHand
        ? assessment?.rightValue
        : assessment?.leftValue;
  }
}
