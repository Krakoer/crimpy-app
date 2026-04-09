// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionResponse {

 int get id; String get name; String get notes; String get date; int get duration;// ignore: invalid_annotation_target
@JsonKey(name: 'is_assessment') bool get isAssessment;// ignore: invalid_annotation_target
@JsonKey(name: 'session_type') int get sessionType;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_sets') int? get repeaterSets;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_reps') int? get repeaterReps;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_work_time') int? get repeaterWorkTime;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_rest_time') int? get repeaterRestTime;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_set_rest') int? get repeaterSetRest;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_split_hand') bool? get repeaterSplitHand;// ignore: invalid_annotation_target
@JsonKey(name: 'user_id') String get userId;
/// Create a copy of SessionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionResponseCopyWith<SessionResponse> get copyWith => _$SessionResponseCopyWithImpl<SessionResponse>(this as SessionResponse, _$identity);

  /// Serializes this SessionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.date, date) || other.date == date)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.isAssessment, isAssessment) || other.isAssessment == isAssessment)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.repeaterSets, repeaterSets) || other.repeaterSets == repeaterSets)&&(identical(other.repeaterReps, repeaterReps) || other.repeaterReps == repeaterReps)&&(identical(other.repeaterWorkTime, repeaterWorkTime) || other.repeaterWorkTime == repeaterWorkTime)&&(identical(other.repeaterRestTime, repeaterRestTime) || other.repeaterRestTime == repeaterRestTime)&&(identical(other.repeaterSetRest, repeaterSetRest) || other.repeaterSetRest == repeaterSetRest)&&(identical(other.repeaterSplitHand, repeaterSplitHand) || other.repeaterSplitHand == repeaterSplitHand)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,notes,date,duration,isAssessment,sessionType,repeaterSets,repeaterReps,repeaterWorkTime,repeaterRestTime,repeaterSetRest,repeaterSplitHand,userId);

@override
String toString() {
  return 'SessionResponse(id: $id, name: $name, notes: $notes, date: $date, duration: $duration, isAssessment: $isAssessment, sessionType: $sessionType, repeaterSets: $repeaterSets, repeaterReps: $repeaterReps, repeaterWorkTime: $repeaterWorkTime, repeaterRestTime: $repeaterRestTime, repeaterSetRest: $repeaterSetRest, repeaterSplitHand: $repeaterSplitHand, userId: $userId)';
}


}

/// @nodoc
abstract mixin class $SessionResponseCopyWith<$Res>  {
  factory $SessionResponseCopyWith(SessionResponse value, $Res Function(SessionResponse) _then) = _$SessionResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name, String notes, String date, int duration,@JsonKey(name: 'is_assessment') bool isAssessment,@JsonKey(name: 'session_type') int sessionType,@JsonKey(name: 'repeater_sets') int? repeaterSets,@JsonKey(name: 'repeater_reps') int? repeaterReps,@JsonKey(name: 'repeater_work_time') int? repeaterWorkTime,@JsonKey(name: 'repeater_rest_time') int? repeaterRestTime,@JsonKey(name: 'repeater_set_rest') int? repeaterSetRest,@JsonKey(name: 'repeater_split_hand') bool? repeaterSplitHand,@JsonKey(name: 'user_id') String userId
});




}
/// @nodoc
class _$SessionResponseCopyWithImpl<$Res>
    implements $SessionResponseCopyWith<$Res> {
  _$SessionResponseCopyWithImpl(this._self, this._then);

  final SessionResponse _self;
  final $Res Function(SessionResponse) _then;

/// Create a copy of SessionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? notes = null,Object? date = null,Object? duration = null,Object? isAssessment = null,Object? sessionType = null,Object? repeaterSets = freezed,Object? repeaterReps = freezed,Object? repeaterWorkTime = freezed,Object? repeaterRestTime = freezed,Object? repeaterSetRest = freezed,Object? repeaterSplitHand = freezed,Object? userId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,isAssessment: null == isAssessment ? _self.isAssessment : isAssessment // ignore: cast_nullable_to_non_nullable
as bool,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as int,repeaterSets: freezed == repeaterSets ? _self.repeaterSets : repeaterSets // ignore: cast_nullable_to_non_nullable
as int?,repeaterReps: freezed == repeaterReps ? _self.repeaterReps : repeaterReps // ignore: cast_nullable_to_non_nullable
as int?,repeaterWorkTime: freezed == repeaterWorkTime ? _self.repeaterWorkTime : repeaterWorkTime // ignore: cast_nullable_to_non_nullable
as int?,repeaterRestTime: freezed == repeaterRestTime ? _self.repeaterRestTime : repeaterRestTime // ignore: cast_nullable_to_non_nullable
as int?,repeaterSetRest: freezed == repeaterSetRest ? _self.repeaterSetRest : repeaterSetRest // ignore: cast_nullable_to_non_nullable
as int?,repeaterSplitHand: freezed == repeaterSplitHand ? _self.repeaterSplitHand : repeaterSplitHand // ignore: cast_nullable_to_non_nullable
as bool?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionResponse].
extension SessionResponsePatterns on SessionResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionResponse value)  $default,){
final _that = this;
switch (_that) {
case _SessionResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SessionResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String notes,  String date,  int duration, @JsonKey(name: 'is_assessment')  bool isAssessment, @JsonKey(name: 'session_type')  int sessionType, @JsonKey(name: 'repeater_sets')  int? repeaterSets, @JsonKey(name: 'repeater_reps')  int? repeaterReps, @JsonKey(name: 'repeater_work_time')  int? repeaterWorkTime, @JsonKey(name: 'repeater_rest_time')  int? repeaterRestTime, @JsonKey(name: 'repeater_set_rest')  int? repeaterSetRest, @JsonKey(name: 'repeater_split_hand')  bool? repeaterSplitHand, @JsonKey(name: 'user_id')  String userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionResponse() when $default != null:
return $default(_that.id,_that.name,_that.notes,_that.date,_that.duration,_that.isAssessment,_that.sessionType,_that.repeaterSets,_that.repeaterReps,_that.repeaterWorkTime,_that.repeaterRestTime,_that.repeaterSetRest,_that.repeaterSplitHand,_that.userId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String notes,  String date,  int duration, @JsonKey(name: 'is_assessment')  bool isAssessment, @JsonKey(name: 'session_type')  int sessionType, @JsonKey(name: 'repeater_sets')  int? repeaterSets, @JsonKey(name: 'repeater_reps')  int? repeaterReps, @JsonKey(name: 'repeater_work_time')  int? repeaterWorkTime, @JsonKey(name: 'repeater_rest_time')  int? repeaterRestTime, @JsonKey(name: 'repeater_set_rest')  int? repeaterSetRest, @JsonKey(name: 'repeater_split_hand')  bool? repeaterSplitHand, @JsonKey(name: 'user_id')  String userId)  $default,) {final _that = this;
switch (_that) {
case _SessionResponse():
return $default(_that.id,_that.name,_that.notes,_that.date,_that.duration,_that.isAssessment,_that.sessionType,_that.repeaterSets,_that.repeaterReps,_that.repeaterWorkTime,_that.repeaterRestTime,_that.repeaterSetRest,_that.repeaterSplitHand,_that.userId);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String notes,  String date,  int duration, @JsonKey(name: 'is_assessment')  bool isAssessment, @JsonKey(name: 'session_type')  int sessionType, @JsonKey(name: 'repeater_sets')  int? repeaterSets, @JsonKey(name: 'repeater_reps')  int? repeaterReps, @JsonKey(name: 'repeater_work_time')  int? repeaterWorkTime, @JsonKey(name: 'repeater_rest_time')  int? repeaterRestTime, @JsonKey(name: 'repeater_set_rest')  int? repeaterSetRest, @JsonKey(name: 'repeater_split_hand')  bool? repeaterSplitHand, @JsonKey(name: 'user_id')  String userId)?  $default,) {final _that = this;
switch (_that) {
case _SessionResponse() when $default != null:
return $default(_that.id,_that.name,_that.notes,_that.date,_that.duration,_that.isAssessment,_that.sessionType,_that.repeaterSets,_that.repeaterReps,_that.repeaterWorkTime,_that.repeaterRestTime,_that.repeaterSetRest,_that.repeaterSplitHand,_that.userId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionResponse implements SessionResponse {
  const _SessionResponse({required this.id, required this.name, required this.notes, required this.date, required this.duration, @JsonKey(name: 'is_assessment') required this.isAssessment, @JsonKey(name: 'session_type') required this.sessionType, @JsonKey(name: 'repeater_sets') this.repeaterSets, @JsonKey(name: 'repeater_reps') this.repeaterReps, @JsonKey(name: 'repeater_work_time') this.repeaterWorkTime, @JsonKey(name: 'repeater_rest_time') this.repeaterRestTime, @JsonKey(name: 'repeater_set_rest') this.repeaterSetRest, @JsonKey(name: 'repeater_split_hand') this.repeaterSplitHand, @JsonKey(name: 'user_id') required this.userId});
  factory _SessionResponse.fromJson(Map<String, dynamic> json) => _$SessionResponseFromJson(json);

@override final  int id;
@override final  String name;
@override final  String notes;
@override final  String date;
@override final  int duration;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'is_assessment') final  bool isAssessment;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'session_type') final  int sessionType;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_sets') final  int? repeaterSets;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_reps') final  int? repeaterReps;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_work_time') final  int? repeaterWorkTime;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_rest_time') final  int? repeaterRestTime;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_set_rest') final  int? repeaterSetRest;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_split_hand') final  bool? repeaterSplitHand;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'user_id') final  String userId;

/// Create a copy of SessionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionResponseCopyWith<_SessionResponse> get copyWith => __$SessionResponseCopyWithImpl<_SessionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.date, date) || other.date == date)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.isAssessment, isAssessment) || other.isAssessment == isAssessment)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.repeaterSets, repeaterSets) || other.repeaterSets == repeaterSets)&&(identical(other.repeaterReps, repeaterReps) || other.repeaterReps == repeaterReps)&&(identical(other.repeaterWorkTime, repeaterWorkTime) || other.repeaterWorkTime == repeaterWorkTime)&&(identical(other.repeaterRestTime, repeaterRestTime) || other.repeaterRestTime == repeaterRestTime)&&(identical(other.repeaterSetRest, repeaterSetRest) || other.repeaterSetRest == repeaterSetRest)&&(identical(other.repeaterSplitHand, repeaterSplitHand) || other.repeaterSplitHand == repeaterSplitHand)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,notes,date,duration,isAssessment,sessionType,repeaterSets,repeaterReps,repeaterWorkTime,repeaterRestTime,repeaterSetRest,repeaterSplitHand,userId);

@override
String toString() {
  return 'SessionResponse(id: $id, name: $name, notes: $notes, date: $date, duration: $duration, isAssessment: $isAssessment, sessionType: $sessionType, repeaterSets: $repeaterSets, repeaterReps: $repeaterReps, repeaterWorkTime: $repeaterWorkTime, repeaterRestTime: $repeaterRestTime, repeaterSetRest: $repeaterSetRest, repeaterSplitHand: $repeaterSplitHand, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$SessionResponseCopyWith<$Res> implements $SessionResponseCopyWith<$Res> {
  factory _$SessionResponseCopyWith(_SessionResponse value, $Res Function(_SessionResponse) _then) = __$SessionResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String notes, String date, int duration,@JsonKey(name: 'is_assessment') bool isAssessment,@JsonKey(name: 'session_type') int sessionType,@JsonKey(name: 'repeater_sets') int? repeaterSets,@JsonKey(name: 'repeater_reps') int? repeaterReps,@JsonKey(name: 'repeater_work_time') int? repeaterWorkTime,@JsonKey(name: 'repeater_rest_time') int? repeaterRestTime,@JsonKey(name: 'repeater_set_rest') int? repeaterSetRest,@JsonKey(name: 'repeater_split_hand') bool? repeaterSplitHand,@JsonKey(name: 'user_id') String userId
});




}
/// @nodoc
class __$SessionResponseCopyWithImpl<$Res>
    implements _$SessionResponseCopyWith<$Res> {
  __$SessionResponseCopyWithImpl(this._self, this._then);

  final _SessionResponse _self;
  final $Res Function(_SessionResponse) _then;

/// Create a copy of SessionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? notes = null,Object? date = null,Object? duration = null,Object? isAssessment = null,Object? sessionType = null,Object? repeaterSets = freezed,Object? repeaterReps = freezed,Object? repeaterWorkTime = freezed,Object? repeaterRestTime = freezed,Object? repeaterSetRest = freezed,Object? repeaterSplitHand = freezed,Object? userId = null,}) {
  return _then(_SessionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,isAssessment: null == isAssessment ? _self.isAssessment : isAssessment // ignore: cast_nullable_to_non_nullable
as bool,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as int,repeaterSets: freezed == repeaterSets ? _self.repeaterSets : repeaterSets // ignore: cast_nullable_to_non_nullable
as int?,repeaterReps: freezed == repeaterReps ? _self.repeaterReps : repeaterReps // ignore: cast_nullable_to_non_nullable
as int?,repeaterWorkTime: freezed == repeaterWorkTime ? _self.repeaterWorkTime : repeaterWorkTime // ignore: cast_nullable_to_non_nullable
as int?,repeaterRestTime: freezed == repeaterRestTime ? _self.repeaterRestTime : repeaterRestTime // ignore: cast_nullable_to_non_nullable
as int?,repeaterSetRest: freezed == repeaterSetRest ? _self.repeaterSetRest : repeaterSetRest // ignore: cast_nullable_to_non_nullable
as int?,repeaterSplitHand: freezed == repeaterSplitHand ? _self.repeaterSplitHand : repeaterSplitHand // ignore: cast_nullable_to_non_nullable
as bool?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CreateSessionRequest {

 String get name; String get notes; int get duration;// ignore: invalid_annotation_target
@JsonKey(name: 'is_assessment') bool get isAssessment;// ignore: invalid_annotation_target
@JsonKey(name: 'session_type') int get sessionType;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_sets') int? get repeaterSets;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_reps') int? get repeaterReps;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_work_time') int? get repeaterWorkTime;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_rest_time') int? get repeaterRestTime;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_set_rest') int? get repeaterSetRest;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_split_hand') bool? get repeaterSplitHand;// ignore: invalid_annotation_target
@JsonKey(name: 'rep_datas') List<RepDataRequest>? get repDatas; List<AssessmentRequest>? get assessments;
/// Create a copy of CreateSessionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateSessionRequestCopyWith<CreateSessionRequest> get copyWith => _$CreateSessionRequestCopyWithImpl<CreateSessionRequest>(this as CreateSessionRequest, _$identity);

  /// Serializes this CreateSessionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateSessionRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.isAssessment, isAssessment) || other.isAssessment == isAssessment)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.repeaterSets, repeaterSets) || other.repeaterSets == repeaterSets)&&(identical(other.repeaterReps, repeaterReps) || other.repeaterReps == repeaterReps)&&(identical(other.repeaterWorkTime, repeaterWorkTime) || other.repeaterWorkTime == repeaterWorkTime)&&(identical(other.repeaterRestTime, repeaterRestTime) || other.repeaterRestTime == repeaterRestTime)&&(identical(other.repeaterSetRest, repeaterSetRest) || other.repeaterSetRest == repeaterSetRest)&&(identical(other.repeaterSplitHand, repeaterSplitHand) || other.repeaterSplitHand == repeaterSplitHand)&&const DeepCollectionEquality().equals(other.repDatas, repDatas)&&const DeepCollectionEquality().equals(other.assessments, assessments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,notes,duration,isAssessment,sessionType,repeaterSets,repeaterReps,repeaterWorkTime,repeaterRestTime,repeaterSetRest,repeaterSplitHand,const DeepCollectionEquality().hash(repDatas),const DeepCollectionEquality().hash(assessments));

@override
String toString() {
  return 'CreateSessionRequest(name: $name, notes: $notes, duration: $duration, isAssessment: $isAssessment, sessionType: $sessionType, repeaterSets: $repeaterSets, repeaterReps: $repeaterReps, repeaterWorkTime: $repeaterWorkTime, repeaterRestTime: $repeaterRestTime, repeaterSetRest: $repeaterSetRest, repeaterSplitHand: $repeaterSplitHand, repDatas: $repDatas, assessments: $assessments)';
}


}

/// @nodoc
abstract mixin class $CreateSessionRequestCopyWith<$Res>  {
  factory $CreateSessionRequestCopyWith(CreateSessionRequest value, $Res Function(CreateSessionRequest) _then) = _$CreateSessionRequestCopyWithImpl;
@useResult
$Res call({
 String name, String notes, int duration,@JsonKey(name: 'is_assessment') bool isAssessment,@JsonKey(name: 'session_type') int sessionType,@JsonKey(name: 'repeater_sets') int? repeaterSets,@JsonKey(name: 'repeater_reps') int? repeaterReps,@JsonKey(name: 'repeater_work_time') int? repeaterWorkTime,@JsonKey(name: 'repeater_rest_time') int? repeaterRestTime,@JsonKey(name: 'repeater_set_rest') int? repeaterSetRest,@JsonKey(name: 'repeater_split_hand') bool? repeaterSplitHand,@JsonKey(name: 'rep_datas') List<RepDataRequest>? repDatas, List<AssessmentRequest>? assessments
});




}
/// @nodoc
class _$CreateSessionRequestCopyWithImpl<$Res>
    implements $CreateSessionRequestCopyWith<$Res> {
  _$CreateSessionRequestCopyWithImpl(this._self, this._then);

  final CreateSessionRequest _self;
  final $Res Function(CreateSessionRequest) _then;

/// Create a copy of CreateSessionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? notes = null,Object? duration = null,Object? isAssessment = null,Object? sessionType = null,Object? repeaterSets = freezed,Object? repeaterReps = freezed,Object? repeaterWorkTime = freezed,Object? repeaterRestTime = freezed,Object? repeaterSetRest = freezed,Object? repeaterSplitHand = freezed,Object? repDatas = freezed,Object? assessments = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,isAssessment: null == isAssessment ? _self.isAssessment : isAssessment // ignore: cast_nullable_to_non_nullable
as bool,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as int,repeaterSets: freezed == repeaterSets ? _self.repeaterSets : repeaterSets // ignore: cast_nullable_to_non_nullable
as int?,repeaterReps: freezed == repeaterReps ? _self.repeaterReps : repeaterReps // ignore: cast_nullable_to_non_nullable
as int?,repeaterWorkTime: freezed == repeaterWorkTime ? _self.repeaterWorkTime : repeaterWorkTime // ignore: cast_nullable_to_non_nullable
as int?,repeaterRestTime: freezed == repeaterRestTime ? _self.repeaterRestTime : repeaterRestTime // ignore: cast_nullable_to_non_nullable
as int?,repeaterSetRest: freezed == repeaterSetRest ? _self.repeaterSetRest : repeaterSetRest // ignore: cast_nullable_to_non_nullable
as int?,repeaterSplitHand: freezed == repeaterSplitHand ? _self.repeaterSplitHand : repeaterSplitHand // ignore: cast_nullable_to_non_nullable
as bool?,repDatas: freezed == repDatas ? _self.repDatas : repDatas // ignore: cast_nullable_to_non_nullable
as List<RepDataRequest>?,assessments: freezed == assessments ? _self.assessments : assessments // ignore: cast_nullable_to_non_nullable
as List<AssessmentRequest>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateSessionRequest].
extension CreateSessionRequestPatterns on CreateSessionRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateSessionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateSessionRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateSessionRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateSessionRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateSessionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateSessionRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String notes,  int duration, @JsonKey(name: 'is_assessment')  bool isAssessment, @JsonKey(name: 'session_type')  int sessionType, @JsonKey(name: 'repeater_sets')  int? repeaterSets, @JsonKey(name: 'repeater_reps')  int? repeaterReps, @JsonKey(name: 'repeater_work_time')  int? repeaterWorkTime, @JsonKey(name: 'repeater_rest_time')  int? repeaterRestTime, @JsonKey(name: 'repeater_set_rest')  int? repeaterSetRest, @JsonKey(name: 'repeater_split_hand')  bool? repeaterSplitHand, @JsonKey(name: 'rep_datas')  List<RepDataRequest>? repDatas,  List<AssessmentRequest>? assessments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateSessionRequest() when $default != null:
return $default(_that.name,_that.notes,_that.duration,_that.isAssessment,_that.sessionType,_that.repeaterSets,_that.repeaterReps,_that.repeaterWorkTime,_that.repeaterRestTime,_that.repeaterSetRest,_that.repeaterSplitHand,_that.repDatas,_that.assessments);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String notes,  int duration, @JsonKey(name: 'is_assessment')  bool isAssessment, @JsonKey(name: 'session_type')  int sessionType, @JsonKey(name: 'repeater_sets')  int? repeaterSets, @JsonKey(name: 'repeater_reps')  int? repeaterReps, @JsonKey(name: 'repeater_work_time')  int? repeaterWorkTime, @JsonKey(name: 'repeater_rest_time')  int? repeaterRestTime, @JsonKey(name: 'repeater_set_rest')  int? repeaterSetRest, @JsonKey(name: 'repeater_split_hand')  bool? repeaterSplitHand, @JsonKey(name: 'rep_datas')  List<RepDataRequest>? repDatas,  List<AssessmentRequest>? assessments)  $default,) {final _that = this;
switch (_that) {
case _CreateSessionRequest():
return $default(_that.name,_that.notes,_that.duration,_that.isAssessment,_that.sessionType,_that.repeaterSets,_that.repeaterReps,_that.repeaterWorkTime,_that.repeaterRestTime,_that.repeaterSetRest,_that.repeaterSplitHand,_that.repDatas,_that.assessments);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String notes,  int duration, @JsonKey(name: 'is_assessment')  bool isAssessment, @JsonKey(name: 'session_type')  int sessionType, @JsonKey(name: 'repeater_sets')  int? repeaterSets, @JsonKey(name: 'repeater_reps')  int? repeaterReps, @JsonKey(name: 'repeater_work_time')  int? repeaterWorkTime, @JsonKey(name: 'repeater_rest_time')  int? repeaterRestTime, @JsonKey(name: 'repeater_set_rest')  int? repeaterSetRest, @JsonKey(name: 'repeater_split_hand')  bool? repeaterSplitHand, @JsonKey(name: 'rep_datas')  List<RepDataRequest>? repDatas,  List<AssessmentRequest>? assessments)?  $default,) {final _that = this;
switch (_that) {
case _CreateSessionRequest() when $default != null:
return $default(_that.name,_that.notes,_that.duration,_that.isAssessment,_that.sessionType,_that.repeaterSets,_that.repeaterReps,_that.repeaterWorkTime,_that.repeaterRestTime,_that.repeaterSetRest,_that.repeaterSplitHand,_that.repDatas,_that.assessments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateSessionRequest implements CreateSessionRequest {
  const _CreateSessionRequest({required this.name, required this.notes, required this.duration, @JsonKey(name: 'is_assessment') required this.isAssessment, @JsonKey(name: 'session_type') required this.sessionType, @JsonKey(name: 'repeater_sets') this.repeaterSets, @JsonKey(name: 'repeater_reps') this.repeaterReps, @JsonKey(name: 'repeater_work_time') this.repeaterWorkTime, @JsonKey(name: 'repeater_rest_time') this.repeaterRestTime, @JsonKey(name: 'repeater_set_rest') this.repeaterSetRest, @JsonKey(name: 'repeater_split_hand') this.repeaterSplitHand, @JsonKey(name: 'rep_datas') final  List<RepDataRequest>? repDatas, final  List<AssessmentRequest>? assessments}): _repDatas = repDatas,_assessments = assessments;
  factory _CreateSessionRequest.fromJson(Map<String, dynamic> json) => _$CreateSessionRequestFromJson(json);

@override final  String name;
@override final  String notes;
@override final  int duration;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'is_assessment') final  bool isAssessment;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'session_type') final  int sessionType;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_sets') final  int? repeaterSets;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_reps') final  int? repeaterReps;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_work_time') final  int? repeaterWorkTime;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_rest_time') final  int? repeaterRestTime;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_set_rest') final  int? repeaterSetRest;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_split_hand') final  bool? repeaterSplitHand;
// ignore: invalid_annotation_target
 final  List<RepDataRequest>? _repDatas;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'rep_datas') List<RepDataRequest>? get repDatas {
  final value = _repDatas;
  if (value == null) return null;
  if (_repDatas is EqualUnmodifiableListView) return _repDatas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<AssessmentRequest>? _assessments;
@override List<AssessmentRequest>? get assessments {
  final value = _assessments;
  if (value == null) return null;
  if (_assessments is EqualUnmodifiableListView) return _assessments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CreateSessionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateSessionRequestCopyWith<_CreateSessionRequest> get copyWith => __$CreateSessionRequestCopyWithImpl<_CreateSessionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateSessionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateSessionRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.isAssessment, isAssessment) || other.isAssessment == isAssessment)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.repeaterSets, repeaterSets) || other.repeaterSets == repeaterSets)&&(identical(other.repeaterReps, repeaterReps) || other.repeaterReps == repeaterReps)&&(identical(other.repeaterWorkTime, repeaterWorkTime) || other.repeaterWorkTime == repeaterWorkTime)&&(identical(other.repeaterRestTime, repeaterRestTime) || other.repeaterRestTime == repeaterRestTime)&&(identical(other.repeaterSetRest, repeaterSetRest) || other.repeaterSetRest == repeaterSetRest)&&(identical(other.repeaterSplitHand, repeaterSplitHand) || other.repeaterSplitHand == repeaterSplitHand)&&const DeepCollectionEquality().equals(other._repDatas, _repDatas)&&const DeepCollectionEquality().equals(other._assessments, _assessments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,notes,duration,isAssessment,sessionType,repeaterSets,repeaterReps,repeaterWorkTime,repeaterRestTime,repeaterSetRest,repeaterSplitHand,const DeepCollectionEquality().hash(_repDatas),const DeepCollectionEquality().hash(_assessments));

@override
String toString() {
  return 'CreateSessionRequest(name: $name, notes: $notes, duration: $duration, isAssessment: $isAssessment, sessionType: $sessionType, repeaterSets: $repeaterSets, repeaterReps: $repeaterReps, repeaterWorkTime: $repeaterWorkTime, repeaterRestTime: $repeaterRestTime, repeaterSetRest: $repeaterSetRest, repeaterSplitHand: $repeaterSplitHand, repDatas: $repDatas, assessments: $assessments)';
}


}

/// @nodoc
abstract mixin class _$CreateSessionRequestCopyWith<$Res> implements $CreateSessionRequestCopyWith<$Res> {
  factory _$CreateSessionRequestCopyWith(_CreateSessionRequest value, $Res Function(_CreateSessionRequest) _then) = __$CreateSessionRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String notes, int duration,@JsonKey(name: 'is_assessment') bool isAssessment,@JsonKey(name: 'session_type') int sessionType,@JsonKey(name: 'repeater_sets') int? repeaterSets,@JsonKey(name: 'repeater_reps') int? repeaterReps,@JsonKey(name: 'repeater_work_time') int? repeaterWorkTime,@JsonKey(name: 'repeater_rest_time') int? repeaterRestTime,@JsonKey(name: 'repeater_set_rest') int? repeaterSetRest,@JsonKey(name: 'repeater_split_hand') bool? repeaterSplitHand,@JsonKey(name: 'rep_datas') List<RepDataRequest>? repDatas, List<AssessmentRequest>? assessments
});




}
/// @nodoc
class __$CreateSessionRequestCopyWithImpl<$Res>
    implements _$CreateSessionRequestCopyWith<$Res> {
  __$CreateSessionRequestCopyWithImpl(this._self, this._then);

  final _CreateSessionRequest _self;
  final $Res Function(_CreateSessionRequest) _then;

/// Create a copy of CreateSessionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? notes = null,Object? duration = null,Object? isAssessment = null,Object? sessionType = null,Object? repeaterSets = freezed,Object? repeaterReps = freezed,Object? repeaterWorkTime = freezed,Object? repeaterRestTime = freezed,Object? repeaterSetRest = freezed,Object? repeaterSplitHand = freezed,Object? repDatas = freezed,Object? assessments = freezed,}) {
  return _then(_CreateSessionRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,isAssessment: null == isAssessment ? _self.isAssessment : isAssessment // ignore: cast_nullable_to_non_nullable
as bool,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as int,repeaterSets: freezed == repeaterSets ? _self.repeaterSets : repeaterSets // ignore: cast_nullable_to_non_nullable
as int?,repeaterReps: freezed == repeaterReps ? _self.repeaterReps : repeaterReps // ignore: cast_nullable_to_non_nullable
as int?,repeaterWorkTime: freezed == repeaterWorkTime ? _self.repeaterWorkTime : repeaterWorkTime // ignore: cast_nullable_to_non_nullable
as int?,repeaterRestTime: freezed == repeaterRestTime ? _self.repeaterRestTime : repeaterRestTime // ignore: cast_nullable_to_non_nullable
as int?,repeaterSetRest: freezed == repeaterSetRest ? _self.repeaterSetRest : repeaterSetRest // ignore: cast_nullable_to_non_nullable
as int?,repeaterSplitHand: freezed == repeaterSplitHand ? _self.repeaterSplitHand : repeaterSplitHand // ignore: cast_nullable_to_non_nullable
as bool?,repDatas: freezed == repDatas ? _self._repDatas : repDatas // ignore: cast_nullable_to_non_nullable
as List<RepDataRequest>?,assessments: freezed == assessments ? _self._assessments : assessments // ignore: cast_nullable_to_non_nullable
as List<AssessmentRequest>?,
  ));
}


}


/// @nodoc
mixin _$UpdateSessionRequest {

 String? get name; String? get notes; int? get duration;
/// Create a copy of UpdateSessionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateSessionRequestCopyWith<UpdateSessionRequest> get copyWith => _$UpdateSessionRequestCopyWithImpl<UpdateSessionRequest>(this as UpdateSessionRequest, _$identity);

  /// Serializes this UpdateSessionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateSessionRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,notes,duration);

@override
String toString() {
  return 'UpdateSessionRequest(name: $name, notes: $notes, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $UpdateSessionRequestCopyWith<$Res>  {
  factory $UpdateSessionRequestCopyWith(UpdateSessionRequest value, $Res Function(UpdateSessionRequest) _then) = _$UpdateSessionRequestCopyWithImpl;
@useResult
$Res call({
 String? name, String? notes, int? duration
});




}
/// @nodoc
class _$UpdateSessionRequestCopyWithImpl<$Res>
    implements $UpdateSessionRequestCopyWith<$Res> {
  _$UpdateSessionRequestCopyWithImpl(this._self, this._then);

  final UpdateSessionRequest _self;
  final $Res Function(UpdateSessionRequest) _then;

/// Create a copy of UpdateSessionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? notes = freezed,Object? duration = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateSessionRequest].
extension UpdateSessionRequestPatterns on UpdateSessionRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateSessionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateSessionRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateSessionRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateSessionRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateSessionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateSessionRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? notes,  int? duration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateSessionRequest() when $default != null:
return $default(_that.name,_that.notes,_that.duration);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? notes,  int? duration)  $default,) {final _that = this;
switch (_that) {
case _UpdateSessionRequest():
return $default(_that.name,_that.notes,_that.duration);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? notes,  int? duration)?  $default,) {final _that = this;
switch (_that) {
case _UpdateSessionRequest() when $default != null:
return $default(_that.name,_that.notes,_that.duration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateSessionRequest implements UpdateSessionRequest {
  const _UpdateSessionRequest({this.name, this.notes, this.duration});
  factory _UpdateSessionRequest.fromJson(Map<String, dynamic> json) => _$UpdateSessionRequestFromJson(json);

@override final  String? name;
@override final  String? notes;
@override final  int? duration;

/// Create a copy of UpdateSessionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateSessionRequestCopyWith<_UpdateSessionRequest> get copyWith => __$UpdateSessionRequestCopyWithImpl<_UpdateSessionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateSessionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateSessionRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,notes,duration);

@override
String toString() {
  return 'UpdateSessionRequest(name: $name, notes: $notes, duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$UpdateSessionRequestCopyWith<$Res> implements $UpdateSessionRequestCopyWith<$Res> {
  factory _$UpdateSessionRequestCopyWith(_UpdateSessionRequest value, $Res Function(_UpdateSessionRequest) _then) = __$UpdateSessionRequestCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? notes, int? duration
});




}
/// @nodoc
class __$UpdateSessionRequestCopyWithImpl<$Res>
    implements _$UpdateSessionRequestCopyWith<$Res> {
  __$UpdateSessionRequestCopyWithImpl(this._self, this._then);

  final _UpdateSessionRequest _self;
  final $Res Function(_UpdateSessionRequest) _then;

/// Create a copy of UpdateSessionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? notes = freezed,Object? duration = freezed,}) {
  return _then(_UpdateSessionRequest(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$RepDataRequest {

 int get index;// ignore: invalid_annotation_target
@JsonKey(name: 'is_rest') bool get isRest;// ignore: invalid_annotation_target
@JsonKey(name: 'right_hand') bool get rightHand; int get duration;// ignore: invalid_annotation_target
@JsonKey(name: 'target_weight') double get targetWeight;// ignore: invalid_annotation_target
@JsonKey(name: 'average_weight') double get averageWeight;// ignore: invalid_annotation_target
@JsonKey(name: 'grip_position') int get gripPosition;
/// Create a copy of RepDataRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepDataRequestCopyWith<RepDataRequest> get copyWith => _$RepDataRequestCopyWithImpl<RepDataRequest>(this as RepDataRequest, _$identity);

  /// Serializes this RepDataRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepDataRequest&&(identical(other.index, index) || other.index == index)&&(identical(other.isRest, isRest) || other.isRest == isRest)&&(identical(other.rightHand, rightHand) || other.rightHand == rightHand)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.targetWeight, targetWeight) || other.targetWeight == targetWeight)&&(identical(other.averageWeight, averageWeight) || other.averageWeight == averageWeight)&&(identical(other.gripPosition, gripPosition) || other.gripPosition == gripPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,isRest,rightHand,duration,targetWeight,averageWeight,gripPosition);

@override
String toString() {
  return 'RepDataRequest(index: $index, isRest: $isRest, rightHand: $rightHand, duration: $duration, targetWeight: $targetWeight, averageWeight: $averageWeight, gripPosition: $gripPosition)';
}


}

/// @nodoc
abstract mixin class $RepDataRequestCopyWith<$Res>  {
  factory $RepDataRequestCopyWith(RepDataRequest value, $Res Function(RepDataRequest) _then) = _$RepDataRequestCopyWithImpl;
@useResult
$Res call({
 int index,@JsonKey(name: 'is_rest') bool isRest,@JsonKey(name: 'right_hand') bool rightHand, int duration,@JsonKey(name: 'target_weight') double targetWeight,@JsonKey(name: 'average_weight') double averageWeight,@JsonKey(name: 'grip_position') int gripPosition
});




}
/// @nodoc
class _$RepDataRequestCopyWithImpl<$Res>
    implements $RepDataRequestCopyWith<$Res> {
  _$RepDataRequestCopyWithImpl(this._self, this._then);

  final RepDataRequest _self;
  final $Res Function(RepDataRequest) _then;

/// Create a copy of RepDataRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? isRest = null,Object? rightHand = null,Object? duration = null,Object? targetWeight = null,Object? averageWeight = null,Object? gripPosition = null,}) {
  return _then(_self.copyWith(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,isRest: null == isRest ? _self.isRest : isRest // ignore: cast_nullable_to_non_nullable
as bool,rightHand: null == rightHand ? _self.rightHand : rightHand // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,targetWeight: null == targetWeight ? _self.targetWeight : targetWeight // ignore: cast_nullable_to_non_nullable
as double,averageWeight: null == averageWeight ? _self.averageWeight : averageWeight // ignore: cast_nullable_to_non_nullable
as double,gripPosition: null == gripPosition ? _self.gripPosition : gripPosition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RepDataRequest].
extension RepDataRequestPatterns on RepDataRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepDataRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepDataRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepDataRequest value)  $default,){
final _that = this;
switch (_that) {
case _RepDataRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepDataRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RepDataRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index, @JsonKey(name: 'is_rest')  bool isRest, @JsonKey(name: 'right_hand')  bool rightHand,  int duration, @JsonKey(name: 'target_weight')  double targetWeight, @JsonKey(name: 'average_weight')  double averageWeight, @JsonKey(name: 'grip_position')  int gripPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepDataRequest() when $default != null:
return $default(_that.index,_that.isRest,_that.rightHand,_that.duration,_that.targetWeight,_that.averageWeight,_that.gripPosition);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index, @JsonKey(name: 'is_rest')  bool isRest, @JsonKey(name: 'right_hand')  bool rightHand,  int duration, @JsonKey(name: 'target_weight')  double targetWeight, @JsonKey(name: 'average_weight')  double averageWeight, @JsonKey(name: 'grip_position')  int gripPosition)  $default,) {final _that = this;
switch (_that) {
case _RepDataRequest():
return $default(_that.index,_that.isRest,_that.rightHand,_that.duration,_that.targetWeight,_that.averageWeight,_that.gripPosition);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index, @JsonKey(name: 'is_rest')  bool isRest, @JsonKey(name: 'right_hand')  bool rightHand,  int duration, @JsonKey(name: 'target_weight')  double targetWeight, @JsonKey(name: 'average_weight')  double averageWeight, @JsonKey(name: 'grip_position')  int gripPosition)?  $default,) {final _that = this;
switch (_that) {
case _RepDataRequest() when $default != null:
return $default(_that.index,_that.isRest,_that.rightHand,_that.duration,_that.targetWeight,_that.averageWeight,_that.gripPosition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepDataRequest implements RepDataRequest {
  const _RepDataRequest({required this.index, @JsonKey(name: 'is_rest') required this.isRest, @JsonKey(name: 'right_hand') required this.rightHand, required this.duration, @JsonKey(name: 'target_weight') required this.targetWeight, @JsonKey(name: 'average_weight') required this.averageWeight, @JsonKey(name: 'grip_position') required this.gripPosition});
  factory _RepDataRequest.fromJson(Map<String, dynamic> json) => _$RepDataRequestFromJson(json);

@override final  int index;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'is_rest') final  bool isRest;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'right_hand') final  bool rightHand;
@override final  int duration;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'target_weight') final  double targetWeight;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'average_weight') final  double averageWeight;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'grip_position') final  int gripPosition;

/// Create a copy of RepDataRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepDataRequestCopyWith<_RepDataRequest> get copyWith => __$RepDataRequestCopyWithImpl<_RepDataRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepDataRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepDataRequest&&(identical(other.index, index) || other.index == index)&&(identical(other.isRest, isRest) || other.isRest == isRest)&&(identical(other.rightHand, rightHand) || other.rightHand == rightHand)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.targetWeight, targetWeight) || other.targetWeight == targetWeight)&&(identical(other.averageWeight, averageWeight) || other.averageWeight == averageWeight)&&(identical(other.gripPosition, gripPosition) || other.gripPosition == gripPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,isRest,rightHand,duration,targetWeight,averageWeight,gripPosition);

@override
String toString() {
  return 'RepDataRequest(index: $index, isRest: $isRest, rightHand: $rightHand, duration: $duration, targetWeight: $targetWeight, averageWeight: $averageWeight, gripPosition: $gripPosition)';
}


}

/// @nodoc
abstract mixin class _$RepDataRequestCopyWith<$Res> implements $RepDataRequestCopyWith<$Res> {
  factory _$RepDataRequestCopyWith(_RepDataRequest value, $Res Function(_RepDataRequest) _then) = __$RepDataRequestCopyWithImpl;
@override @useResult
$Res call({
 int index,@JsonKey(name: 'is_rest') bool isRest,@JsonKey(name: 'right_hand') bool rightHand, int duration,@JsonKey(name: 'target_weight') double targetWeight,@JsonKey(name: 'average_weight') double averageWeight,@JsonKey(name: 'grip_position') int gripPosition
});




}
/// @nodoc
class __$RepDataRequestCopyWithImpl<$Res>
    implements _$RepDataRequestCopyWith<$Res> {
  __$RepDataRequestCopyWithImpl(this._self, this._then);

  final _RepDataRequest _self;
  final $Res Function(_RepDataRequest) _then;

/// Create a copy of RepDataRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? isRest = null,Object? rightHand = null,Object? duration = null,Object? targetWeight = null,Object? averageWeight = null,Object? gripPosition = null,}) {
  return _then(_RepDataRequest(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,isRest: null == isRest ? _self.isRest : isRest // ignore: cast_nullable_to_non_nullable
as bool,rightHand: null == rightHand ? _self.rightHand : rightHand // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,targetWeight: null == targetWeight ? _self.targetWeight : targetWeight // ignore: cast_nullable_to_non_nullable
as double,averageWeight: null == averageWeight ? _self.averageWeight : averageWeight // ignore: cast_nullable_to_non_nullable
as double,gripPosition: null == gripPosition ? _self.gripPosition : gripPosition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AssessmentRequest {

 int get type;// ignore: invalid_annotation_target
@JsonKey(name: 'right_value') double? get rightValue;// ignore: invalid_annotation_target
@JsonKey(name: 'left_value') double? get leftValue;// ignore: invalid_annotation_target
@JsonKey(name: 'grip_position') int? get gripPosition;
/// Create a copy of AssessmentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssessmentRequestCopyWith<AssessmentRequest> get copyWith => _$AssessmentRequestCopyWithImpl<AssessmentRequest>(this as AssessmentRequest, _$identity);

  /// Serializes this AssessmentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssessmentRequest&&(identical(other.type, type) || other.type == type)&&(identical(other.rightValue, rightValue) || other.rightValue == rightValue)&&(identical(other.leftValue, leftValue) || other.leftValue == leftValue)&&(identical(other.gripPosition, gripPosition) || other.gripPosition == gripPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,rightValue,leftValue,gripPosition);

@override
String toString() {
  return 'AssessmentRequest(type: $type, rightValue: $rightValue, leftValue: $leftValue, gripPosition: $gripPosition)';
}


}

/// @nodoc
abstract mixin class $AssessmentRequestCopyWith<$Res>  {
  factory $AssessmentRequestCopyWith(AssessmentRequest value, $Res Function(AssessmentRequest) _then) = _$AssessmentRequestCopyWithImpl;
@useResult
$Res call({
 int type,@JsonKey(name: 'right_value') double? rightValue,@JsonKey(name: 'left_value') double? leftValue,@JsonKey(name: 'grip_position') int? gripPosition
});




}
/// @nodoc
class _$AssessmentRequestCopyWithImpl<$Res>
    implements $AssessmentRequestCopyWith<$Res> {
  _$AssessmentRequestCopyWithImpl(this._self, this._then);

  final AssessmentRequest _self;
  final $Res Function(AssessmentRequest) _then;

/// Create a copy of AssessmentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? rightValue = freezed,Object? leftValue = freezed,Object? gripPosition = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,rightValue: freezed == rightValue ? _self.rightValue : rightValue // ignore: cast_nullable_to_non_nullable
as double?,leftValue: freezed == leftValue ? _self.leftValue : leftValue // ignore: cast_nullable_to_non_nullable
as double?,gripPosition: freezed == gripPosition ? _self.gripPosition : gripPosition // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssessmentRequest].
extension AssessmentRequestPatterns on AssessmentRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssessmentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssessmentRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssessmentRequest value)  $default,){
final _that = this;
switch (_that) {
case _AssessmentRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssessmentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AssessmentRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int type, @JsonKey(name: 'right_value')  double? rightValue, @JsonKey(name: 'left_value')  double? leftValue, @JsonKey(name: 'grip_position')  int? gripPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssessmentRequest() when $default != null:
return $default(_that.type,_that.rightValue,_that.leftValue,_that.gripPosition);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int type, @JsonKey(name: 'right_value')  double? rightValue, @JsonKey(name: 'left_value')  double? leftValue, @JsonKey(name: 'grip_position')  int? gripPosition)  $default,) {final _that = this;
switch (_that) {
case _AssessmentRequest():
return $default(_that.type,_that.rightValue,_that.leftValue,_that.gripPosition);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int type, @JsonKey(name: 'right_value')  double? rightValue, @JsonKey(name: 'left_value')  double? leftValue, @JsonKey(name: 'grip_position')  int? gripPosition)?  $default,) {final _that = this;
switch (_that) {
case _AssessmentRequest() when $default != null:
return $default(_that.type,_that.rightValue,_that.leftValue,_that.gripPosition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssessmentRequest implements AssessmentRequest {
  const _AssessmentRequest({required this.type, @JsonKey(name: 'right_value') this.rightValue, @JsonKey(name: 'left_value') this.leftValue, @JsonKey(name: 'grip_position') this.gripPosition});
  factory _AssessmentRequest.fromJson(Map<String, dynamic> json) => _$AssessmentRequestFromJson(json);

@override final  int type;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'right_value') final  double? rightValue;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'left_value') final  double? leftValue;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'grip_position') final  int? gripPosition;

/// Create a copy of AssessmentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssessmentRequestCopyWith<_AssessmentRequest> get copyWith => __$AssessmentRequestCopyWithImpl<_AssessmentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssessmentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssessmentRequest&&(identical(other.type, type) || other.type == type)&&(identical(other.rightValue, rightValue) || other.rightValue == rightValue)&&(identical(other.leftValue, leftValue) || other.leftValue == leftValue)&&(identical(other.gripPosition, gripPosition) || other.gripPosition == gripPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,rightValue,leftValue,gripPosition);

@override
String toString() {
  return 'AssessmentRequest(type: $type, rightValue: $rightValue, leftValue: $leftValue, gripPosition: $gripPosition)';
}


}

/// @nodoc
abstract mixin class _$AssessmentRequestCopyWith<$Res> implements $AssessmentRequestCopyWith<$Res> {
  factory _$AssessmentRequestCopyWith(_AssessmentRequest value, $Res Function(_AssessmentRequest) _then) = __$AssessmentRequestCopyWithImpl;
@override @useResult
$Res call({
 int type,@JsonKey(name: 'right_value') double? rightValue,@JsonKey(name: 'left_value') double? leftValue,@JsonKey(name: 'grip_position') int? gripPosition
});




}
/// @nodoc
class __$AssessmentRequestCopyWithImpl<$Res>
    implements _$AssessmentRequestCopyWith<$Res> {
  __$AssessmentRequestCopyWithImpl(this._self, this._then);

  final _AssessmentRequest _self;
  final $Res Function(_AssessmentRequest) _then;

/// Create a copy of AssessmentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? rightValue = freezed,Object? leftValue = freezed,Object? gripPosition = freezed,}) {
  return _then(_AssessmentRequest(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,rightValue: freezed == rightValue ? _self.rightValue : rightValue // ignore: cast_nullable_to_non_nullable
as double?,leftValue: freezed == leftValue ? _self.leftValue : leftValue // ignore: cast_nullable_to_non_nullable
as double?,gripPosition: freezed == gripPosition ? _self.gripPosition : gripPosition // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$TrainingResponse {

 int get id; String get name;// ignore: invalid_annotation_target
@JsonKey(name: 'is_assessment') bool get isAssessment;// ignore: invalid_annotation_target
@JsonKey(name: 'is_favorite') bool get isFavorite;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_id') int? get repeaterId;// ignore: invalid_annotation_target
@JsonKey(name: 'user_id') String get userId;
/// Create a copy of TrainingResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingResponseCopyWith<TrainingResponse> get copyWith => _$TrainingResponseCopyWithImpl<TrainingResponse>(this as TrainingResponse, _$identity);

  /// Serializes this TrainingResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isAssessment, isAssessment) || other.isAssessment == isAssessment)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.repeaterId, repeaterId) || other.repeaterId == repeaterId)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isAssessment,isFavorite,repeaterId,userId);

@override
String toString() {
  return 'TrainingResponse(id: $id, name: $name, isAssessment: $isAssessment, isFavorite: $isFavorite, repeaterId: $repeaterId, userId: $userId)';
}


}

/// @nodoc
abstract mixin class $TrainingResponseCopyWith<$Res>  {
  factory $TrainingResponseCopyWith(TrainingResponse value, $Res Function(TrainingResponse) _then) = _$TrainingResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'is_assessment') bool isAssessment,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'repeater_id') int? repeaterId,@JsonKey(name: 'user_id') String userId
});




}
/// @nodoc
class _$TrainingResponseCopyWithImpl<$Res>
    implements $TrainingResponseCopyWith<$Res> {
  _$TrainingResponseCopyWithImpl(this._self, this._then);

  final TrainingResponse _self;
  final $Res Function(TrainingResponse) _then;

/// Create a copy of TrainingResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isAssessment = null,Object? isFavorite = null,Object? repeaterId = freezed,Object? userId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isAssessment: null == isAssessment ? _self.isAssessment : isAssessment // ignore: cast_nullable_to_non_nullable
as bool,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,repeaterId: freezed == repeaterId ? _self.repeaterId : repeaterId // ignore: cast_nullable_to_non_nullable
as int?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainingResponse].
extension TrainingResponsePatterns on TrainingResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainingResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainingResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainingResponse value)  $default,){
final _that = this;
switch (_that) {
case _TrainingResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainingResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TrainingResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'is_assessment')  bool isAssessment, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'repeater_id')  int? repeaterId, @JsonKey(name: 'user_id')  String userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingResponse() when $default != null:
return $default(_that.id,_that.name,_that.isAssessment,_that.isFavorite,_that.repeaterId,_that.userId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'is_assessment')  bool isAssessment, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'repeater_id')  int? repeaterId, @JsonKey(name: 'user_id')  String userId)  $default,) {final _that = this;
switch (_that) {
case _TrainingResponse():
return $default(_that.id,_that.name,_that.isAssessment,_that.isFavorite,_that.repeaterId,_that.userId);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'is_assessment')  bool isAssessment, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'repeater_id')  int? repeaterId, @JsonKey(name: 'user_id')  String userId)?  $default,) {final _that = this;
switch (_that) {
case _TrainingResponse() when $default != null:
return $default(_that.id,_that.name,_that.isAssessment,_that.isFavorite,_that.repeaterId,_that.userId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainingResponse implements TrainingResponse {
  const _TrainingResponse({required this.id, required this.name, @JsonKey(name: 'is_assessment') required this.isAssessment, @JsonKey(name: 'is_favorite') required this.isFavorite, @JsonKey(name: 'repeater_id') this.repeaterId, @JsonKey(name: 'user_id') required this.userId});
  factory _TrainingResponse.fromJson(Map<String, dynamic> json) => _$TrainingResponseFromJson(json);

@override final  int id;
@override final  String name;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'is_assessment') final  bool isAssessment;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'is_favorite') final  bool isFavorite;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_id') final  int? repeaterId;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'user_id') final  String userId;

/// Create a copy of TrainingResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainingResponseCopyWith<_TrainingResponse> get copyWith => __$TrainingResponseCopyWithImpl<_TrainingResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainingResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isAssessment, isAssessment) || other.isAssessment == isAssessment)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.repeaterId, repeaterId) || other.repeaterId == repeaterId)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isAssessment,isFavorite,repeaterId,userId);

@override
String toString() {
  return 'TrainingResponse(id: $id, name: $name, isAssessment: $isAssessment, isFavorite: $isFavorite, repeaterId: $repeaterId, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$TrainingResponseCopyWith<$Res> implements $TrainingResponseCopyWith<$Res> {
  factory _$TrainingResponseCopyWith(_TrainingResponse value, $Res Function(_TrainingResponse) _then) = __$TrainingResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'is_assessment') bool isAssessment,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'repeater_id') int? repeaterId,@JsonKey(name: 'user_id') String userId
});




}
/// @nodoc
class __$TrainingResponseCopyWithImpl<$Res>
    implements _$TrainingResponseCopyWith<$Res> {
  __$TrainingResponseCopyWithImpl(this._self, this._then);

  final _TrainingResponse _self;
  final $Res Function(_TrainingResponse) _then;

/// Create a copy of TrainingResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isAssessment = null,Object? isFavorite = null,Object? repeaterId = freezed,Object? userId = null,}) {
  return _then(_TrainingResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isAssessment: null == isAssessment ? _self.isAssessment : isAssessment // ignore: cast_nullable_to_non_nullable
as bool,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,repeaterId: freezed == repeaterId ? _self.repeaterId : repeaterId // ignore: cast_nullable_to_non_nullable
as int?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CreateTrainingRequest {

 String get name;// ignore: invalid_annotation_target
@JsonKey(name: 'is_assessment') bool get isAssessment;// ignore: invalid_annotation_target
@JsonKey(name: 'is_favorite') bool get isFavorite;// ignore: invalid_annotation_target
@JsonKey(name: 'repeater_id') int? get repeaterId;// ignore: invalid_annotation_target
@JsonKey(name: 'rep_templates') List<RepTemplateRequest>? get repTemplates;
/// Create a copy of CreateTrainingRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTrainingRequestCopyWith<CreateTrainingRequest> get copyWith => _$CreateTrainingRequestCopyWithImpl<CreateTrainingRequest>(this as CreateTrainingRequest, _$identity);

  /// Serializes this CreateTrainingRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTrainingRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.isAssessment, isAssessment) || other.isAssessment == isAssessment)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.repeaterId, repeaterId) || other.repeaterId == repeaterId)&&const DeepCollectionEquality().equals(other.repTemplates, repTemplates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,isAssessment,isFavorite,repeaterId,const DeepCollectionEquality().hash(repTemplates));

@override
String toString() {
  return 'CreateTrainingRequest(name: $name, isAssessment: $isAssessment, isFavorite: $isFavorite, repeaterId: $repeaterId, repTemplates: $repTemplates)';
}


}

/// @nodoc
abstract mixin class $CreateTrainingRequestCopyWith<$Res>  {
  factory $CreateTrainingRequestCopyWith(CreateTrainingRequest value, $Res Function(CreateTrainingRequest) _then) = _$CreateTrainingRequestCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(name: 'is_assessment') bool isAssessment,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'repeater_id') int? repeaterId,@JsonKey(name: 'rep_templates') List<RepTemplateRequest>? repTemplates
});




}
/// @nodoc
class _$CreateTrainingRequestCopyWithImpl<$Res>
    implements $CreateTrainingRequestCopyWith<$Res> {
  _$CreateTrainingRequestCopyWithImpl(this._self, this._then);

  final CreateTrainingRequest _self;
  final $Res Function(CreateTrainingRequest) _then;

/// Create a copy of CreateTrainingRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? isAssessment = null,Object? isFavorite = null,Object? repeaterId = freezed,Object? repTemplates = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isAssessment: null == isAssessment ? _self.isAssessment : isAssessment // ignore: cast_nullable_to_non_nullable
as bool,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,repeaterId: freezed == repeaterId ? _self.repeaterId : repeaterId // ignore: cast_nullable_to_non_nullable
as int?,repTemplates: freezed == repTemplates ? _self.repTemplates : repTemplates // ignore: cast_nullable_to_non_nullable
as List<RepTemplateRequest>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateTrainingRequest].
extension CreateTrainingRequestPatterns on CreateTrainingRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateTrainingRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateTrainingRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateTrainingRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateTrainingRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateTrainingRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateTrainingRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'is_assessment')  bool isAssessment, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'repeater_id')  int? repeaterId, @JsonKey(name: 'rep_templates')  List<RepTemplateRequest>? repTemplates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateTrainingRequest() when $default != null:
return $default(_that.name,_that.isAssessment,_that.isFavorite,_that.repeaterId,_that.repTemplates);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'is_assessment')  bool isAssessment, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'repeater_id')  int? repeaterId, @JsonKey(name: 'rep_templates')  List<RepTemplateRequest>? repTemplates)  $default,) {final _that = this;
switch (_that) {
case _CreateTrainingRequest():
return $default(_that.name,_that.isAssessment,_that.isFavorite,_that.repeaterId,_that.repTemplates);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(name: 'is_assessment')  bool isAssessment, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'repeater_id')  int? repeaterId, @JsonKey(name: 'rep_templates')  List<RepTemplateRequest>? repTemplates)?  $default,) {final _that = this;
switch (_that) {
case _CreateTrainingRequest() when $default != null:
return $default(_that.name,_that.isAssessment,_that.isFavorite,_that.repeaterId,_that.repTemplates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateTrainingRequest implements CreateTrainingRequest {
  const _CreateTrainingRequest({required this.name, @JsonKey(name: 'is_assessment') required this.isAssessment, @JsonKey(name: 'is_favorite') required this.isFavorite, @JsonKey(name: 'repeater_id') this.repeaterId, @JsonKey(name: 'rep_templates') final  List<RepTemplateRequest>? repTemplates}): _repTemplates = repTemplates;
  factory _CreateTrainingRequest.fromJson(Map<String, dynamic> json) => _$CreateTrainingRequestFromJson(json);

@override final  String name;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'is_assessment') final  bool isAssessment;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'is_favorite') final  bool isFavorite;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'repeater_id') final  int? repeaterId;
// ignore: invalid_annotation_target
 final  List<RepTemplateRequest>? _repTemplates;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'rep_templates') List<RepTemplateRequest>? get repTemplates {
  final value = _repTemplates;
  if (value == null) return null;
  if (_repTemplates is EqualUnmodifiableListView) return _repTemplates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CreateTrainingRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateTrainingRequestCopyWith<_CreateTrainingRequest> get copyWith => __$CreateTrainingRequestCopyWithImpl<_CreateTrainingRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateTrainingRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateTrainingRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.isAssessment, isAssessment) || other.isAssessment == isAssessment)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.repeaterId, repeaterId) || other.repeaterId == repeaterId)&&const DeepCollectionEquality().equals(other._repTemplates, _repTemplates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,isAssessment,isFavorite,repeaterId,const DeepCollectionEquality().hash(_repTemplates));

@override
String toString() {
  return 'CreateTrainingRequest(name: $name, isAssessment: $isAssessment, isFavorite: $isFavorite, repeaterId: $repeaterId, repTemplates: $repTemplates)';
}


}

/// @nodoc
abstract mixin class _$CreateTrainingRequestCopyWith<$Res> implements $CreateTrainingRequestCopyWith<$Res> {
  factory _$CreateTrainingRequestCopyWith(_CreateTrainingRequest value, $Res Function(_CreateTrainingRequest) _then) = __$CreateTrainingRequestCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(name: 'is_assessment') bool isAssessment,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'repeater_id') int? repeaterId,@JsonKey(name: 'rep_templates') List<RepTemplateRequest>? repTemplates
});




}
/// @nodoc
class __$CreateTrainingRequestCopyWithImpl<$Res>
    implements _$CreateTrainingRequestCopyWith<$Res> {
  __$CreateTrainingRequestCopyWithImpl(this._self, this._then);

  final _CreateTrainingRequest _self;
  final $Res Function(_CreateTrainingRequest) _then;

/// Create a copy of CreateTrainingRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? isAssessment = null,Object? isFavorite = null,Object? repeaterId = freezed,Object? repTemplates = freezed,}) {
  return _then(_CreateTrainingRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isAssessment: null == isAssessment ? _self.isAssessment : isAssessment // ignore: cast_nullable_to_non_nullable
as bool,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,repeaterId: freezed == repeaterId ? _self.repeaterId : repeaterId // ignore: cast_nullable_to_non_nullable
as int?,repTemplates: freezed == repTemplates ? _self._repTemplates : repTemplates // ignore: cast_nullable_to_non_nullable
as List<RepTemplateRequest>?,
  ));
}


}


/// @nodoc
mixin _$UpdateTrainingRequest {

 String? get name;// ignore: invalid_annotation_target
@JsonKey(name: 'is_favorite') bool? get isFavorite;
/// Create a copy of UpdateTrainingRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateTrainingRequestCopyWith<UpdateTrainingRequest> get copyWith => _$UpdateTrainingRequestCopyWithImpl<UpdateTrainingRequest>(this as UpdateTrainingRequest, _$identity);

  /// Serializes this UpdateTrainingRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateTrainingRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,isFavorite);

@override
String toString() {
  return 'UpdateTrainingRequest(name: $name, isFavorite: $isFavorite)';
}


}

/// @nodoc
abstract mixin class $UpdateTrainingRequestCopyWith<$Res>  {
  factory $UpdateTrainingRequestCopyWith(UpdateTrainingRequest value, $Res Function(UpdateTrainingRequest) _then) = _$UpdateTrainingRequestCopyWithImpl;
@useResult
$Res call({
 String? name,@JsonKey(name: 'is_favorite') bool? isFavorite
});




}
/// @nodoc
class _$UpdateTrainingRequestCopyWithImpl<$Res>
    implements $UpdateTrainingRequestCopyWith<$Res> {
  _$UpdateTrainingRequestCopyWithImpl(this._self, this._then);

  final UpdateTrainingRequest _self;
  final $Res Function(UpdateTrainingRequest) _then;

/// Create a copy of UpdateTrainingRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? isFavorite = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: freezed == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateTrainingRequest].
extension UpdateTrainingRequestPatterns on UpdateTrainingRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateTrainingRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateTrainingRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateTrainingRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateTrainingRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateTrainingRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateTrainingRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name, @JsonKey(name: 'is_favorite')  bool? isFavorite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateTrainingRequest() when $default != null:
return $default(_that.name,_that.isFavorite);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name, @JsonKey(name: 'is_favorite')  bool? isFavorite)  $default,) {final _that = this;
switch (_that) {
case _UpdateTrainingRequest():
return $default(_that.name,_that.isFavorite);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name, @JsonKey(name: 'is_favorite')  bool? isFavorite)?  $default,) {final _that = this;
switch (_that) {
case _UpdateTrainingRequest() when $default != null:
return $default(_that.name,_that.isFavorite);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateTrainingRequest implements UpdateTrainingRequest {
  const _UpdateTrainingRequest({this.name, @JsonKey(name: 'is_favorite') this.isFavorite});
  factory _UpdateTrainingRequest.fromJson(Map<String, dynamic> json) => _$UpdateTrainingRequestFromJson(json);

@override final  String? name;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'is_favorite') final  bool? isFavorite;

/// Create a copy of UpdateTrainingRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateTrainingRequestCopyWith<_UpdateTrainingRequest> get copyWith => __$UpdateTrainingRequestCopyWithImpl<_UpdateTrainingRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateTrainingRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateTrainingRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,isFavorite);

@override
String toString() {
  return 'UpdateTrainingRequest(name: $name, isFavorite: $isFavorite)';
}


}

/// @nodoc
abstract mixin class _$UpdateTrainingRequestCopyWith<$Res> implements $UpdateTrainingRequestCopyWith<$Res> {
  factory _$UpdateTrainingRequestCopyWith(_UpdateTrainingRequest value, $Res Function(_UpdateTrainingRequest) _then) = __$UpdateTrainingRequestCopyWithImpl;
@override @useResult
$Res call({
 String? name,@JsonKey(name: 'is_favorite') bool? isFavorite
});




}
/// @nodoc
class __$UpdateTrainingRequestCopyWithImpl<$Res>
    implements _$UpdateTrainingRequestCopyWith<$Res> {
  __$UpdateTrainingRequestCopyWithImpl(this._self, this._then);

  final _UpdateTrainingRequest _self;
  final $Res Function(_UpdateTrainingRequest) _then;

/// Create a copy of UpdateTrainingRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? isFavorite = freezed,}) {
  return _then(_UpdateTrainingRequest(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: freezed == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$RepTemplateRequest {

 int get index;// ignore: invalid_annotation_target
@JsonKey(name: 'is_rest') bool get isRest;// ignore: invalid_annotation_target
@JsonKey(name: 'right_hand') bool get rightHand; int get duration;// ignore: invalid_annotation_target
@JsonKey(name: 'target_weight') double get targetWeight;// ignore: invalid_annotation_target
@JsonKey(name: 'grip_position') int get gripPosition;
/// Create a copy of RepTemplateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepTemplateRequestCopyWith<RepTemplateRequest> get copyWith => _$RepTemplateRequestCopyWithImpl<RepTemplateRequest>(this as RepTemplateRequest, _$identity);

  /// Serializes this RepTemplateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepTemplateRequest&&(identical(other.index, index) || other.index == index)&&(identical(other.isRest, isRest) || other.isRest == isRest)&&(identical(other.rightHand, rightHand) || other.rightHand == rightHand)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.targetWeight, targetWeight) || other.targetWeight == targetWeight)&&(identical(other.gripPosition, gripPosition) || other.gripPosition == gripPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,isRest,rightHand,duration,targetWeight,gripPosition);

@override
String toString() {
  return 'RepTemplateRequest(index: $index, isRest: $isRest, rightHand: $rightHand, duration: $duration, targetWeight: $targetWeight, gripPosition: $gripPosition)';
}


}

/// @nodoc
abstract mixin class $RepTemplateRequestCopyWith<$Res>  {
  factory $RepTemplateRequestCopyWith(RepTemplateRequest value, $Res Function(RepTemplateRequest) _then) = _$RepTemplateRequestCopyWithImpl;
@useResult
$Res call({
 int index,@JsonKey(name: 'is_rest') bool isRest,@JsonKey(name: 'right_hand') bool rightHand, int duration,@JsonKey(name: 'target_weight') double targetWeight,@JsonKey(name: 'grip_position') int gripPosition
});




}
/// @nodoc
class _$RepTemplateRequestCopyWithImpl<$Res>
    implements $RepTemplateRequestCopyWith<$Res> {
  _$RepTemplateRequestCopyWithImpl(this._self, this._then);

  final RepTemplateRequest _self;
  final $Res Function(RepTemplateRequest) _then;

/// Create a copy of RepTemplateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? isRest = null,Object? rightHand = null,Object? duration = null,Object? targetWeight = null,Object? gripPosition = null,}) {
  return _then(_self.copyWith(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,isRest: null == isRest ? _self.isRest : isRest // ignore: cast_nullable_to_non_nullable
as bool,rightHand: null == rightHand ? _self.rightHand : rightHand // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,targetWeight: null == targetWeight ? _self.targetWeight : targetWeight // ignore: cast_nullable_to_non_nullable
as double,gripPosition: null == gripPosition ? _self.gripPosition : gripPosition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RepTemplateRequest].
extension RepTemplateRequestPatterns on RepTemplateRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepTemplateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepTemplateRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepTemplateRequest value)  $default,){
final _that = this;
switch (_that) {
case _RepTemplateRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepTemplateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RepTemplateRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index, @JsonKey(name: 'is_rest')  bool isRest, @JsonKey(name: 'right_hand')  bool rightHand,  int duration, @JsonKey(name: 'target_weight')  double targetWeight, @JsonKey(name: 'grip_position')  int gripPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepTemplateRequest() when $default != null:
return $default(_that.index,_that.isRest,_that.rightHand,_that.duration,_that.targetWeight,_that.gripPosition);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index, @JsonKey(name: 'is_rest')  bool isRest, @JsonKey(name: 'right_hand')  bool rightHand,  int duration, @JsonKey(name: 'target_weight')  double targetWeight, @JsonKey(name: 'grip_position')  int gripPosition)  $default,) {final _that = this;
switch (_that) {
case _RepTemplateRequest():
return $default(_that.index,_that.isRest,_that.rightHand,_that.duration,_that.targetWeight,_that.gripPosition);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index, @JsonKey(name: 'is_rest')  bool isRest, @JsonKey(name: 'right_hand')  bool rightHand,  int duration, @JsonKey(name: 'target_weight')  double targetWeight, @JsonKey(name: 'grip_position')  int gripPosition)?  $default,) {final _that = this;
switch (_that) {
case _RepTemplateRequest() when $default != null:
return $default(_that.index,_that.isRest,_that.rightHand,_that.duration,_that.targetWeight,_that.gripPosition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepTemplateRequest implements RepTemplateRequest {
  const _RepTemplateRequest({required this.index, @JsonKey(name: 'is_rest') required this.isRest, @JsonKey(name: 'right_hand') required this.rightHand, required this.duration, @JsonKey(name: 'target_weight') required this.targetWeight, @JsonKey(name: 'grip_position') required this.gripPosition});
  factory _RepTemplateRequest.fromJson(Map<String, dynamic> json) => _$RepTemplateRequestFromJson(json);

@override final  int index;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'is_rest') final  bool isRest;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'right_hand') final  bool rightHand;
@override final  int duration;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'target_weight') final  double targetWeight;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'grip_position') final  int gripPosition;

/// Create a copy of RepTemplateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepTemplateRequestCopyWith<_RepTemplateRequest> get copyWith => __$RepTemplateRequestCopyWithImpl<_RepTemplateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepTemplateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepTemplateRequest&&(identical(other.index, index) || other.index == index)&&(identical(other.isRest, isRest) || other.isRest == isRest)&&(identical(other.rightHand, rightHand) || other.rightHand == rightHand)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.targetWeight, targetWeight) || other.targetWeight == targetWeight)&&(identical(other.gripPosition, gripPosition) || other.gripPosition == gripPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,isRest,rightHand,duration,targetWeight,gripPosition);

@override
String toString() {
  return 'RepTemplateRequest(index: $index, isRest: $isRest, rightHand: $rightHand, duration: $duration, targetWeight: $targetWeight, gripPosition: $gripPosition)';
}


}

/// @nodoc
abstract mixin class _$RepTemplateRequestCopyWith<$Res> implements $RepTemplateRequestCopyWith<$Res> {
  factory _$RepTemplateRequestCopyWith(_RepTemplateRequest value, $Res Function(_RepTemplateRequest) _then) = __$RepTemplateRequestCopyWithImpl;
@override @useResult
$Res call({
 int index,@JsonKey(name: 'is_rest') bool isRest,@JsonKey(name: 'right_hand') bool rightHand, int duration,@JsonKey(name: 'target_weight') double targetWeight,@JsonKey(name: 'grip_position') int gripPosition
});




}
/// @nodoc
class __$RepTemplateRequestCopyWithImpl<$Res>
    implements _$RepTemplateRequestCopyWith<$Res> {
  __$RepTemplateRequestCopyWithImpl(this._self, this._then);

  final _RepTemplateRequest _self;
  final $Res Function(_RepTemplateRequest) _then;

/// Create a copy of RepTemplateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? isRest = null,Object? rightHand = null,Object? duration = null,Object? targetWeight = null,Object? gripPosition = null,}) {
  return _then(_RepTemplateRequest(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,isRest: null == isRest ? _self.isRest : isRest // ignore: cast_nullable_to_non_nullable
as bool,rightHand: null == rightHand ? _self.rightHand : rightHand // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,targetWeight: null == targetWeight ? _self.targetWeight : targetWeight // ignore: cast_nullable_to_non_nullable
as double,gripPosition: null == gripPosition ? _self.gripPosition : gripPosition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RepeaterResponse {

 int get id; int get sets; int get reps; int get worktime; int get resttime;// ignore: invalid_annotation_target
@JsonKey(name: 'set_rest') int get setRest;// ignore: invalid_annotation_target
@JsonKey(name: 'target_weight_right') double? get targetWeightRight;// ignore: invalid_annotation_target
@JsonKey(name: 'target_weight_left') double? get targetWeightLeft;// ignore: invalid_annotation_target
@JsonKey(name: 'split_hand') bool get splitHand;// ignore: invalid_annotation_target
@JsonKey(name: 'grip_position') int get gripPosition;
/// Create a copy of RepeaterResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepeaterResponseCopyWith<RepeaterResponse> get copyWith => _$RepeaterResponseCopyWithImpl<RepeaterResponse>(this as RepeaterResponse, _$identity);

  /// Serializes this RepeaterResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepeaterResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.worktime, worktime) || other.worktime == worktime)&&(identical(other.resttime, resttime) || other.resttime == resttime)&&(identical(other.setRest, setRest) || other.setRest == setRest)&&(identical(other.targetWeightRight, targetWeightRight) || other.targetWeightRight == targetWeightRight)&&(identical(other.targetWeightLeft, targetWeightLeft) || other.targetWeightLeft == targetWeightLeft)&&(identical(other.splitHand, splitHand) || other.splitHand == splitHand)&&(identical(other.gripPosition, gripPosition) || other.gripPosition == gripPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sets,reps,worktime,resttime,setRest,targetWeightRight,targetWeightLeft,splitHand,gripPosition);

@override
String toString() {
  return 'RepeaterResponse(id: $id, sets: $sets, reps: $reps, worktime: $worktime, resttime: $resttime, setRest: $setRest, targetWeightRight: $targetWeightRight, targetWeightLeft: $targetWeightLeft, splitHand: $splitHand, gripPosition: $gripPosition)';
}


}

/// @nodoc
abstract mixin class $RepeaterResponseCopyWith<$Res>  {
  factory $RepeaterResponseCopyWith(RepeaterResponse value, $Res Function(RepeaterResponse) _then) = _$RepeaterResponseCopyWithImpl;
@useResult
$Res call({
 int id, int sets, int reps, int worktime, int resttime,@JsonKey(name: 'set_rest') int setRest,@JsonKey(name: 'target_weight_right') double? targetWeightRight,@JsonKey(name: 'target_weight_left') double? targetWeightLeft,@JsonKey(name: 'split_hand') bool splitHand,@JsonKey(name: 'grip_position') int gripPosition
});




}
/// @nodoc
class _$RepeaterResponseCopyWithImpl<$Res>
    implements $RepeaterResponseCopyWith<$Res> {
  _$RepeaterResponseCopyWithImpl(this._self, this._then);

  final RepeaterResponse _self;
  final $Res Function(RepeaterResponse) _then;

/// Create a copy of RepeaterResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sets = null,Object? reps = null,Object? worktime = null,Object? resttime = null,Object? setRest = null,Object? targetWeightRight = freezed,Object? targetWeightLeft = freezed,Object? splitHand = null,Object? gripPosition = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,worktime: null == worktime ? _self.worktime : worktime // ignore: cast_nullable_to_non_nullable
as int,resttime: null == resttime ? _self.resttime : resttime // ignore: cast_nullable_to_non_nullable
as int,setRest: null == setRest ? _self.setRest : setRest // ignore: cast_nullable_to_non_nullable
as int,targetWeightRight: freezed == targetWeightRight ? _self.targetWeightRight : targetWeightRight // ignore: cast_nullable_to_non_nullable
as double?,targetWeightLeft: freezed == targetWeightLeft ? _self.targetWeightLeft : targetWeightLeft // ignore: cast_nullable_to_non_nullable
as double?,splitHand: null == splitHand ? _self.splitHand : splitHand // ignore: cast_nullable_to_non_nullable
as bool,gripPosition: null == gripPosition ? _self.gripPosition : gripPosition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RepeaterResponse].
extension RepeaterResponsePatterns on RepeaterResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepeaterResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepeaterResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepeaterResponse value)  $default,){
final _that = this;
switch (_that) {
case _RepeaterResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepeaterResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RepeaterResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int sets,  int reps,  int worktime,  int resttime, @JsonKey(name: 'set_rest')  int setRest, @JsonKey(name: 'target_weight_right')  double? targetWeightRight, @JsonKey(name: 'target_weight_left')  double? targetWeightLeft, @JsonKey(name: 'split_hand')  bool splitHand, @JsonKey(name: 'grip_position')  int gripPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepeaterResponse() when $default != null:
return $default(_that.id,_that.sets,_that.reps,_that.worktime,_that.resttime,_that.setRest,_that.targetWeightRight,_that.targetWeightLeft,_that.splitHand,_that.gripPosition);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int sets,  int reps,  int worktime,  int resttime, @JsonKey(name: 'set_rest')  int setRest, @JsonKey(name: 'target_weight_right')  double? targetWeightRight, @JsonKey(name: 'target_weight_left')  double? targetWeightLeft, @JsonKey(name: 'split_hand')  bool splitHand, @JsonKey(name: 'grip_position')  int gripPosition)  $default,) {final _that = this;
switch (_that) {
case _RepeaterResponse():
return $default(_that.id,_that.sets,_that.reps,_that.worktime,_that.resttime,_that.setRest,_that.targetWeightRight,_that.targetWeightLeft,_that.splitHand,_that.gripPosition);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int sets,  int reps,  int worktime,  int resttime, @JsonKey(name: 'set_rest')  int setRest, @JsonKey(name: 'target_weight_right')  double? targetWeightRight, @JsonKey(name: 'target_weight_left')  double? targetWeightLeft, @JsonKey(name: 'split_hand')  bool splitHand, @JsonKey(name: 'grip_position')  int gripPosition)?  $default,) {final _that = this;
switch (_that) {
case _RepeaterResponse() when $default != null:
return $default(_that.id,_that.sets,_that.reps,_that.worktime,_that.resttime,_that.setRest,_that.targetWeightRight,_that.targetWeightLeft,_that.splitHand,_that.gripPosition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepeaterResponse implements RepeaterResponse {
  const _RepeaterResponse({required this.id, required this.sets, required this.reps, required this.worktime, required this.resttime, @JsonKey(name: 'set_rest') required this.setRest, @JsonKey(name: 'target_weight_right') this.targetWeightRight, @JsonKey(name: 'target_weight_left') this.targetWeightLeft, @JsonKey(name: 'split_hand') required this.splitHand, @JsonKey(name: 'grip_position') required this.gripPosition});
  factory _RepeaterResponse.fromJson(Map<String, dynamic> json) => _$RepeaterResponseFromJson(json);

@override final  int id;
@override final  int sets;
@override final  int reps;
@override final  int worktime;
@override final  int resttime;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'set_rest') final  int setRest;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'target_weight_right') final  double? targetWeightRight;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'target_weight_left') final  double? targetWeightLeft;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'split_hand') final  bool splitHand;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'grip_position') final  int gripPosition;

/// Create a copy of RepeaterResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepeaterResponseCopyWith<_RepeaterResponse> get copyWith => __$RepeaterResponseCopyWithImpl<_RepeaterResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepeaterResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepeaterResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.worktime, worktime) || other.worktime == worktime)&&(identical(other.resttime, resttime) || other.resttime == resttime)&&(identical(other.setRest, setRest) || other.setRest == setRest)&&(identical(other.targetWeightRight, targetWeightRight) || other.targetWeightRight == targetWeightRight)&&(identical(other.targetWeightLeft, targetWeightLeft) || other.targetWeightLeft == targetWeightLeft)&&(identical(other.splitHand, splitHand) || other.splitHand == splitHand)&&(identical(other.gripPosition, gripPosition) || other.gripPosition == gripPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sets,reps,worktime,resttime,setRest,targetWeightRight,targetWeightLeft,splitHand,gripPosition);

@override
String toString() {
  return 'RepeaterResponse(id: $id, sets: $sets, reps: $reps, worktime: $worktime, resttime: $resttime, setRest: $setRest, targetWeightRight: $targetWeightRight, targetWeightLeft: $targetWeightLeft, splitHand: $splitHand, gripPosition: $gripPosition)';
}


}

/// @nodoc
abstract mixin class _$RepeaterResponseCopyWith<$Res> implements $RepeaterResponseCopyWith<$Res> {
  factory _$RepeaterResponseCopyWith(_RepeaterResponse value, $Res Function(_RepeaterResponse) _then) = __$RepeaterResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int sets, int reps, int worktime, int resttime,@JsonKey(name: 'set_rest') int setRest,@JsonKey(name: 'target_weight_right') double? targetWeightRight,@JsonKey(name: 'target_weight_left') double? targetWeightLeft,@JsonKey(name: 'split_hand') bool splitHand,@JsonKey(name: 'grip_position') int gripPosition
});




}
/// @nodoc
class __$RepeaterResponseCopyWithImpl<$Res>
    implements _$RepeaterResponseCopyWith<$Res> {
  __$RepeaterResponseCopyWithImpl(this._self, this._then);

  final _RepeaterResponse _self;
  final $Res Function(_RepeaterResponse) _then;

/// Create a copy of RepeaterResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sets = null,Object? reps = null,Object? worktime = null,Object? resttime = null,Object? setRest = null,Object? targetWeightRight = freezed,Object? targetWeightLeft = freezed,Object? splitHand = null,Object? gripPosition = null,}) {
  return _then(_RepeaterResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,worktime: null == worktime ? _self.worktime : worktime // ignore: cast_nullable_to_non_nullable
as int,resttime: null == resttime ? _self.resttime : resttime // ignore: cast_nullable_to_non_nullable
as int,setRest: null == setRest ? _self.setRest : setRest // ignore: cast_nullable_to_non_nullable
as int,targetWeightRight: freezed == targetWeightRight ? _self.targetWeightRight : targetWeightRight // ignore: cast_nullable_to_non_nullable
as double?,targetWeightLeft: freezed == targetWeightLeft ? _self.targetWeightLeft : targetWeightLeft // ignore: cast_nullable_to_non_nullable
as double?,splitHand: null == splitHand ? _self.splitHand : splitHand // ignore: cast_nullable_to_non_nullable
as bool,gripPosition: null == gripPosition ? _self.gripPosition : gripPosition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CreateRepeaterRequest {

 int get sets; int get reps; int get worktime; int get resttime;// ignore: invalid_annotation_target
@JsonKey(name: 'set_rest') int get setRest;// ignore: invalid_annotation_target
@JsonKey(name: 'target_weight_right') double? get targetWeightRight;// ignore: invalid_annotation_target
@JsonKey(name: 'target_weight_left') double? get targetWeightLeft;// ignore: invalid_annotation_target
@JsonKey(name: 'split_hand') bool get splitHand;// ignore: invalid_annotation_target
@JsonKey(name: 'grip_position') int get gripPosition;
/// Create a copy of CreateRepeaterRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateRepeaterRequestCopyWith<CreateRepeaterRequest> get copyWith => _$CreateRepeaterRequestCopyWithImpl<CreateRepeaterRequest>(this as CreateRepeaterRequest, _$identity);

  /// Serializes this CreateRepeaterRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateRepeaterRequest&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.worktime, worktime) || other.worktime == worktime)&&(identical(other.resttime, resttime) || other.resttime == resttime)&&(identical(other.setRest, setRest) || other.setRest == setRest)&&(identical(other.targetWeightRight, targetWeightRight) || other.targetWeightRight == targetWeightRight)&&(identical(other.targetWeightLeft, targetWeightLeft) || other.targetWeightLeft == targetWeightLeft)&&(identical(other.splitHand, splitHand) || other.splitHand == splitHand)&&(identical(other.gripPosition, gripPosition) || other.gripPosition == gripPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sets,reps,worktime,resttime,setRest,targetWeightRight,targetWeightLeft,splitHand,gripPosition);

@override
String toString() {
  return 'CreateRepeaterRequest(sets: $sets, reps: $reps, worktime: $worktime, resttime: $resttime, setRest: $setRest, targetWeightRight: $targetWeightRight, targetWeightLeft: $targetWeightLeft, splitHand: $splitHand, gripPosition: $gripPosition)';
}


}

/// @nodoc
abstract mixin class $CreateRepeaterRequestCopyWith<$Res>  {
  factory $CreateRepeaterRequestCopyWith(CreateRepeaterRequest value, $Res Function(CreateRepeaterRequest) _then) = _$CreateRepeaterRequestCopyWithImpl;
@useResult
$Res call({
 int sets, int reps, int worktime, int resttime,@JsonKey(name: 'set_rest') int setRest,@JsonKey(name: 'target_weight_right') double? targetWeightRight,@JsonKey(name: 'target_weight_left') double? targetWeightLeft,@JsonKey(name: 'split_hand') bool splitHand,@JsonKey(name: 'grip_position') int gripPosition
});




}
/// @nodoc
class _$CreateRepeaterRequestCopyWithImpl<$Res>
    implements $CreateRepeaterRequestCopyWith<$Res> {
  _$CreateRepeaterRequestCopyWithImpl(this._self, this._then);

  final CreateRepeaterRequest _self;
  final $Res Function(CreateRepeaterRequest) _then;

/// Create a copy of CreateRepeaterRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sets = null,Object? reps = null,Object? worktime = null,Object? resttime = null,Object? setRest = null,Object? targetWeightRight = freezed,Object? targetWeightLeft = freezed,Object? splitHand = null,Object? gripPosition = null,}) {
  return _then(_self.copyWith(
sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,worktime: null == worktime ? _self.worktime : worktime // ignore: cast_nullable_to_non_nullable
as int,resttime: null == resttime ? _self.resttime : resttime // ignore: cast_nullable_to_non_nullable
as int,setRest: null == setRest ? _self.setRest : setRest // ignore: cast_nullable_to_non_nullable
as int,targetWeightRight: freezed == targetWeightRight ? _self.targetWeightRight : targetWeightRight // ignore: cast_nullable_to_non_nullable
as double?,targetWeightLeft: freezed == targetWeightLeft ? _self.targetWeightLeft : targetWeightLeft // ignore: cast_nullable_to_non_nullable
as double?,splitHand: null == splitHand ? _self.splitHand : splitHand // ignore: cast_nullable_to_non_nullable
as bool,gripPosition: null == gripPosition ? _self.gripPosition : gripPosition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateRepeaterRequest].
extension CreateRepeaterRequestPatterns on CreateRepeaterRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateRepeaterRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateRepeaterRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateRepeaterRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateRepeaterRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateRepeaterRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateRepeaterRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sets,  int reps,  int worktime,  int resttime, @JsonKey(name: 'set_rest')  int setRest, @JsonKey(name: 'target_weight_right')  double? targetWeightRight, @JsonKey(name: 'target_weight_left')  double? targetWeightLeft, @JsonKey(name: 'split_hand')  bool splitHand, @JsonKey(name: 'grip_position')  int gripPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateRepeaterRequest() when $default != null:
return $default(_that.sets,_that.reps,_that.worktime,_that.resttime,_that.setRest,_that.targetWeightRight,_that.targetWeightLeft,_that.splitHand,_that.gripPosition);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sets,  int reps,  int worktime,  int resttime, @JsonKey(name: 'set_rest')  int setRest, @JsonKey(name: 'target_weight_right')  double? targetWeightRight, @JsonKey(name: 'target_weight_left')  double? targetWeightLeft, @JsonKey(name: 'split_hand')  bool splitHand, @JsonKey(name: 'grip_position')  int gripPosition)  $default,) {final _that = this;
switch (_that) {
case _CreateRepeaterRequest():
return $default(_that.sets,_that.reps,_that.worktime,_that.resttime,_that.setRest,_that.targetWeightRight,_that.targetWeightLeft,_that.splitHand,_that.gripPosition);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sets,  int reps,  int worktime,  int resttime, @JsonKey(name: 'set_rest')  int setRest, @JsonKey(name: 'target_weight_right')  double? targetWeightRight, @JsonKey(name: 'target_weight_left')  double? targetWeightLeft, @JsonKey(name: 'split_hand')  bool splitHand, @JsonKey(name: 'grip_position')  int gripPosition)?  $default,) {final _that = this;
switch (_that) {
case _CreateRepeaterRequest() when $default != null:
return $default(_that.sets,_that.reps,_that.worktime,_that.resttime,_that.setRest,_that.targetWeightRight,_that.targetWeightLeft,_that.splitHand,_that.gripPosition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateRepeaterRequest implements CreateRepeaterRequest {
  const _CreateRepeaterRequest({required this.sets, required this.reps, required this.worktime, required this.resttime, @JsonKey(name: 'set_rest') required this.setRest, @JsonKey(name: 'target_weight_right') this.targetWeightRight, @JsonKey(name: 'target_weight_left') this.targetWeightLeft, @JsonKey(name: 'split_hand') required this.splitHand, @JsonKey(name: 'grip_position') required this.gripPosition});
  factory _CreateRepeaterRequest.fromJson(Map<String, dynamic> json) => _$CreateRepeaterRequestFromJson(json);

@override final  int sets;
@override final  int reps;
@override final  int worktime;
@override final  int resttime;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'set_rest') final  int setRest;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'target_weight_right') final  double? targetWeightRight;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'target_weight_left') final  double? targetWeightLeft;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'split_hand') final  bool splitHand;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'grip_position') final  int gripPosition;

/// Create a copy of CreateRepeaterRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateRepeaterRequestCopyWith<_CreateRepeaterRequest> get copyWith => __$CreateRepeaterRequestCopyWithImpl<_CreateRepeaterRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateRepeaterRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateRepeaterRequest&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.worktime, worktime) || other.worktime == worktime)&&(identical(other.resttime, resttime) || other.resttime == resttime)&&(identical(other.setRest, setRest) || other.setRest == setRest)&&(identical(other.targetWeightRight, targetWeightRight) || other.targetWeightRight == targetWeightRight)&&(identical(other.targetWeightLeft, targetWeightLeft) || other.targetWeightLeft == targetWeightLeft)&&(identical(other.splitHand, splitHand) || other.splitHand == splitHand)&&(identical(other.gripPosition, gripPosition) || other.gripPosition == gripPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sets,reps,worktime,resttime,setRest,targetWeightRight,targetWeightLeft,splitHand,gripPosition);

@override
String toString() {
  return 'CreateRepeaterRequest(sets: $sets, reps: $reps, worktime: $worktime, resttime: $resttime, setRest: $setRest, targetWeightRight: $targetWeightRight, targetWeightLeft: $targetWeightLeft, splitHand: $splitHand, gripPosition: $gripPosition)';
}


}

/// @nodoc
abstract mixin class _$CreateRepeaterRequestCopyWith<$Res> implements $CreateRepeaterRequestCopyWith<$Res> {
  factory _$CreateRepeaterRequestCopyWith(_CreateRepeaterRequest value, $Res Function(_CreateRepeaterRequest) _then) = __$CreateRepeaterRequestCopyWithImpl;
@override @useResult
$Res call({
 int sets, int reps, int worktime, int resttime,@JsonKey(name: 'set_rest') int setRest,@JsonKey(name: 'target_weight_right') double? targetWeightRight,@JsonKey(name: 'target_weight_left') double? targetWeightLeft,@JsonKey(name: 'split_hand') bool splitHand,@JsonKey(name: 'grip_position') int gripPosition
});




}
/// @nodoc
class __$CreateRepeaterRequestCopyWithImpl<$Res>
    implements _$CreateRepeaterRequestCopyWith<$Res> {
  __$CreateRepeaterRequestCopyWithImpl(this._self, this._then);

  final _CreateRepeaterRequest _self;
  final $Res Function(_CreateRepeaterRequest) _then;

/// Create a copy of CreateRepeaterRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sets = null,Object? reps = null,Object? worktime = null,Object? resttime = null,Object? setRest = null,Object? targetWeightRight = freezed,Object? targetWeightLeft = freezed,Object? splitHand = null,Object? gripPosition = null,}) {
  return _then(_CreateRepeaterRequest(
sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,worktime: null == worktime ? _self.worktime : worktime // ignore: cast_nullable_to_non_nullable
as int,resttime: null == resttime ? _self.resttime : resttime // ignore: cast_nullable_to_non_nullable
as int,setRest: null == setRest ? _self.setRest : setRest // ignore: cast_nullable_to_non_nullable
as int,targetWeightRight: freezed == targetWeightRight ? _self.targetWeightRight : targetWeightRight // ignore: cast_nullable_to_non_nullable
as double?,targetWeightLeft: freezed == targetWeightLeft ? _self.targetWeightLeft : targetWeightLeft // ignore: cast_nullable_to_non_nullable
as double?,splitHand: null == splitHand ? _self.splitHand : splitHand // ignore: cast_nullable_to_non_nullable
as bool,gripPosition: null == gripPosition ? _self.gripPosition : gripPosition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$UpdateRepeaterRequest {

 int? get sets; int? get reps; int? get worktime; int? get resttime;// ignore: invalid_annotation_target
@JsonKey(name: 'set_rest') int? get setRest;// ignore: invalid_annotation_target
@JsonKey(name: 'target_weight_right') double? get targetWeightRight;// ignore: invalid_annotation_target
@JsonKey(name: 'target_weight_left') double? get targetWeightLeft;// ignore: invalid_annotation_target
@JsonKey(name: 'split_hand') bool? get splitHand;// ignore: invalid_annotation_target
@JsonKey(name: 'grip_position') int? get gripPosition;
/// Create a copy of UpdateRepeaterRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateRepeaterRequestCopyWith<UpdateRepeaterRequest> get copyWith => _$UpdateRepeaterRequestCopyWithImpl<UpdateRepeaterRequest>(this as UpdateRepeaterRequest, _$identity);

  /// Serializes this UpdateRepeaterRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateRepeaterRequest&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.worktime, worktime) || other.worktime == worktime)&&(identical(other.resttime, resttime) || other.resttime == resttime)&&(identical(other.setRest, setRest) || other.setRest == setRest)&&(identical(other.targetWeightRight, targetWeightRight) || other.targetWeightRight == targetWeightRight)&&(identical(other.targetWeightLeft, targetWeightLeft) || other.targetWeightLeft == targetWeightLeft)&&(identical(other.splitHand, splitHand) || other.splitHand == splitHand)&&(identical(other.gripPosition, gripPosition) || other.gripPosition == gripPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sets,reps,worktime,resttime,setRest,targetWeightRight,targetWeightLeft,splitHand,gripPosition);

@override
String toString() {
  return 'UpdateRepeaterRequest(sets: $sets, reps: $reps, worktime: $worktime, resttime: $resttime, setRest: $setRest, targetWeightRight: $targetWeightRight, targetWeightLeft: $targetWeightLeft, splitHand: $splitHand, gripPosition: $gripPosition)';
}


}

/// @nodoc
abstract mixin class $UpdateRepeaterRequestCopyWith<$Res>  {
  factory $UpdateRepeaterRequestCopyWith(UpdateRepeaterRequest value, $Res Function(UpdateRepeaterRequest) _then) = _$UpdateRepeaterRequestCopyWithImpl;
@useResult
$Res call({
 int? sets, int? reps, int? worktime, int? resttime,@JsonKey(name: 'set_rest') int? setRest,@JsonKey(name: 'target_weight_right') double? targetWeightRight,@JsonKey(name: 'target_weight_left') double? targetWeightLeft,@JsonKey(name: 'split_hand') bool? splitHand,@JsonKey(name: 'grip_position') int? gripPosition
});




}
/// @nodoc
class _$UpdateRepeaterRequestCopyWithImpl<$Res>
    implements $UpdateRepeaterRequestCopyWith<$Res> {
  _$UpdateRepeaterRequestCopyWithImpl(this._self, this._then);

  final UpdateRepeaterRequest _self;
  final $Res Function(UpdateRepeaterRequest) _then;

/// Create a copy of UpdateRepeaterRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sets = freezed,Object? reps = freezed,Object? worktime = freezed,Object? resttime = freezed,Object? setRest = freezed,Object? targetWeightRight = freezed,Object? targetWeightLeft = freezed,Object? splitHand = freezed,Object? gripPosition = freezed,}) {
  return _then(_self.copyWith(
sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,worktime: freezed == worktime ? _self.worktime : worktime // ignore: cast_nullable_to_non_nullable
as int?,resttime: freezed == resttime ? _self.resttime : resttime // ignore: cast_nullable_to_non_nullable
as int?,setRest: freezed == setRest ? _self.setRest : setRest // ignore: cast_nullable_to_non_nullable
as int?,targetWeightRight: freezed == targetWeightRight ? _self.targetWeightRight : targetWeightRight // ignore: cast_nullable_to_non_nullable
as double?,targetWeightLeft: freezed == targetWeightLeft ? _self.targetWeightLeft : targetWeightLeft // ignore: cast_nullable_to_non_nullable
as double?,splitHand: freezed == splitHand ? _self.splitHand : splitHand // ignore: cast_nullable_to_non_nullable
as bool?,gripPosition: freezed == gripPosition ? _self.gripPosition : gripPosition // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateRepeaterRequest].
extension UpdateRepeaterRequestPatterns on UpdateRepeaterRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateRepeaterRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateRepeaterRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateRepeaterRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateRepeaterRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateRepeaterRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateRepeaterRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? sets,  int? reps,  int? worktime,  int? resttime, @JsonKey(name: 'set_rest')  int? setRest, @JsonKey(name: 'target_weight_right')  double? targetWeightRight, @JsonKey(name: 'target_weight_left')  double? targetWeightLeft, @JsonKey(name: 'split_hand')  bool? splitHand, @JsonKey(name: 'grip_position')  int? gripPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateRepeaterRequest() when $default != null:
return $default(_that.sets,_that.reps,_that.worktime,_that.resttime,_that.setRest,_that.targetWeightRight,_that.targetWeightLeft,_that.splitHand,_that.gripPosition);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? sets,  int? reps,  int? worktime,  int? resttime, @JsonKey(name: 'set_rest')  int? setRest, @JsonKey(name: 'target_weight_right')  double? targetWeightRight, @JsonKey(name: 'target_weight_left')  double? targetWeightLeft, @JsonKey(name: 'split_hand')  bool? splitHand, @JsonKey(name: 'grip_position')  int? gripPosition)  $default,) {final _that = this;
switch (_that) {
case _UpdateRepeaterRequest():
return $default(_that.sets,_that.reps,_that.worktime,_that.resttime,_that.setRest,_that.targetWeightRight,_that.targetWeightLeft,_that.splitHand,_that.gripPosition);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? sets,  int? reps,  int? worktime,  int? resttime, @JsonKey(name: 'set_rest')  int? setRest, @JsonKey(name: 'target_weight_right')  double? targetWeightRight, @JsonKey(name: 'target_weight_left')  double? targetWeightLeft, @JsonKey(name: 'split_hand')  bool? splitHand, @JsonKey(name: 'grip_position')  int? gripPosition)?  $default,) {final _that = this;
switch (_that) {
case _UpdateRepeaterRequest() when $default != null:
return $default(_that.sets,_that.reps,_that.worktime,_that.resttime,_that.setRest,_that.targetWeightRight,_that.targetWeightLeft,_that.splitHand,_that.gripPosition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateRepeaterRequest implements UpdateRepeaterRequest {
  const _UpdateRepeaterRequest({this.sets, this.reps, this.worktime, this.resttime, @JsonKey(name: 'set_rest') this.setRest, @JsonKey(name: 'target_weight_right') this.targetWeightRight, @JsonKey(name: 'target_weight_left') this.targetWeightLeft, @JsonKey(name: 'split_hand') this.splitHand, @JsonKey(name: 'grip_position') this.gripPosition});
  factory _UpdateRepeaterRequest.fromJson(Map<String, dynamic> json) => _$UpdateRepeaterRequestFromJson(json);

@override final  int? sets;
@override final  int? reps;
@override final  int? worktime;
@override final  int? resttime;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'set_rest') final  int? setRest;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'target_weight_right') final  double? targetWeightRight;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'target_weight_left') final  double? targetWeightLeft;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'split_hand') final  bool? splitHand;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'grip_position') final  int? gripPosition;

/// Create a copy of UpdateRepeaterRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateRepeaterRequestCopyWith<_UpdateRepeaterRequest> get copyWith => __$UpdateRepeaterRequestCopyWithImpl<_UpdateRepeaterRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateRepeaterRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateRepeaterRequest&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.worktime, worktime) || other.worktime == worktime)&&(identical(other.resttime, resttime) || other.resttime == resttime)&&(identical(other.setRest, setRest) || other.setRest == setRest)&&(identical(other.targetWeightRight, targetWeightRight) || other.targetWeightRight == targetWeightRight)&&(identical(other.targetWeightLeft, targetWeightLeft) || other.targetWeightLeft == targetWeightLeft)&&(identical(other.splitHand, splitHand) || other.splitHand == splitHand)&&(identical(other.gripPosition, gripPosition) || other.gripPosition == gripPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sets,reps,worktime,resttime,setRest,targetWeightRight,targetWeightLeft,splitHand,gripPosition);

@override
String toString() {
  return 'UpdateRepeaterRequest(sets: $sets, reps: $reps, worktime: $worktime, resttime: $resttime, setRest: $setRest, targetWeightRight: $targetWeightRight, targetWeightLeft: $targetWeightLeft, splitHand: $splitHand, gripPosition: $gripPosition)';
}


}

/// @nodoc
abstract mixin class _$UpdateRepeaterRequestCopyWith<$Res> implements $UpdateRepeaterRequestCopyWith<$Res> {
  factory _$UpdateRepeaterRequestCopyWith(_UpdateRepeaterRequest value, $Res Function(_UpdateRepeaterRequest) _then) = __$UpdateRepeaterRequestCopyWithImpl;
@override @useResult
$Res call({
 int? sets, int? reps, int? worktime, int? resttime,@JsonKey(name: 'set_rest') int? setRest,@JsonKey(name: 'target_weight_right') double? targetWeightRight,@JsonKey(name: 'target_weight_left') double? targetWeightLeft,@JsonKey(name: 'split_hand') bool? splitHand,@JsonKey(name: 'grip_position') int? gripPosition
});




}
/// @nodoc
class __$UpdateRepeaterRequestCopyWithImpl<$Res>
    implements _$UpdateRepeaterRequestCopyWith<$Res> {
  __$UpdateRepeaterRequestCopyWithImpl(this._self, this._then);

  final _UpdateRepeaterRequest _self;
  final $Res Function(_UpdateRepeaterRequest) _then;

/// Create a copy of UpdateRepeaterRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sets = freezed,Object? reps = freezed,Object? worktime = freezed,Object? resttime = freezed,Object? setRest = freezed,Object? targetWeightRight = freezed,Object? targetWeightLeft = freezed,Object? splitHand = freezed,Object? gripPosition = freezed,}) {
  return _then(_UpdateRepeaterRequest(
sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,worktime: freezed == worktime ? _self.worktime : worktime // ignore: cast_nullable_to_non_nullable
as int?,resttime: freezed == resttime ? _self.resttime : resttime // ignore: cast_nullable_to_non_nullable
as int?,setRest: freezed == setRest ? _self.setRest : setRest // ignore: cast_nullable_to_non_nullable
as int?,targetWeightRight: freezed == targetWeightRight ? _self.targetWeightRight : targetWeightRight // ignore: cast_nullable_to_non_nullable
as double?,targetWeightLeft: freezed == targetWeightLeft ? _self.targetWeightLeft : targetWeightLeft // ignore: cast_nullable_to_non_nullable
as double?,splitHand: freezed == splitHand ? _self.splitHand : splitHand // ignore: cast_nullable_to_non_nullable
as bool?,gripPosition: freezed == gripPosition ? _self.gripPosition : gripPosition // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
