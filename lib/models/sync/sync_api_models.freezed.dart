// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncSummaryResponse {

// ignore: invalid_annotation_target
@JsonKey(name: 'user_id') String get userId; Map<String, int> get collections;// ignore: invalid_annotation_target
@JsonKey(name: 'last_sync_version') int get lastSyncVersion;
/// Create a copy of SyncSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncSummaryResponseCopyWith<SyncSummaryResponse> get copyWith => _$SyncSummaryResponseCopyWithImpl<SyncSummaryResponse>(this as SyncSummaryResponse, _$identity);

  /// Serializes this SyncSummaryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncSummaryResponse&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.collections, collections)&&(identical(other.lastSyncVersion, lastSyncVersion) || other.lastSyncVersion == lastSyncVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,const DeepCollectionEquality().hash(collections),lastSyncVersion);

@override
String toString() {
  return 'SyncSummaryResponse(userId: $userId, collections: $collections, lastSyncVersion: $lastSyncVersion)';
}


}

/// @nodoc
abstract mixin class $SyncSummaryResponseCopyWith<$Res>  {
  factory $SyncSummaryResponseCopyWith(SyncSummaryResponse value, $Res Function(SyncSummaryResponse) _then) = _$SyncSummaryResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, Map<String, int> collections,@JsonKey(name: 'last_sync_version') int lastSyncVersion
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
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? collections = null,Object? lastSyncVersion = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as Map<String, int>,lastSyncVersion: null == lastSyncVersion ? _self.lastSyncVersion : lastSyncVersion // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  Map<String, int> collections, @JsonKey(name: 'last_sync_version')  int lastSyncVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncSummaryResponse() when $default != null:
return $default(_that.userId,_that.collections,_that.lastSyncVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  Map<String, int> collections, @JsonKey(name: 'last_sync_version')  int lastSyncVersion)  $default,) {final _that = this;
switch (_that) {
case _SyncSummaryResponse():
return $default(_that.userId,_that.collections,_that.lastSyncVersion);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  Map<String, int> collections, @JsonKey(name: 'last_sync_version')  int lastSyncVersion)?  $default,) {final _that = this;
switch (_that) {
case _SyncSummaryResponse() when $default != null:
return $default(_that.userId,_that.collections,_that.lastSyncVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncSummaryResponse implements SyncSummaryResponse {
  const _SyncSummaryResponse({@JsonKey(name: 'user_id') required this.userId, required final  Map<String, int> collections, @JsonKey(name: 'last_sync_version') required this.lastSyncVersion}): _collections = collections;
  factory _SyncSummaryResponse.fromJson(Map<String, dynamic> json) => _$SyncSummaryResponseFromJson(json);

// ignore: invalid_annotation_target
@override@JsonKey(name: 'user_id') final  String userId;
 final  Map<String, int> _collections;
@override Map<String, int> get collections {
  if (_collections is EqualUnmodifiableMapView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_collections);
}

// ignore: invalid_annotation_target
@override@JsonKey(name: 'last_sync_version') final  int lastSyncVersion;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncSummaryResponse&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._collections, _collections)&&(identical(other.lastSyncVersion, lastSyncVersion) || other.lastSyncVersion == lastSyncVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,const DeepCollectionEquality().hash(_collections),lastSyncVersion);

@override
String toString() {
  return 'SyncSummaryResponse(userId: $userId, collections: $collections, lastSyncVersion: $lastSyncVersion)';
}


}

/// @nodoc
abstract mixin class _$SyncSummaryResponseCopyWith<$Res> implements $SyncSummaryResponseCopyWith<$Res> {
  factory _$SyncSummaryResponseCopyWith(_SyncSummaryResponse value, $Res Function(_SyncSummaryResponse) _then) = __$SyncSummaryResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, Map<String, int> collections,@JsonKey(name: 'last_sync_version') int lastSyncVersion
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
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? collections = null,Object? lastSyncVersion = null,}) {
  return _then(_SyncSummaryResponse(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as Map<String, int>,lastSyncVersion: null == lastSyncVersion ? _self.lastSyncVersion : lastSyncVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SyncPullResponse {

// ignore: invalid_annotation_target
@JsonKey(name: 'server_version') int get serverVersion; Map<String, List<Map<String, dynamic>>> get records;
/// Create a copy of SyncPullResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncPullResponseCopyWith<SyncPullResponse> get copyWith => _$SyncPullResponseCopyWithImpl<SyncPullResponse>(this as SyncPullResponse, _$identity);

  /// Serializes this SyncPullResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncPullResponse&&(identical(other.serverVersion, serverVersion) || other.serverVersion == serverVersion)&&const DeepCollectionEquality().equals(other.records, records));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serverVersion,const DeepCollectionEquality().hash(records));

@override
String toString() {
  return 'SyncPullResponse(serverVersion: $serverVersion, records: $records)';
}


}

/// @nodoc
abstract mixin class $SyncPullResponseCopyWith<$Res>  {
  factory $SyncPullResponseCopyWith(SyncPullResponse value, $Res Function(SyncPullResponse) _then) = _$SyncPullResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'server_version') int serverVersion, Map<String, List<Map<String, dynamic>>> records
});




}
/// @nodoc
class _$SyncPullResponseCopyWithImpl<$Res>
    implements $SyncPullResponseCopyWith<$Res> {
  _$SyncPullResponseCopyWithImpl(this._self, this._then);

  final SyncPullResponse _self;
  final $Res Function(SyncPullResponse) _then;

/// Create a copy of SyncPullResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serverVersion = null,Object? records = null,}) {
  return _then(_self.copyWith(
serverVersion: null == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as int,records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as Map<String, List<Map<String, dynamic>>>,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncPullResponse].
extension SyncPullResponsePatterns on SyncPullResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncPullResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncPullResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncPullResponse value)  $default,){
final _that = this;
switch (_that) {
case _SyncPullResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncPullResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SyncPullResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'server_version')  int serverVersion,  Map<String, List<Map<String, dynamic>>> records)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncPullResponse() when $default != null:
return $default(_that.serverVersion,_that.records);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'server_version')  int serverVersion,  Map<String, List<Map<String, dynamic>>> records)  $default,) {final _that = this;
switch (_that) {
case _SyncPullResponse():
return $default(_that.serverVersion,_that.records);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'server_version')  int serverVersion,  Map<String, List<Map<String, dynamic>>> records)?  $default,) {final _that = this;
switch (_that) {
case _SyncPullResponse() when $default != null:
return $default(_that.serverVersion,_that.records);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncPullResponse implements SyncPullResponse {
  const _SyncPullResponse({@JsonKey(name: 'server_version') required this.serverVersion, required final  Map<String, List<Map<String, dynamic>>> records}): _records = records;
  factory _SyncPullResponse.fromJson(Map<String, dynamic> json) => _$SyncPullResponseFromJson(json);

// ignore: invalid_annotation_target
@override@JsonKey(name: 'server_version') final  int serverVersion;
 final  Map<String, List<Map<String, dynamic>>> _records;
@override Map<String, List<Map<String, dynamic>>> get records {
  if (_records is EqualUnmodifiableMapView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_records);
}


/// Create a copy of SyncPullResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncPullResponseCopyWith<_SyncPullResponse> get copyWith => __$SyncPullResponseCopyWithImpl<_SyncPullResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncPullResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncPullResponse&&(identical(other.serverVersion, serverVersion) || other.serverVersion == serverVersion)&&const DeepCollectionEquality().equals(other._records, _records));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serverVersion,const DeepCollectionEquality().hash(_records));

@override
String toString() {
  return 'SyncPullResponse(serverVersion: $serverVersion, records: $records)';
}


}

/// @nodoc
abstract mixin class _$SyncPullResponseCopyWith<$Res> implements $SyncPullResponseCopyWith<$Res> {
  factory _$SyncPullResponseCopyWith(_SyncPullResponse value, $Res Function(_SyncPullResponse) _then) = __$SyncPullResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'server_version') int serverVersion, Map<String, List<Map<String, dynamic>>> records
});




}
/// @nodoc
class __$SyncPullResponseCopyWithImpl<$Res>
    implements _$SyncPullResponseCopyWith<$Res> {
  __$SyncPullResponseCopyWithImpl(this._self, this._then);

  final _SyncPullResponse _self;
  final $Res Function(_SyncPullResponse) _then;

/// Create a copy of SyncPullResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serverVersion = null,Object? records = null,}) {
  return _then(_SyncPullResponse(
serverVersion: null == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as int,records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as Map<String, List<Map<String, dynamic>>>,
  ));
}


}


/// @nodoc
mixin _$SyncPushRequest {

 Map<String, List<Map<String, dynamic>>> get records;
/// Create a copy of SyncPushRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncPushRequestCopyWith<SyncPushRequest> get copyWith => _$SyncPushRequestCopyWithImpl<SyncPushRequest>(this as SyncPushRequest, _$identity);

  /// Serializes this SyncPushRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncPushRequest&&const DeepCollectionEquality().equals(other.records, records));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(records));

@override
String toString() {
  return 'SyncPushRequest(records: $records)';
}


}

/// @nodoc
abstract mixin class $SyncPushRequestCopyWith<$Res>  {
  factory $SyncPushRequestCopyWith(SyncPushRequest value, $Res Function(SyncPushRequest) _then) = _$SyncPushRequestCopyWithImpl;
@useResult
$Res call({
 Map<String, List<Map<String, dynamic>>> records
});




}
/// @nodoc
class _$SyncPushRequestCopyWithImpl<$Res>
    implements $SyncPushRequestCopyWith<$Res> {
  _$SyncPushRequestCopyWithImpl(this._self, this._then);

  final SyncPushRequest _self;
  final $Res Function(SyncPushRequest) _then;

/// Create a copy of SyncPushRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? records = null,}) {
  return _then(_self.copyWith(
records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as Map<String, List<Map<String, dynamic>>>,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncPushRequest].
extension SyncPushRequestPatterns on SyncPushRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncPushRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncPushRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncPushRequest value)  $default,){
final _that = this;
switch (_that) {
case _SyncPushRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncPushRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SyncPushRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, List<Map<String, dynamic>>> records)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncPushRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, List<Map<String, dynamic>>> records)  $default,) {final _that = this;
switch (_that) {
case _SyncPushRequest():
return $default(_that.records);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, List<Map<String, dynamic>>> records)?  $default,) {final _that = this;
switch (_that) {
case _SyncPushRequest() when $default != null:
return $default(_that.records);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncPushRequest implements SyncPushRequest {
  const _SyncPushRequest({required final  Map<String, List<Map<String, dynamic>>> records}): _records = records;
  factory _SyncPushRequest.fromJson(Map<String, dynamic> json) => _$SyncPushRequestFromJson(json);

 final  Map<String, List<Map<String, dynamic>>> _records;
@override Map<String, List<Map<String, dynamic>>> get records {
  if (_records is EqualUnmodifiableMapView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_records);
}


/// Create a copy of SyncPushRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncPushRequestCopyWith<_SyncPushRequest> get copyWith => __$SyncPushRequestCopyWithImpl<_SyncPushRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncPushRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncPushRequest&&const DeepCollectionEquality().equals(other._records, _records));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_records));

@override
String toString() {
  return 'SyncPushRequest(records: $records)';
}


}

/// @nodoc
abstract mixin class _$SyncPushRequestCopyWith<$Res> implements $SyncPushRequestCopyWith<$Res> {
  factory _$SyncPushRequestCopyWith(_SyncPushRequest value, $Res Function(_SyncPushRequest) _then) = __$SyncPushRequestCopyWithImpl;
@override @useResult
$Res call({
 Map<String, List<Map<String, dynamic>>> records
});




}
/// @nodoc
class __$SyncPushRequestCopyWithImpl<$Res>
    implements _$SyncPushRequestCopyWith<$Res> {
  __$SyncPushRequestCopyWithImpl(this._self, this._then);

  final _SyncPushRequest _self;
  final $Res Function(_SyncPushRequest) _then;

/// Create a copy of SyncPushRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? records = null,}) {
  return _then(_SyncPushRequest(
records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as Map<String, List<Map<String, dynamic>>>,
  ));
}


}


/// @nodoc
mixin _$SyncPushResponse {

// ignore: invalid_annotation_target
@JsonKey(name: 'server_version') int get serverVersion; List<String> get accepted; List<String> get rejected; List<String> get conflicts;
/// Create a copy of SyncPushResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncPushResponseCopyWith<SyncPushResponse> get copyWith => _$SyncPushResponseCopyWithImpl<SyncPushResponse>(this as SyncPushResponse, _$identity);

  /// Serializes this SyncPushResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncPushResponse&&(identical(other.serverVersion, serverVersion) || other.serverVersion == serverVersion)&&const DeepCollectionEquality().equals(other.accepted, accepted)&&const DeepCollectionEquality().equals(other.rejected, rejected)&&const DeepCollectionEquality().equals(other.conflicts, conflicts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serverVersion,const DeepCollectionEquality().hash(accepted),const DeepCollectionEquality().hash(rejected),const DeepCollectionEquality().hash(conflicts));

@override
String toString() {
  return 'SyncPushResponse(serverVersion: $serverVersion, accepted: $accepted, rejected: $rejected, conflicts: $conflicts)';
}


}

/// @nodoc
abstract mixin class $SyncPushResponseCopyWith<$Res>  {
  factory $SyncPushResponseCopyWith(SyncPushResponse value, $Res Function(SyncPushResponse) _then) = _$SyncPushResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'server_version') int serverVersion, List<String> accepted, List<String> rejected, List<String> conflicts
});




}
/// @nodoc
class _$SyncPushResponseCopyWithImpl<$Res>
    implements $SyncPushResponseCopyWith<$Res> {
  _$SyncPushResponseCopyWithImpl(this._self, this._then);

  final SyncPushResponse _self;
  final $Res Function(SyncPushResponse) _then;

/// Create a copy of SyncPushResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serverVersion = null,Object? accepted = null,Object? rejected = null,Object? conflicts = null,}) {
  return _then(_self.copyWith(
serverVersion: null == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as int,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as List<String>,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as List<String>,conflicts: null == conflicts ? _self.conflicts : conflicts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncPushResponse].
extension SyncPushResponsePatterns on SyncPushResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncPushResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncPushResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncPushResponse value)  $default,){
final _that = this;
switch (_that) {
case _SyncPushResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncPushResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SyncPushResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'server_version')  int serverVersion,  List<String> accepted,  List<String> rejected,  List<String> conflicts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncPushResponse() when $default != null:
return $default(_that.serverVersion,_that.accepted,_that.rejected,_that.conflicts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'server_version')  int serverVersion,  List<String> accepted,  List<String> rejected,  List<String> conflicts)  $default,) {final _that = this;
switch (_that) {
case _SyncPushResponse():
return $default(_that.serverVersion,_that.accepted,_that.rejected,_that.conflicts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'server_version')  int serverVersion,  List<String> accepted,  List<String> rejected,  List<String> conflicts)?  $default,) {final _that = this;
switch (_that) {
case _SyncPushResponse() when $default != null:
return $default(_that.serverVersion,_that.accepted,_that.rejected,_that.conflicts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncPushResponse implements SyncPushResponse {
  const _SyncPushResponse({@JsonKey(name: 'server_version') required this.serverVersion, required final  List<String> accepted, required final  List<String> rejected, required final  List<String> conflicts}): _accepted = accepted,_rejected = rejected,_conflicts = conflicts;
  factory _SyncPushResponse.fromJson(Map<String, dynamic> json) => _$SyncPushResponseFromJson(json);

// ignore: invalid_annotation_target
@override@JsonKey(name: 'server_version') final  int serverVersion;
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

 final  List<String> _conflicts;
@override List<String> get conflicts {
  if (_conflicts is EqualUnmodifiableListView) return _conflicts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conflicts);
}


/// Create a copy of SyncPushResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncPushResponseCopyWith<_SyncPushResponse> get copyWith => __$SyncPushResponseCopyWithImpl<_SyncPushResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncPushResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncPushResponse&&(identical(other.serverVersion, serverVersion) || other.serverVersion == serverVersion)&&const DeepCollectionEquality().equals(other._accepted, _accepted)&&const DeepCollectionEquality().equals(other._rejected, _rejected)&&const DeepCollectionEquality().equals(other._conflicts, _conflicts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serverVersion,const DeepCollectionEquality().hash(_accepted),const DeepCollectionEquality().hash(_rejected),const DeepCollectionEquality().hash(_conflicts));

@override
String toString() {
  return 'SyncPushResponse(serverVersion: $serverVersion, accepted: $accepted, rejected: $rejected, conflicts: $conflicts)';
}


}

/// @nodoc
abstract mixin class _$SyncPushResponseCopyWith<$Res> implements $SyncPushResponseCopyWith<$Res> {
  factory _$SyncPushResponseCopyWith(_SyncPushResponse value, $Res Function(_SyncPushResponse) _then) = __$SyncPushResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'server_version') int serverVersion, List<String> accepted, List<String> rejected, List<String> conflicts
});




}
/// @nodoc
class __$SyncPushResponseCopyWithImpl<$Res>
    implements _$SyncPushResponseCopyWith<$Res> {
  __$SyncPushResponseCopyWithImpl(this._self, this._then);

  final _SyncPushResponse _self;
  final $Res Function(_SyncPushResponse) _then;

/// Create a copy of SyncPushResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serverVersion = null,Object? accepted = null,Object? rejected = null,Object? conflicts = null,}) {
  return _then(_SyncPushResponse(
serverVersion: null == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as int,accepted: null == accepted ? _self._accepted : accepted // ignore: cast_nullable_to_non_nullable
as List<String>,rejected: null == rejected ? _self._rejected : rejected // ignore: cast_nullable_to_non_nullable
as List<String>,conflicts: null == conflicts ? _self._conflicts : conflicts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
