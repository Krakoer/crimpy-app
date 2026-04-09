import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';

@freezed
class SyncState with _$SyncState {
  const factory SyncState({
    @Default(false) bool isSyncing,
    DateTime? lastSyncTime,
    @Default(0) int pendingChanges,
    String? error,
    @Default(SyncPhase.idle) SyncPhase phase,
  }) = _SyncState;
}

enum SyncPhase {
  idle,
  pushingSessions,
  pushingTrainings,
  pushingRepeaters,
  pullingSessions,
  pullingTrainings,
  pullingRepeaters,
}
