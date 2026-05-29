import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';

abstract class AssessmentRepository {
  Future<List<AssessmentTrainingModel>> getAssessmentTrainings();
  Future<void> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  );
  Future<void> deleteAssessment(String id);
  Future<List<AssessmentModel>> getAssessments({
    AssessmentType? type,
    HandSide? handSide,
    GripPosition? gripPosition,
  });
  Future<double?> getLastValueForHand(
    AssessmentType type,
    HandSide handSide, {
    GripPosition? gripPosition,
  });
}

class LocalAssessmentRepository implements AssessmentRepository {
  @override
  Future<List<AssessmentTrainingModel>> getAssessmentTrainings() async {
    return builtinAssessments.map((a) => a.generateAssessment()).toList();
  }

  @override
  Future<void> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  ) async {
    await gDatabase.saveAssessment(assessment, sessionId);
  }

  @override
  Future<void> deleteAssessment(String id) async {
    await gDatabase.deleteAssessment(id);
  }

  @override
  Future<List<AssessmentModel>> getAssessments({
    AssessmentType? type,
    HandSide? handSide,
    GripPosition? gripPosition,
  }) async {
    return await gDatabase.getAssessments(
      type: type,
      handSide: handSide,
      gripPosition: gripPosition,
    );
  }

  @override
  Future<double?> getLastValueForHand(
    AssessmentType type,
    HandSide handSide, {
    GripPosition? gripPosition,
  }) async {
    final assessment = (await gDatabase.getAssessments(
      type: type,
      handSide: handSide,
      gripPosition: gripPosition,
    )).lastOrNull;
    return handSide.isRightHand
        ? assessment?.rightValue
        : assessment?.leftValue;
  }
}
