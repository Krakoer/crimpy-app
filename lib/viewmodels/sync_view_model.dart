import 'package:crimpy/database/database.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/sync_models.dart';
import 'package:crimpy/repositories/sync_repository.dart';
import 'package:crimpy/services/sync_service.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_view_model.g.dart';

@riverpod
SyncService syncService(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SyncService(apiClient);
}

@riverpod
SyncRepository syncRepository(Ref ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncRepository(syncService, gDatabase);
}

@riverpod
class SyncViewModel extends _$SyncViewModel {
  @override
  Future<SyncState> build() async {
    final metadata = await gDatabase.getSyncMetadata();
    return SyncState(
      lastSyncVersion: metadata?.lastSyncVersion ?? 0,
      lastSyncTime: metadata?.lastSyncTime,
      pendingChanges: metadata?.pendingChanges ?? 0,
    );
  }

  Future<void> performSync() async {
    await future;

    state = AsyncData(state.value!.copyWith(status: SyncStatus.syncing));

    try {
      final repository = ref.read(syncRepositoryProvider);
      await repository.performSync();

      _invalidateDataProviders();

      if (!ref.mounted) return;

      final metadata = await gDatabase.getSyncMetadata();
      state = AsyncData(
        SyncState(
          status: SyncStatus.success,
          lastSyncVersion: metadata?.lastSyncVersion ?? 0,
          lastSyncTime: metadata?.lastSyncTime,
          pendingChanges: 0,
        ),
      );

      AppLoggerHelper.info('Sync completed successfully');
    } catch (e, s) {
      AppLoggerHelper.error('Sync failed: $e ($s)');
      if (ref.mounted) {
        state = AsyncData(
          state.value!.copyWith(
            status: SyncStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> handleFirstLogin() async {
    await future;

    state = AsyncData(state.value!.copyWith(status: SyncStatus.syncing));

    try {
      final repository = ref.read(syncRepositoryProvider);
      await repository.handleFirstLogin();

      if (!ref.mounted) return;

      final metadata = await gDatabase.getSyncMetadata();
      state = AsyncData(
        SyncState(
          status: SyncStatus.success,
          lastSyncVersion: metadata?.lastSyncVersion ?? 0,
          lastSyncTime: metadata?.lastSyncTime,
          pendingChanges: 0,
        ),
      );

      AppLoggerHelper.info('First login sync completed successfully');
    } catch (e, s) {
      AppLoggerHelper.error('First login sync failed: $e, stacktrace: $s');
      if (ref.mounted) {
        state = AsyncData(
          state.value!.copyWith(
            status: SyncStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> incrementPendingChanges() async {
    await gDatabase.incrementPendingChanges();
    final metadata = await gDatabase.getSyncMetadata();
    state = AsyncData(
      state.value!.copyWith(pendingChanges: metadata?.pendingChanges ?? 0),
    );
  }

  void _invalidateDataProviders() {
    ref.invalidate(sessionsProvider);
    ref.invalidate(trainingsProvider);
    ref.invalidate(favTrainingsProvider);
    ref.invalidate(allTrainingsProvider);
    ref.invalidate(pinnedTrainingsProvider);
    ref.invalidate(assessmentsProvider);
    AppLoggerHelper.info('Data providers invalidated after sync');
  }
}
