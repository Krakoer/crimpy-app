import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';

abstract class AssessmentRepository {
  /// Saves a result and hands back the id storage gave it, which the guest
  /// import records so a retry does not send the same result twice.
  Future<String> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  );
  Future<void> deleteAssessment(String id);
  Future<List<AssessmentModel>> getAssessments({
    String? assessmentId,
    HandSide? handSide,
    GripPosition? gripPosition,
  });

  /// Every assessment that can be measured, so a result can be named and a
  /// percentage of it unit checked.
  Future<List<AssessmentDefinition>> getAssessmentDefinitions();

  /// The most recent result for [handSide], or null when there is none.
  ///
  /// Derived from [getAssessments] so both backends agree on what "most recent"
  /// means: implementations only have to return the matching assessments in
  /// chronological order.
  Future<double?> getLastValueForHand(
    String assessmentId,
    HandSide handSide, {
    GripPosition? gripPosition,
  }) async {
    final last = (await getAssessments(
      assessmentId: assessmentId,
      handSide: handSide,
      gripPosition: gripPosition,
    )).lastOrNull;
    return handSide.isRightHand ? last?.rightValue : last?.leftValue;
  }
}

class LocalAssessmentRepository extends AssessmentRepository {
  final AppDatabase _database;

  LocalAssessmentRepository({AppDatabase? database})
    : _database = database ?? gDatabase;

  @override
  Future<String> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  ) => _database.saveAssessment(assessment, sessionId);

  @override
  Future<void> deleteAssessment(String id) => _database.deleteAssessment(id);

  @override
  Future<List<AssessmentModel>> getAssessments({
    String? assessmentId,
    HandSide? handSide,
    GripPosition? gripPosition,
  }) => _database.getAssessments(
    assessmentId: assessmentId,
    handSide: handSide,
    gripPosition: gripPosition,
  );

  @override
  Future<List<AssessmentDefinition>> getAssessmentDefinitions() =>
      _database.getAssessmentDefinitions();
}
