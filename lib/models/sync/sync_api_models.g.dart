// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncSummaryResponse _$SyncSummaryResponseFromJson(Map<String, dynamic> json) =>
    _SyncSummaryResponse(
      userId: json['user_id'] as String,
      collections: Map<String, int>.from(json['collections'] as Map),
      lastSyncVersion: (json['last_sync_version'] as num).toInt(),
    );

Map<String, dynamic> _$SyncSummaryResponseToJson(
  _SyncSummaryResponse instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'collections': instance.collections,
  'last_sync_version': instance.lastSyncVersion,
};

_SyncPullResponse _$SyncPullResponseFromJson(Map<String, dynamic> json) =>
    _SyncPullResponse(
      serverVersion: (json['server_version'] as num).toInt(),
      records: (json['records'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>).map((e) => e as Map<String, dynamic>).toList(),
        ),
      ),
    );

Map<String, dynamic> _$SyncPullResponseToJson(_SyncPullResponse instance) =>
    <String, dynamic>{
      'server_version': instance.serverVersion,
      'records': instance.records,
    };

_SyncPushRequest _$SyncPushRequestFromJson(Map<String, dynamic> json) =>
    _SyncPushRequest(
      records: (json['records'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>).map((e) => e as Map<String, dynamic>).toList(),
        ),
      ),
    );

Map<String, dynamic> _$SyncPushRequestToJson(_SyncPushRequest instance) =>
    <String, dynamic>{'records': instance.records};

_SyncPushResponse _$SyncPushResponseFromJson(Map<String, dynamic> json) =>
    _SyncPushResponse(
      serverVersion: (json['server_version'] as num).toInt(),
      accepted:
          (json['accepted'] as List<dynamic>).map((e) => e as String).toList(),
      rejected:
          (json['rejected'] as List<dynamic>).map((e) => e as String).toList(),
      conflicts:
          (json['conflicts'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SyncPushResponseToJson(_SyncPushResponse instance) =>
    <String, dynamic>{
      'server_version': instance.serverVersion,
      'accepted': instance.accepted,
      'rejected': instance.rejected,
      'conflicts': instance.conflicts,
    };
