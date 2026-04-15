// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncSummaryResponse _$SyncSummaryResponseFromJson(Map<String, dynamic> json) =>
    _SyncSummaryResponse(
      userId: json['userId'] as String,
      lastSyncVersion: (json['lastSyncVersion'] as num).toInt(),
      collections: Map<String, int>.from(json['collections'] as Map),
    );

Map<String, dynamic> _$SyncSummaryResponseToJson(
  _SyncSummaryResponse instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'lastSyncVersion': instance.lastSyncVersion,
  'collections': instance.collections,
};

_PushRequest _$PushRequestFromJson(Map<String, dynamic> json) =>
    _PushRequest(records: json['records'] as Map<String, dynamic>);

Map<String, dynamic> _$PushRequestToJson(_PushRequest instance) =>
    <String, dynamic>{'records': instance.records};

_PushResponse _$PushResponseFromJson(Map<String, dynamic> json) =>
    _PushResponse(
      accepted:
          (json['accepted'] as List<dynamic>).map((e) => e as String).toList(),
      rejected:
          (json['rejected'] as List<dynamic>).map((e) => e as String).toList(),
      serverVersion: (json['serverVersion'] as num).toInt(),
    );

Map<String, dynamic> _$PushResponseToJson(_PushResponse instance) =>
    <String, dynamic>{
      'accepted': instance.accepted,
      'rejected': instance.rejected,
      'serverVersion': instance.serverVersion,
    };

_PullResponse _$PullResponseFromJson(Map<String, dynamic> json) =>
    _PullResponse(
      records: json['records'] as Map<String, dynamic>,
      serverVersion: (json['serverVersion'] as num).toInt(),
    );

Map<String, dynamic> _$PullResponseToJson(_PullResponse instance) =>
    <String, dynamic>{
      'records': instance.records,
      'serverVersion': instance.serverVersion,
    };

_SyncRecord _$SyncRecordFromJson(Map<String, dynamic> json) => _SyncRecord(
  id: json['id'] as String,
  remoteId: json['remoteId'] as String,
  data: json['data'] as Map<String, dynamic>,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$SyncRecordToJson(_SyncRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'remoteId': instance.remoteId,
      'data': instance.data,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SyncState _$SyncStateFromJson(Map<String, dynamic> json) => _SyncState(
  status:
      $enumDecodeNullable(_$SyncStatusEnumMap, json['status']) ??
      SyncStatus.idle,
  lastSyncVersion: (json['lastSyncVersion'] as num?)?.toInt() ?? 0,
  lastSyncTime:
      json['lastSyncTime'] == null
          ? null
          : DateTime.parse(json['lastSyncTime'] as String),
  errorMessage: json['errorMessage'] as String?,
  pendingChanges: (json['pendingChanges'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SyncStateToJson(_SyncState instance) =>
    <String, dynamic>{
      'status': _$SyncStatusEnumMap[instance.status]!,
      'lastSyncVersion': instance.lastSyncVersion,
      'lastSyncTime': instance.lastSyncTime?.toIso8601String(),
      'errorMessage': instance.errorMessage,
      'pendingChanges': instance.pendingChanges,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.idle: 'idle',
  SyncStatus.syncing: 'syncing',
  SyncStatus.success: 'success',
  SyncStatus.error: 'error',
};
