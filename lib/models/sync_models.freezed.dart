// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncSummaryResponse {

@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'last_sync_version') int get lastSyncVersion; Map<String, int> get collections;
/// Create a copy of SyncSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncSummaryResponseCopyWith<SyncSummaryResponse> get copyWith => _$SyncSummaryResponseCopyWithImpl<SyncSummaryResponse>(this as SyncSummaryResponse, _$identity);

  /// Serializes this SyncSummaryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncSummaryResponse&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lastSyncVersion, lastSyncVersion) || other.lastSyncVersion == lastSyncVersion)&&const DeepCollectionEquality().equals(other.collections, collections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,lastSyncVersion,const DeepCollectionEquality().hash(collections));

@override
String toString() {
  return 'SyncSummaryResponse(userId: $userId, lastSyncVersion: $lastSyncVersion, collections: $collections)';
}


}

/// @nodoc
abstract mixin class $SyncSummaryResponseCopyWith<$Res>  {
  factory $SyncSummaryResponseCopyWith(SyncSummaryResponse value, $Res Function(SyncSummaryResponse) _then) = _$SyncSummaryResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'last_sync_version') int lastSyncVersion, Map<String, int> collections
});




}
/// @nodoc
class _$SyncSummaryResponseCopyWithImpl<$Res>
    implements $SyncSummaryResponseCopyWith<$Res> {
  _$SyncSummaryResponseCopyWithImpl(this._self, this._then);

  final SyncSummaryResponse _self;
  final $Res Function(SyncSummaryResponse) _then;

/// Create a copy of SyncSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? lastSyncVersion = null,Object? collections = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lastSyncVersion: null == lastSyncVersion ? _self.lastSyncVersion : lastSyncVersion // ignore: cast_nullable_to_non_nullable
as int,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncSummaryResponse].
extension SyncSummaryResponsePatterns on SyncSummaryResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncSummaryResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncSummaryResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncSummaryResponse value)  $default,){
final _that = this;
switch (_that) {
case _SyncSummaryResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncSummaryResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SyncSummaryResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'last_sync_version')  int lastSyncVersion,  Map<String, int> collections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncSummaryResponse() when $default != null:
return $default(_that.userId,_that.lastSyncVersion,_that.collections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'last_sync_version')  int lastSyncVersion,  Map<String, int> collections)  $default,) {final _that = this;
switch (_that) {
case _SyncSummaryResponse():
return $default(_that.userId,_that.lastSyncVersion,_that.collections);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'last_sync_version')  int lastSyncVersion,  Map<String, int> collections)?  $default,) {final _that = this;
switch (_that) {
case _SyncSummaryResponse() when $default != null:
return $default(_that.userId,_that.lastSyncVersion,_that.collections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncSummaryResponse implements SyncSummaryResponse {
  const _SyncSummaryResponse({@JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'last_sync_version') required this.lastSyncVersion, required final  Map<String, int> collections}): _collections = collections;
  factory _SyncSummaryResponse.fromJson(Map<String, dynamic> json) => _$SyncSummaryResponseFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'last_sync_version') final  int lastSyncVersion;
 final  Map<String, int> _collections;
@override Map<String, int> get collections {
  if (_collections is EqualUnmodifiableMapView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_collections);
}


/// Create a copy of SyncSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncSummaryResponseCopyWith<_SyncSummaryResponse> get copyWith => __$SyncSummaryResponseCopyWithImpl<_SyncSummaryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncSummaryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncSummaryResponse&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lastSyncVersion, lastSyncVersion) || other.lastSyncVersion == lastSyncVersion)&&const DeepCollectionEquality().equals(other._collections, _collections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,lastSyncVersion,const DeepCollectionEquality().hash(_collections));

@override
String toString() {
  return 'SyncSummaryResponse(userId: $userId, lastSyncVersion: $lastSyncVersion, collections: $collections)';
}


}

/// @nodoc
abstract mixin class _$SyncSummaryResponseCopyWith<$Res> implements $SyncSummaryResponseCopyWith<$Res> {
  factory _$SyncSummaryResponseCopyWith(_SyncSummaryResponse value, $Res Function(_SyncSummaryResponse) _then) = __$SyncSummaryResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'last_sync_version') int lastSyncVersion, Map<String, int> collections
});




}
/// @nodoc
class __$SyncSummaryResponseCopyWithImpl<$Res>
    implements _$SyncSummaryResponseCopyWith<$Res> {
  __$SyncSummaryResponseCopyWithImpl(this._self, this._then);

  final _SyncSummaryResponse _self;
  final $Res Function(_SyncSummaryResponse) _then;

/// Create a copy of SyncSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? lastSyncVersion = null,Object? collections = null,}) {
  return _then(_SyncSummaryResponse(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lastSyncVersion: null == lastSyncVersion ? _self.lastSyncVersion : lastSyncVersion // ignore: cast_nullable_to_non_nullable
as int,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}


/// @nodoc
mixin _$PushRequest {

 Map<String, dynamic> get records;
/// Create a copy of PushRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushRequestCopyWith<PushRequest> get copyWith => _$PushRequestCopyWithImpl<PushRequest>(this as PushRequest, _$identity);

  /// Serializes this PushRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushRequest&&const DeepCollectionEquality().equals(other.records, records));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(records));

@override
String toString() {
  return 'PushRequest(records: $records)';
}


}

/// @nodoc
abstract mixin class $PushRequestCopyWith<$Res>  {
  factory $PushRequestCopyWith(PushRequest value, $Res Function(PushRequest) _then) = _$PushRequestCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> records
});




}
/// @nodoc
class _$PushRequestCopyWithImpl<$Res>
    implements $PushRequestCopyWith<$Res> {
  _$PushRequestCopyWithImpl(this._self, this._then);

  final PushRequest _self;
  final $Res Function(PushRequest) _then;

/// Create a copy of PushRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? records = null,}) {
  return _then(_self.copyWith(
records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [PushRequest].
extension PushRequestPatterns on PushRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PushRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PushRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PushRequest value)  $default,){
final _that = this;
switch (_that) {
case _PushRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PushRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PushRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> records)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PushRequest() when $default != null:
return $default(_that.records);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> records)  $default,) {final _that = this;
switch (_that) {
case _PushRequest():
return $default(_that.records);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> records)?  $default,) {final _that = this;
switch (_that) {
case _PushRequest() when $default != null:
return $default(_that.records);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PushRequest implements PushRequest {
  const _PushRequest({required final  Map<String, dynamic> records}): _records = records;
  factory _PushRequest.fromJson(Map<String, dynamic> json) => _$PushRequestFromJson(json);

 final  Map<String, dynamic> _records;
@override Map<String, dynamic> get records {
  if (_records is EqualUnmodifiableMapView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_records);
}


/// Create a copy of PushRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PushRequestCopyWith<_PushRequest> get copyWith => __$PushRequestCopyWithImpl<_PushRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PushRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PushRequest&&const DeepCollectionEquality().equals(other._records, _records));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_records));

@override
String toString() {
  return 'PushRequest(records: $records)';
}


}

/// @nodoc
abstract mixin class _$PushRequestCopyWith<$Res> implements $PushRequestCopyWith<$Res> {
  factory _$PushRequestCopyWith(_PushRequest value, $Res Function(_PushRequest) _then) = __$PushRequestCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> records
});




}
/// @nodoc
class __$PushRequestCopyWithImpl<$Res>
    implements _$PushRequestCopyWith<$Res> {
  __$PushRequestCopyWithImpl(this._self, this._then);

  final _PushRequest _self;
  final $Res Function(_PushRequest) _then;

/// Create a copy of PushRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? records = null,}) {
  return _then(_PushRequest(
records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$PushResponse {

 List<String> get accepted; List<String> get rejected;@JsonKey(name: 'server_version') int get serverVersion;
/// Create a copy of PushResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushResponseCopyWith<PushResponse> get copyWith => _$PushResponseCopyWithImpl<PushResponse>(this as PushResponse, _$identity);

  /// Serializes this PushResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushResponse&&const DeepCollectionEquality().equals(other.accepted, accepted)&&const DeepCollectionEquality().equals(other.rejected, rejected)&&(identical(other.serverVersion, serverVersion) || other.serverVersion == serverVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(accepted),const DeepCollectionEquality().hash(rejected),serverVersion);

@override
String toString() {
  return 'PushResponse(accepted: $accepted, rejected: $rejected, serverVersion: $serverVersion)';
}


}

/// @nodoc
abstract mixin class $PushResponseCopyWith<$Res>  {
  factory $PushResponseCopyWith(PushResponse value, $Res Function(PushResponse) _then) = _$PushResponseCopyWithImpl;
@useResult
$Res call({
 List<String> accepted, List<String> rejected,@JsonKey(name: 'server_version') int serverVersion
});




}
/// @nodoc
class _$PushResponseCopyWithImpl<$Res>
    implements $PushResponseCopyWith<$Res> {
  _$PushResponseCopyWithImpl(this._self, this._then);

  final PushResponse _self;
  final $Res Function(PushResponse) _then;

/// Create a copy of PushResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accepted = null,Object? rejected = null,Object? serverVersion = null,}) {
  return _then(_self.copyWith(
accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as List<String>,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as List<String>,serverVersion: null == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PushResponse].
extension PushResponsePatterns on PushResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PushResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PushResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PushResponse value)  $default,){
final _that = this;
switch (_that) {
case _PushResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PushResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PushResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> accepted,  List<String> rejected, @JsonKey(name: 'server_version')  int serverVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PushResponse() when $default != null:
return $default(_that.accepted,_that.rejected,_that.serverVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> accepted,  List<String> rejected, @JsonKey(name: 'server_version')  int serverVersion)  $default,) {final _that = this;
switch (_that) {
case _PushResponse():
return $default(_that.accepted,_that.rejected,_that.serverVersion);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> accepted,  List<String> rejected, @JsonKey(name: 'server_version')  int serverVersion)?  $default,) {final _that = this;
switch (_that) {
case _PushResponse() when $default != null:
return $default(_that.accepted,_that.rejected,_that.serverVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PushResponse implements PushResponse {
  const _PushResponse({required final  List<String> accepted, required final  List<String> rejected, @JsonKey(name: 'server_version') required this.serverVersion}): _accepted = accepted,_rejected = rejected;
  factory _PushResponse.fromJson(Map<String, dynamic> json) => _$PushResponseFromJson(json);

 final  List<String> _accepted;
@override List<String> get accepted {
  if (_accepted is EqualUnmodifiableListView) return _accepted;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accepted);
}

 final  List<String> _rejected;
@override List<String> get rejected {
  if (_rejected is EqualUnmodifiableListView) return _rejected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejected);
}

@override@JsonKey(name: 'server_version') final  int serverVersion;

/// Create a copy of PushResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PushResponseCopyWith<_PushResponse> get copyWith => __$PushResponseCopyWithImpl<_PushResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PushResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PushResponse&&const DeepCollectionEquality().equals(other._accepted, _accepted)&&const DeepCollectionEquality().equals(other._rejected, _rejected)&&(identical(other.serverVersion, serverVersion) || other.serverVersion == serverVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_accepted),const DeepCollectionEquality().hash(_rejected),serverVersion);

@override
String toString() {
  return 'PushResponse(accepted: $accepted, rejected: $rejected, serverVersion: $serverVersion)';
}


}

/// @nodoc
abstract mixin class _$PushResponseCopyWith<$Res> implements $PushResponseCopyWith<$Res> {
  factory _$PushResponseCopyWith(_PushResponse value, $Res Function(_PushResponse) _then) = __$PushResponseCopyWithImpl;
@override @useResult
$Res call({
 List<String> accepted, List<String> rejected,@JsonKey(name: 'server_version') int serverVersion
});




}
/// @nodoc
class __$PushResponseCopyWithImpl<$Res>
    implements _$PushResponseCopyWith<$Res> {
  __$PushResponseCopyWithImpl(this._self, this._then);

  final _PushResponse _self;
  final $Res Function(_PushResponse) _then;

/// Create a copy of PushResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accepted = null,Object? rejected = null,Object? serverVersion = null,}) {
  return _then(_PushResponse(
accepted: null == accepted ? _self._accepted : accepted // ignore: cast_nullable_to_non_nullable
as List<String>,rejected: null == rejected ? _self._rejected : rejected // ignore: cast_nullable_to_non_nullable
as List<String>,serverVersion: null == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PullResponse {

 Map<String, dynamic> get records;@JsonKey(name: 'server_version') int get serverVersion;
/// Create a copy of PullResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullResponseCopyWith<PullResponse> get copyWith => _$PullResponseCopyWithImpl<PullResponse>(this as PullResponse, _$identity);

  /// Serializes this PullResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullResponse&&const DeepCollectionEquality().equals(other.records, records)&&(identical(other.serverVersion, serverVersion) || other.serverVersion == serverVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(records),serverVersion);

@override
String toString() {
  return 'PullResponse(records: $records, serverVersion: $serverVersion)';
}


}

/// @nodoc
abstract mixin class $PullResponseCopyWith<$Res>  {
  factory $PullResponseCopyWith(PullResponse value, $Res Function(PullResponse) _then) = _$PullResponseCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> records,@JsonKey(name: 'server_version') int serverVersion
});




}
/// @nodoc
class _$PullResponseCopyWithImpl<$Res>
    implements $PullResponseCopyWith<$Res> {
  _$PullResponseCopyWithImpl(this._self, this._then);

  final PullResponse _self;
  final $Res Function(PullResponse) _then;

/// Create a copy of PullResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? records = null,Object? serverVersion = null,}) {
  return _then(_self.copyWith(
records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,serverVersion: null == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PullResponse].
extension PullResponsePatterns on PullResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PullResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PullResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PullResponse value)  $default,){
final _that = this;
switch (_that) {
case _PullResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PullResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PullResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> records, @JsonKey(name: 'server_version')  int serverVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PullResponse() when $default != null:
return $default(_that.records,_that.serverVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> records, @JsonKey(name: 'server_version')  int serverVersion)  $default,) {final _that = this;
switch (_that) {
case _PullResponse():
return $default(_that.records,_that.serverVersion);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> records, @JsonKey(name: 'server_version')  int serverVersion)?  $default,) {final _that = this;
switch (_that) {
case _PullResponse() when $default != null:
return $default(_that.records,_that.serverVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PullResponse implements PullResponse {
  const _PullResponse({required final  Map<String, dynamic> records, @JsonKey(name: 'server_version') required this.serverVersion}): _records = records;
  factory _PullResponse.fromJson(Map<String, dynamic> json) => _$PullResponseFromJson(json);

 final  Map<String, dynamic> _records;
@override Map<String, dynamic> get records {
  if (_records is EqualUnmodifiableMapView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_records);
}

@override@JsonKey(name: 'server_version') final  int serverVersion;

/// Create a copy of PullResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PullResponseCopyWith<_PullResponse> get copyWith => __$PullResponseCopyWithImpl<_PullResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PullResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PullResponse&&const DeepCollectionEquality().equals(other._records, _records)&&(identical(other.serverVersion, serverVersion) || other.serverVersion == serverVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_records),serverVersion);

@override
String toString() {
  return 'PullResponse(records: $records, serverVersion: $serverVersion)';
}


}

/// @nodoc
abstract mixin class _$PullResponseCopyWith<$Res> implements $PullResponseCopyWith<$Res> {
  factory _$PullResponseCopyWith(_PullResponse value, $Res Function(_PullResponse) _then) = __$PullResponseCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> records,@JsonKey(name: 'server_version') int serverVersion
});




}
/// @nodoc
class __$PullResponseCopyWithImpl<$Res>
    implements _$PullResponseCopyWith<$Res> {
  __$PullResponseCopyWithImpl(this._self, this._then);

  final _PullResponse _self;
  final $Res Function(_PullResponse) _then;

/// Create a copy of PullResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? records = null,Object? serverVersion = null,}) {
  return _then(_PullResponse(
records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,serverVersion: null == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SyncState {

 SyncStatus get status; int get lastSyncVersion; DateTime? get lastSyncTime; String? get errorMessage; int get pendingChanges;
/// Create a copy of SyncState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncStateCopyWith<SyncState> get copyWith => _$SyncStateCopyWithImpl<SyncState>(this as SyncState, _$identity);

  /// Serializes this SyncState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncState&&(identical(other.status, status) || other.status == status)&&(identical(other.lastSyncVersion, lastSyncVersion) || other.lastSyncVersion == lastSyncVersion)&&(identical(other.lastSyncTime, lastSyncTime) || other.lastSyncTime == lastSyncTime)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.pendingChanges, pendingChanges) || other.pendingChanges == pendingChanges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,lastSyncVersion,lastSyncTime,errorMessage,pendingChanges);

@override
String toString() {
  return 'SyncState(status: $status, lastSyncVersion: $lastSyncVersion, lastSyncTime: $lastSyncTime, errorMessage: $errorMessage, pendingChanges: $pendingChanges)';
}


}

/// @nodoc
abstract mixin class $SyncStateCopyWith<$Res>  {
  factory $SyncStateCopyWith(SyncState value, $Res Function(SyncState) _then) = _$SyncStateCopyWithImpl;
@useResult
$Res call({
 SyncStatus status, int lastSyncVersion, DateTime? lastSyncTime, String? errorMessage, int pendingChanges
});




}
/// @nodoc
class _$SyncStateCopyWithImpl<$Res>
    implements $SyncStateCopyWith<$Res> {
  _$SyncStateCopyWithImpl(this._self, this._then);

  final SyncState _self;
  final $Res Function(SyncState) _then;

/// Create a copy of SyncState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? lastSyncVersion = null,Object? lastSyncTime = freezed,Object? errorMessage = freezed,Object? pendingChanges = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SyncStatus,lastSyncVersion: null == lastSyncVersion ? _self.lastSyncVersion : lastSyncVersion // ignore: cast_nullable_to_non_nullable
as int,lastSyncTime: freezed == lastSyncTime ? _self.lastSyncTime : lastSyncTime // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,pendingChanges: null == pendingChanges ? _self.pendingChanges : pendingChanges // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncState].
extension SyncStatePatterns on SyncState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncState value)  $default,){
final _that = this;
switch (_that) {
case _SyncState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncState value)?  $default,){
final _that = this;
switch (_that) {
case _SyncState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SyncStatus status,  int lastSyncVersion,  DateTime? lastSyncTime,  String? errorMessage,  int pendingChanges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncState() when $default != null:
return $default(_that.status,_that.lastSyncVersion,_that.lastSyncTime,_that.errorMessage,_that.pendingChanges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SyncStatus status,  int lastSyncVersion,  DateTime? lastSyncTime,  String? errorMessage,  int pendingChanges)  $default,) {final _that = this;
switch (_that) {
case _SyncState():
return $default(_that.status,_that.lastSyncVersion,_that.lastSyncTime,_that.errorMessage,_that.pendingChanges);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SyncStatus status,  int lastSyncVersion,  DateTime? lastSyncTime,  String? errorMessage,  int pendingChanges)?  $default,) {final _that = this;
switch (_that) {
case _SyncState() when $default != null:
return $default(_that.status,_that.lastSyncVersion,_that.lastSyncTime,_that.errorMessage,_that.pendingChanges);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncState implements SyncState {
  const _SyncState({this.status = SyncStatus.idle, this.lastSyncVersion = 0, this.lastSyncTime, this.errorMessage, this.pendingChanges = 0});
  factory _SyncState.fromJson(Map<String, dynamic> json) => _$SyncStateFromJson(json);

@override@JsonKey() final  SyncStatus status;
@override@JsonKey() final  int lastSyncVersion;
@override final  DateTime? lastSyncTime;
@override final  String? errorMessage;
@override@JsonKey() final  int pendingChanges;

/// Create a copy of SyncState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncStateCopyWith<_SyncState> get copyWith => __$SyncStateCopyWithImpl<_SyncState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncState&&(identical(other.status, status) || other.status == status)&&(identical(other.lastSyncVersion, lastSyncVersion) || other.lastSyncVersion == lastSyncVersion)&&(identical(other.lastSyncTime, lastSyncTime) || other.lastSyncTime == lastSyncTime)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.pendingChanges, pendingChanges) || other.pendingChanges == pendingChanges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,lastSyncVersion,lastSyncTime,errorMessage,pendingChanges);

@override
String toString() {
  return 'SyncState(status: $status, lastSyncVersion: $lastSyncVersion, lastSyncTime: $lastSyncTime, errorMessage: $errorMessage, pendingChanges: $pendingChanges)';
}


}

/// @nodoc
abstract mixin class _$SyncStateCopyWith<$Res> implements $SyncStateCopyWith<$Res> {
  factory _$SyncStateCopyWith(_SyncState value, $Res Function(_SyncState) _then) = __$SyncStateCopyWithImpl;
@override @useResult
$Res call({
 SyncStatus status, int lastSyncVersion, DateTime? lastSyncTime, String? errorMessage, int pendingChanges
});




}
/// @nodoc
class __$SyncStateCopyWithImpl<$Res>
    implements _$SyncStateCopyWith<$Res> {
  __$SyncStateCopyWithImpl(this._self, this._then);

  final _SyncState _self;
  final $Res Function(_SyncState) _then;

/// Create a copy of SyncState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? lastSyncVersion = null,Object? lastSyncTime = freezed,Object? errorMessage = freezed,Object? pendingChanges = null,}) {
  return _then(_SyncState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SyncStatus,lastSyncVersion: null == lastSyncVersion ? _self.lastSyncVersion : lastSyncVersion // ignore: cast_nullable_to_non_nullable
as int,lastSyncTime: freezed == lastSyncTime ? _self.lastSyncTime : lastSyncTime // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,pendingChanges: null == pendingChanges ? _self.pendingChanges : pendingChanges // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
