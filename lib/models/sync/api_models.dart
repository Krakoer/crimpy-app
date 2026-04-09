import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_models.freezed.dart';
part 'api_models.g.dart';

@freezed
sealed class SessionResponse with _$SessionResponse {
  const factory SessionResponse({
    required int id,
    required String name,
    required String notes,
    required String date,
    required int duration,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_assessment') required bool isAssessment,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'session_type') required int sessionType,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_sets') int? repeaterSets,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_reps') int? repeaterReps,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_work_time') int? repeaterWorkTime,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_rest_time') int? repeaterRestTime,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_set_rest') int? repeaterSetRest,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_split_hand') bool? repeaterSplitHand,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'user_id') required String userId,
  }) = _SessionResponse;

  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionResponseFromJson(json);
}

@freezed
sealed class CreateSessionRequest with _$CreateSessionRequest {
  const factory CreateSessionRequest({
    required String name,
    required String notes,
    required int duration,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_assessment') required bool isAssessment,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'session_type') required int sessionType,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_sets') int? repeaterSets,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_reps') int? repeaterReps,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_work_time') int? repeaterWorkTime,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_rest_time') int? repeaterRestTime,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_set_rest') int? repeaterSetRest,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_split_hand') bool? repeaterSplitHand,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'rep_datas') List<RepDataRequest>? repDatas,
    List<AssessmentRequest>? assessments,
  }) = _CreateSessionRequest;

  factory CreateSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSessionRequestFromJson(json);
}

@freezed
sealed class UpdateSessionRequest with _$UpdateSessionRequest {
  const factory UpdateSessionRequest({
    String? name,
    String? notes,
    int? duration,
  }) = _UpdateSessionRequest;

  factory UpdateSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSessionRequestFromJson(json);
}

@freezed
sealed class RepDataRequest with _$RepDataRequest {
  const factory RepDataRequest({
    required int index,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_rest') required bool isRest,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'right_hand') required bool rightHand,
    required int duration,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'target_weight') required double targetWeight,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'average_weight') required double averageWeight,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'grip_position') required int gripPosition,
  }) = _RepDataRequest;

  factory RepDataRequest.fromJson(Map<String, dynamic> json) =>
      _$RepDataRequestFromJson(json);
}

@freezed
sealed class AssessmentRequest with _$AssessmentRequest {
  const factory AssessmentRequest({
    required int type,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'right_value') double? rightValue,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'left_value') double? leftValue,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'grip_position') int? gripPosition,
  }) = _AssessmentRequest;

  factory AssessmentRequest.fromJson(Map<String, dynamic> json) =>
      _$AssessmentRequestFromJson(json);
}

@freezed
sealed class TrainingResponse with _$TrainingResponse {
  const factory TrainingResponse({
    required int id,
    required String name,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_assessment') required bool isAssessment,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_favorite') required bool isFavorite,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_id') int? repeaterId,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'user_id') required String userId,
  }) = _TrainingResponse;

  factory TrainingResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainingResponseFromJson(json);
}

@freezed
sealed class CreateTrainingRequest with _$CreateTrainingRequest {
  const factory CreateTrainingRequest({
    required String name,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_assessment') required bool isAssessment,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_favorite') required bool isFavorite,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'repeater_id') int? repeaterId,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'rep_templates') List<RepTemplateRequest>? repTemplates,
  }) = _CreateTrainingRequest;

  factory CreateTrainingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTrainingRequestFromJson(json);
}

@freezed
sealed class UpdateTrainingRequest with _$UpdateTrainingRequest {
  const factory UpdateTrainingRequest({
    String? name,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_favorite') bool? isFavorite,
  }) = _UpdateTrainingRequest;

  factory UpdateTrainingRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTrainingRequestFromJson(json);
}

@freezed
sealed class RepTemplateRequest with _$RepTemplateRequest {
  const factory RepTemplateRequest({
    required int index,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_rest') required bool isRest,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'right_hand') required bool rightHand,
    required int duration,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'target_weight') required double targetWeight,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'grip_position') required int gripPosition,
  }) = _RepTemplateRequest;

  factory RepTemplateRequest.fromJson(Map<String, dynamic> json) =>
      _$RepTemplateRequestFromJson(json);
}

@freezed
sealed class RepeaterResponse with _$RepeaterResponse {
  const factory RepeaterResponse({
    required int id,
    required int sets,
    required int reps,
    required int worktime,
    required int resttime,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'set_rest') required int setRest,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'target_weight_right') double? targetWeightRight,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'target_weight_left') double? targetWeightLeft,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'split_hand') required bool splitHand,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'grip_position') required int gripPosition,
  }) = _RepeaterResponse;

  factory RepeaterResponse.fromJson(Map<String, dynamic> json) =>
      _$RepeaterResponseFromJson(json);
}

@freezed
sealed class CreateRepeaterRequest with _$CreateRepeaterRequest {
  const factory CreateRepeaterRequest({
    required int sets,
    required int reps,
    required int worktime,
    required int resttime,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'set_rest') required int setRest,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'target_weight_right') double? targetWeightRight,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'target_weight_left') double? targetWeightLeft,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'split_hand') required bool splitHand,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'grip_position') required int gripPosition,
  }) = _CreateRepeaterRequest;

  factory CreateRepeaterRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRepeaterRequestFromJson(json);
}

@freezed
sealed class UpdateRepeaterRequest with _$UpdateRepeaterRequest {
  const factory UpdateRepeaterRequest({
    int? sets,
    int? reps,
    int? worktime,
    int? resttime,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'set_rest') int? setRest,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'target_weight_right') double? targetWeightRight,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'target_weight_left') double? targetWeightLeft,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'split_hand') bool? splitHand,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'grip_position') int? gripPosition,
  }) = _UpdateRepeaterRequest;

  factory UpdateRepeaterRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRepeaterRequestFromJson(json);
}
