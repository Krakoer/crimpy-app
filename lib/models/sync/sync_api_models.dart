import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_api_models.freezed.dart';
part 'sync_api_models.g.dart';

@freezed
sealed class SyncSummaryResponse with _$SyncSummaryResponse {
  const factory SyncSummaryResponse({
    // ignore: invalid_annotation_target
    @JsonKey(name: 'user_id') required String userId,
    required Map<String, int> collections,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'last_sync_version') required int lastSyncVersion,
  }) = _SyncSummaryResponse;

  factory SyncSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncSummaryResponseFromJson(json);
}

@freezed
sealed class SyncPullResponse with _$SyncPullResponse {
  const factory SyncPullResponse({
    // ignore: invalid_annotation_target
    @JsonKey(name: 'server_version') required int serverVersion,
    required Map<String, List<Map<String, dynamic>>> records,
  }) = _SyncPullResponse;

  factory SyncPullResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncPullResponseFromJson(json);
}

@freezed
sealed class SyncPushRequest with _$SyncPushRequest {
  const factory SyncPushRequest({
    required Map<String, List<Map<String, dynamic>>> records,
  }) = _SyncPushRequest;

  factory SyncPushRequest.fromJson(Map<String, dynamic> json) =>
      _$SyncPushRequestFromJson(json);
}

@freezed
sealed class SyncPushResponse with _$SyncPushResponse {
  const factory SyncPushResponse({
    // ignore: invalid_annotation_target
    @JsonKey(name: 'server_version') required int serverVersion,
    required List<String> accepted,
    required List<String> rejected,
    required List<String> conflicts,
  }) = _SyncPushResponse;

  factory SyncPushResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncPushResponseFromJson(json);
}
