import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_models.freezed.dart';
part 'sync_models.g.dart';

@freezed
abstract class SyncSummaryResponse with _$SyncSummaryResponse {
  const factory SyncSummaryResponse({
    required String userId,
    required int lastSyncVersion,
    required Map<String, int> collections,
  }) = _SyncSummaryResponse;

  factory SyncSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncSummaryResponseFromJson(json);
}

@freezed
abstract class PushRequest with _$PushRequest {
  const factory PushRequest({required Map<String, dynamic> records}) =
      _PushRequest;

  factory PushRequest.fromJson(Map<String, dynamic> json) =>
      _$PushRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => {'records': records};
}

@freezed
abstract class PushResponse with _$PushResponse {
  const factory PushResponse({
    required List<String> accepted,
    required List<String> rejected,
    required int serverVersion,
  }) = _PushResponse;

  factory PushResponse.fromJson(Map<String, dynamic> json) =>
      _$PushResponseFromJson(json);
}

@freezed
abstract class PullResponse with _$PullResponse {
  const factory PullResponse({
    required Map<String, dynamic> records,
    required int serverVersion,
  }) = _PullResponse;

  factory PullResponse.fromJson(Map<String, dynamic> json) =>
      _$PullResponseFromJson(json);
}

@freezed
abstract class SyncRecord with _$SyncRecord {
  const factory SyncRecord({
    required String id,
    required String remoteId,
    required Map<String, dynamic> data,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SyncRecord;

  factory SyncRecord.fromJson(Map<String, dynamic> json) =>
      _$SyncRecordFromJson(json);
}

enum SyncStatus { idle, syncing, success, error }

@freezed
abstract class SyncState with _$SyncState {
  const factory SyncState({
    @Default(SyncStatus.idle) SyncStatus status,
    @Default(0) int lastSyncVersion,
    DateTime? lastSyncTime,
    String? errorMessage,
    @Default(0) int pendingChanges,
  }) = _SyncState;

  factory SyncState.fromJson(Map<String, dynamic> json) =>
      _$SyncStateFromJson(json);
}
