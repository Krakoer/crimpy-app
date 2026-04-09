// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionResponse _$SessionResponseFromJson(Map<String, dynamic> json) =>
    _SessionResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      notes: json['notes'] as String,
      date: json['date'] as String,
      duration: (json['duration'] as num).toInt(),
      isAssessment: json['is_assessment'] as bool,
      sessionType: (json['session_type'] as num).toInt(),
      repeaterSets: (json['repeater_sets'] as num?)?.toInt(),
      repeaterReps: (json['repeater_reps'] as num?)?.toInt(),
      repeaterWorkTime: (json['repeater_work_time'] as num?)?.toInt(),
      repeaterRestTime: (json['repeater_rest_time'] as num?)?.toInt(),
      repeaterSetRest: (json['repeater_set_rest'] as num?)?.toInt(),
      repeaterSplitHand: json['repeater_split_hand'] as bool?,
      userId: json['user_id'] as String,
    );

Map<String, dynamic> _$SessionResponseToJson(_SessionResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'notes': instance.notes,
      'date': instance.date,
      'duration': instance.duration,
      'is_assessment': instance.isAssessment,
      'session_type': instance.sessionType,
      'repeater_sets': instance.repeaterSets,
      'repeater_reps': instance.repeaterReps,
      'repeater_work_time': instance.repeaterWorkTime,
      'repeater_rest_time': instance.repeaterRestTime,
      'repeater_set_rest': instance.repeaterSetRest,
      'repeater_split_hand': instance.repeaterSplitHand,
      'user_id': instance.userId,
    };

_CreateSessionRequest _$CreateSessionRequestFromJson(
  Map<String, dynamic> json,
) => _CreateSessionRequest(
  name: json['name'] as String,
  notes: json['notes'] as String,
  duration: (json['duration'] as num).toInt(),
  isAssessment: json['is_assessment'] as bool,
  sessionType: (json['session_type'] as num).toInt(),
  repeaterSets: (json['repeater_sets'] as num?)?.toInt(),
  repeaterReps: (json['repeater_reps'] as num?)?.toInt(),
  repeaterWorkTime: (json['repeater_work_time'] as num?)?.toInt(),
  repeaterRestTime: (json['repeater_rest_time'] as num?)?.toInt(),
  repeaterSetRest: (json['repeater_set_rest'] as num?)?.toInt(),
  repeaterSplitHand: json['repeater_split_hand'] as bool?,
  repDatas:
      (json['rep_datas'] as List<dynamic>?)
          ?.map((e) => RepDataRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
  assessments:
      (json['assessments'] as List<dynamic>?)
          ?.map((e) => AssessmentRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CreateSessionRequestToJson(
  _CreateSessionRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'notes': instance.notes,
  'duration': instance.duration,
  'is_assessment': instance.isAssessment,
  'session_type': instance.sessionType,
  'repeater_sets': instance.repeaterSets,
  'repeater_reps': instance.repeaterReps,
  'repeater_work_time': instance.repeaterWorkTime,
  'repeater_rest_time': instance.repeaterRestTime,
  'repeater_set_rest': instance.repeaterSetRest,
  'repeater_split_hand': instance.repeaterSplitHand,
  'rep_datas': instance.repDatas,
  'assessments': instance.assessments,
};

_UpdateSessionRequest _$UpdateSessionRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateSessionRequest(
  name: json['name'] as String?,
  notes: json['notes'] as String?,
  duration: (json['duration'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateSessionRequestToJson(
  _UpdateSessionRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'notes': instance.notes,
  'duration': instance.duration,
};

_RepDataRequest _$RepDataRequestFromJson(Map<String, dynamic> json) =>
    _RepDataRequest(
      index: (json['index'] as num).toInt(),
      isRest: json['is_rest'] as bool,
      rightHand: json['right_hand'] as bool,
      duration: (json['duration'] as num).toInt(),
      targetWeight: (json['target_weight'] as num).toDouble(),
      averageWeight: (json['average_weight'] as num).toDouble(),
      gripPosition: (json['grip_position'] as num).toInt(),
    );

Map<String, dynamic> _$RepDataRequestToJson(_RepDataRequest instance) =>
    <String, dynamic>{
      'index': instance.index,
      'is_rest': instance.isRest,
      'right_hand': instance.rightHand,
      'duration': instance.duration,
      'target_weight': instance.targetWeight,
      'average_weight': instance.averageWeight,
      'grip_position': instance.gripPosition,
    };

_AssessmentRequest _$AssessmentRequestFromJson(Map<String, dynamic> json) =>
    _AssessmentRequest(
      type: (json['type'] as num).toInt(),
      rightValue: (json['right_value'] as num?)?.toDouble(),
      leftValue: (json['left_value'] as num?)?.toDouble(),
      gripPosition: (json['grip_position'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AssessmentRequestToJson(_AssessmentRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'right_value': instance.rightValue,
      'left_value': instance.leftValue,
      'grip_position': instance.gripPosition,
    };

_TrainingResponse _$TrainingResponseFromJson(Map<String, dynamic> json) =>
    _TrainingResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      isAssessment: json['is_assessment'] as bool,
      isFavorite: json['is_favorite'] as bool,
      repeaterId: (json['repeater_id'] as num?)?.toInt(),
      userId: json['user_id'] as String,
    );

Map<String, dynamic> _$TrainingResponseToJson(_TrainingResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_assessment': instance.isAssessment,
      'is_favorite': instance.isFavorite,
      'repeater_id': instance.repeaterId,
      'user_id': instance.userId,
    };

_CreateTrainingRequest _$CreateTrainingRequestFromJson(
  Map<String, dynamic> json,
) => _CreateTrainingRequest(
  name: json['name'] as String,
  isAssessment: json['is_assessment'] as bool,
  isFavorite: json['is_favorite'] as bool,
  repeaterId: (json['repeater_id'] as num?)?.toInt(),
  repTemplates:
      (json['rep_templates'] as List<dynamic>?)
          ?.map((e) => RepTemplateRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CreateTrainingRequestToJson(
  _CreateTrainingRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'is_assessment': instance.isAssessment,
  'is_favorite': instance.isFavorite,
  'repeater_id': instance.repeaterId,
  'rep_templates': instance.repTemplates,
};

_UpdateTrainingRequest _$UpdateTrainingRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateTrainingRequest(
  name: json['name'] as String?,
  isFavorite: json['is_favorite'] as bool?,
);

Map<String, dynamic> _$UpdateTrainingRequestToJson(
  _UpdateTrainingRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'is_favorite': instance.isFavorite,
};

_RepTemplateRequest _$RepTemplateRequestFromJson(Map<String, dynamic> json) =>
    _RepTemplateRequest(
      index: (json['index'] as num).toInt(),
      isRest: json['is_rest'] as bool,
      rightHand: json['right_hand'] as bool,
      duration: (json['duration'] as num).toInt(),
      targetWeight: (json['target_weight'] as num).toDouble(),
      gripPosition: (json['grip_position'] as num).toInt(),
    );

Map<String, dynamic> _$RepTemplateRequestToJson(_RepTemplateRequest instance) =>
    <String, dynamic>{
      'index': instance.index,
      'is_rest': instance.isRest,
      'right_hand': instance.rightHand,
      'duration': instance.duration,
      'target_weight': instance.targetWeight,
      'grip_position': instance.gripPosition,
    };

_RepeaterResponse _$RepeaterResponseFromJson(Map<String, dynamic> json) =>
    _RepeaterResponse(
      id: (json['id'] as num).toInt(),
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      worktime: (json['worktime'] as num).toInt(),
      resttime: (json['resttime'] as num).toInt(),
      setRest: (json['set_rest'] as num).toInt(),
      targetWeightRight: (json['target_weight_right'] as num?)?.toDouble(),
      targetWeightLeft: (json['target_weight_left'] as num?)?.toDouble(),
      splitHand: json['split_hand'] as bool,
      gripPosition: (json['grip_position'] as num).toInt(),
    );

Map<String, dynamic> _$RepeaterResponseToJson(_RepeaterResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sets': instance.sets,
      'reps': instance.reps,
      'worktime': instance.worktime,
      'resttime': instance.resttime,
      'set_rest': instance.setRest,
      'target_weight_right': instance.targetWeightRight,
      'target_weight_left': instance.targetWeightLeft,
      'split_hand': instance.splitHand,
      'grip_position': instance.gripPosition,
    };

_CreateRepeaterRequest _$CreateRepeaterRequestFromJson(
  Map<String, dynamic> json,
) => _CreateRepeaterRequest(
  sets: (json['sets'] as num).toInt(),
  reps: (json['reps'] as num).toInt(),
  worktime: (json['worktime'] as num).toInt(),
  resttime: (json['resttime'] as num).toInt(),
  setRest: (json['set_rest'] as num).toInt(),
  targetWeightRight: (json['target_weight_right'] as num?)?.toDouble(),
  targetWeightLeft: (json['target_weight_left'] as num?)?.toDouble(),
  splitHand: json['split_hand'] as bool,
  gripPosition: (json['grip_position'] as num).toInt(),
);

Map<String, dynamic> _$CreateRepeaterRequestToJson(
  _CreateRepeaterRequest instance,
) => <String, dynamic>{
  'sets': instance.sets,
  'reps': instance.reps,
  'worktime': instance.worktime,
  'resttime': instance.resttime,
  'set_rest': instance.setRest,
  'target_weight_right': instance.targetWeightRight,
  'target_weight_left': instance.targetWeightLeft,
  'split_hand': instance.splitHand,
  'grip_position': instance.gripPosition,
};

_UpdateRepeaterRequest _$UpdateRepeaterRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateRepeaterRequest(
  sets: (json['sets'] as num?)?.toInt(),
  reps: (json['reps'] as num?)?.toInt(),
  worktime: (json['worktime'] as num?)?.toInt(),
  resttime: (json['resttime'] as num?)?.toInt(),
  setRest: (json['set_rest'] as num?)?.toInt(),
  targetWeightRight: (json['target_weight_right'] as num?)?.toDouble(),
  targetWeightLeft: (json['target_weight_left'] as num?)?.toDouble(),
  splitHand: json['split_hand'] as bool?,
  gripPosition: (json['grip_position'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateRepeaterRequestToJson(
  _UpdateRepeaterRequest instance,
) => <String, dynamic>{
  'sets': instance.sets,
  'reps': instance.reps,
  'worktime': instance.worktime,
  'resttime': instance.resttime,
  'set_rest': instance.setRest,
  'target_weight_right': instance.targetWeightRight,
  'target_weight_left': instance.targetWeightLeft,
  'split_hand': instance.splitHand,
  'grip_position': instance.gripPosition,
};
