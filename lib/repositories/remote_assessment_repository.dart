import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/services/api_client.dart';

class RemoteAssessmentRepository extends AssessmentRepository {
  final ApiClient _apiClient;

  RemoteAssessmentRepository(this._apiClient);

  @override
  Future<String> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  ) async {
    final created = await _apiClient.createAssessmentApi({
      'session_id': sessionId,
      'assessment_id': assessment.assessmentId,
      if (assessment.rightValue != null) 'right_value': assessment.rightValue,
      if (assessment.leftValue != null) 'left_value': assessment.leftValue,
      if (assessment.gripPosition != null)
        'grip_position': assessment.gripPosition!.index,
    });
    return created['id'] as String;
  }

  @override
  Future<void> deleteAssessment(String id) async {
    await _apiClient.deleteAssessmentApi(id);
  }

  @override
  Future<List<AssessmentDefinition>> getAssessmentDefinitions() async {
    final data = await _apiClient.getAssessmentDefinitionsApi();
    return data.map((d) => AssessmentDefinition.fromJson(d)).toList();
  }

  @override
  Future<List<AssessmentModel>> getAssessments({
    String? assessmentId,
    HandSide? handSide,
    GripPosition? gripPosition,
  }) async {
    final data = await _apiClient.getAssessmentsApi();

    List<AssessmentModel> result = data.map((a) {
      return AssessmentModel(
        id: a['id'] as String,
        date: DateTime.parse(
          a['session_date'] as String? ??
              a['date'] as String? ??
              DateTime.now().toIso8601String(),
        ),
        // Each row carries its own definition, so the history can be named
        // and formatted without a second request.
        definition: AssessmentDefinition(
          id: a['assessment_id'] as String,
          label: (a['label'] as String?) ?? 'Assessment',
          unit: assessmentUnitFromApi(a['unit'] as String?),
          perHand: (a['per_hand'] as bool?) ?? false,
          trainingId: a['training_id'] as String?,
        ),
        rightValue: (a['right_value'] as num?)?.toDouble(),
        leftValue: (a['left_value'] as num?)?.toDouble(),
        gripPosition: enumFromIndex<GripPosition?>(
          GripPosition.values,
          a['grip_position'] as num?,
          null,
        ),
      );
    }).toList();

    if (assessmentId != null) {
      result = result.where((a) => a.assessmentId == assessmentId).toList();
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

    // Callers take the last entry as the most recent one, so do not rely on the
    // order the API happened to return.
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }
}
