import 'package:crimpy/database/database.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/sync/sync_state.dart';
import 'package:crimpy/services/api/api_client.dart';
import 'package:crimpy/services/api/session_api_service.dart';
import 'package:crimpy/services/api/training_api_service.dart';
import 'package:crimpy/services/sync/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_view_model.g.dart';

@riverpod
class SyncViewModel extends _$SyncViewModel {
  late final SyncService _syncService;

  @override
  SyncState build() {
    final apiClient = ApiClient();
    final database = gDatabase;
    final sessionApi = SessionApiService(apiClient);
    final trainingApi = TrainingApiService(apiClient);
    final connectivity = Connectivity();

    _syncService = SyncService(database, sessionApi, trainingApi, connectivity);

    _checkPendingChanges();
    return const SyncState();
  }

  Future<void> _checkPendingChanges() async {
    final pending = await gDatabase.getEntitiesNeedingUpload();
    state = state.copyWith(pendingChanges: pending.length);
  }

  Future<void> syncAll() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      error: null,
      phase: SyncPhase.pushingSessions,
    );

    try {
      await _syncService.syncAll();

      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        pendingChanges: 0,
        phase: SyncPhase.idle,
      );

      AppLoggerHelper.info('Sync completed successfully');
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
        phase: SyncPhase.idle,
      );

      AppLoggerHelper.error('Sync failed: $e');
      rethrow;
    }
  }

  Future<void> pushChanges() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      error: null,
      phase: SyncPhase.pushingSessions,
    );

    try {
      await _syncService.pushChanges();

      final pending = await gDatabase.getEntitiesNeedingUpload();
      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        pendingChanges: pending.length,
        phase: SyncPhase.idle,
      );

      AppLoggerHelper.info('Push completed successfully');
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
        phase: SyncPhase.idle,
      );

      AppLoggerHelper.error('Push failed: $e');
      rethrow;
    }
  }

  Future<void> pullChanges() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      error: null,
      phase: SyncPhase.pullingSessions,
    );

    try {
      await _syncService.pullChanges();

      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        phase: SyncPhase.idle,
      );

      AppLoggerHelper.info('Pull completed successfully');
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
        phase: SyncPhase.idle,
      );

      AppLoggerHelper.error('Pull failed: $e');
      rethrow;
    }
  }

  Future<void> retryOfflineQueue() async {
    try {
      await _syncService.retryOfflineQueue();
      await _checkPendingChanges();
      AppLoggerHelper.info('Offline queue processed');
    } catch (e) {
      AppLoggerHelper.error('Failed to process offline queue: $e');
      rethrow;
    }
  }

  Future<bool> checkConnectivity() async {
    return await _syncService.isOnline();
  }
}
