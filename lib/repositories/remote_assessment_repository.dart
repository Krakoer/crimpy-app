import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/services/api_client.dart';

class RemoteAssessmentRepository implements AssessmentRepository {
  final ApiClient _apiClient;

  RemoteAssessmentRepository(this._apiClient);

  @override
  Future<List<AssessmentTrainingModel>> getAssessmentTrainings() async {
    // Assessment trainings are derived from builtin definitions, not stored remotely
    return builtinAssessments.map((a) => a.generateAssessment()).toList();
  }

  @override
  Future<void> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  ) async {
    // Assessments are created as part of POST /api/sessions (nested)
    // This method is only called when saving to the already-running session context.
    // The session handler creates assessments in the same transaction.
    // This is a no-op for the remote case since saveSession handles it.
  }

  @override
  Future<void> deleteAssessment(String id) async {
    await _apiClient.deleteAssessmentApi(id);
  }

  @override
  Future<List<AssessmentModel>> getAssessments({
    AssessmentType? type,
    HandSide? handSide,
    GripPosition? gripPosition,
  }) async {
    final data = await _apiClient.getAssessmentsApi();

    List<AssessmentModel> result = data.map((a) {
      return AssessmentModel(
        id: a['ID'] as String,
        date: DateTime.parse(
          a['SessionDate'] as String? ??
              a['Date'] as String? ??
              DateTime.now().toIso8601String(),
        ),
        type: AssessmentType.values[(a['Type'] as num).toInt()],
        rightValue: (a['RightValue'] as num?)?.toDouble(),
        leftValue: (a['LeftValue'] as num?)?.toDouble(),
        gripPosition: a['GripPosition'] != null
            ? GripPosition.values[(a['GripPosition'] as num).toInt()]
            : null,
      );
    }).toList();

    if (type != null) {
      result = result.where((a) => a.type == type).toList();
    }
    if (handSide != null) {
      result = result
          .where(
            (a) => handSide.isRightHand
                ? a.rightValue != null
                : a.leftValue != null,
          )
          .toList();
    }
    if (gripPosition != null) {
      result = result.where((a) => a.gripPosition == gripPosition).toList();
    }

    return result;
  }

  @override
  Future<double?> getLastValueForHand(
    AssessmentType type,
    HandSide handSide, {
    GripPosition? gripPosition,
  }) async {
    final assessments = await getAssessments(
      type: type,
      handSide: handSide,
      gripPosition: gripPosition,
    );
    final last = assessments.lastOrNull;
    return handSide.isRightHand ? last?.rightValue : last?.leftValue;
  }
}
