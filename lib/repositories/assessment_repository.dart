import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';

abstract class AssessmentRepository {
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

  /// The most recent result for [handSide], or null when there is none.
  ///
  /// Derived from [getAssessments] so both backends agree on what "most recent"
  /// means: implementations only have to return the matching assessments in
  /// chronological order.
  Future<double?> getLastValueForHand(
    AssessmentType type,
    HandSide handSide, {
    GripPosition? gripPosition,
  }) async {
    final last = (await getAssessments(
      type: type,
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
  Future<void> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  ) => _database.saveAssessment(assessment, sessionId);

  @override
  Future<void> deleteAssessment(String id) => _database.deleteAssessment(id);

  @override
  Future<List<AssessmentModel>> getAssessments({
    AssessmentType? type,
    HandSide? handSide,
    GripPosition? gripPosition,
  }) => _database.getAssessments(
    type: type,
    handSide: handSide,
    gripPosition: gripPosition,
  );
}
