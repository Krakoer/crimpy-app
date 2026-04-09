import 'dart:convert';
import 'package:crimpy/database/database.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/sync/api_models.dart';
import 'package:crimpy/services/api/session_api_service.dart';
import 'package:crimpy/services/api/training_api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  final AppDatabase _database;
  final SessionApiService _sessionApi;
  final TrainingApiService _trainingApi;
  final Connectivity _connectivity;

  SyncService(
    this._database,
    this._sessionApi,
    this._trainingApi,
    this._connectivity,
  );

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> syncAll() async {
    if (!await isOnline()) {
      throw Exception('No internet connection');
    }

    try {
      await pushChanges();
      await pullChanges();
    } catch (e) {
      AppLoggerHelper.error('Sync failed: $e');
      rethrow;
    }
  }

  Future<void> pushChanges() async {
    final entitiesToPush = await _database.getEntitiesNeedingUpload();

    for (final entity in entitiesToPush) {
      try {
        await _pushEntity(entity);
      } catch (e) {
        AppLoggerHelper.error(
          'Failed to push ${entity.entityTable} ${entity.localId}: $e',
        );
        await _database.enqueueOfflineOperation(
          operation: 'push',
          payload: {
            'table': entity.entityTable,
            'local_id': entity.localId,
            'operation': entity.pendingOperation,
          },
        );
      }
    }
  }

  Future<void> _pushEntity(SyncMetadataData entity) async {
    if (entity.pendingOperation == null) return;

    switch (entity.entityTable) {
      case 'sessions':
        await _pushSession(entity);
        break;
      case 'trainings':
        await _pushTraining(entity);
        break;
      default:
        AppLoggerHelper.warning('Unknown entity type: ${entity.entityTable}');
    }
  }

  Future<void> _pushSession(SyncMetadataData entity) async {
    final session = await _database.getSessionWithData(entity.localId);
    if (session == null) return;

    final request = CreateSessionRequest(
      name: session.name,
      notes: session.notes ?? '',
      duration: session.durationInSeconds ?? 0,
      isAssessment: session.isAssessment,
      sessionType: session.sessionType.index,
      repeaterSets: session.repeaterConfig?.sets,
      repeaterReps: session.repeaterConfig?.repsPerSet,
      repeaterWorkTime: session.repeaterConfig?.workTime,
      repeaterRestTime: session.repeaterConfig?.restTime,
      repeaterSetRest: session.repeaterConfig?.setRest,
      repeaterSplitHand: session.repeaterConfig?.splitHand,
    );

    if (entity.pendingOperation == 'create') {
      final response = await _sessionApi.createSession(request);
      await _database.upsertSyncMetadata(
        tableName: 'sessions',
        localId: entity.localId,
        remoteId: response.id,
        lastSyncedAt: DateTime.now(),
        needsUpload: false,
      );
    } else if (entity.pendingOperation == 'update' && entity.remoteId != null) {
      final updateRequest = UpdateSessionRequest(
        name: session.name,
        notes: session.notes,
        duration: session.durationInSeconds,
      );
      await _sessionApi.updateSession(entity.remoteId!, updateRequest);
      await _database.upsertSyncMetadata(
        tableName: 'sessions',
        localId: entity.localId,
        remoteId: entity.remoteId,
        lastSyncedAt: DateTime.now(),
        needsUpload: false,
      );
    } else if (entity.pendingOperation == 'delete' && entity.remoteId != null) {
      await _sessionApi.deleteSession(entity.remoteId!);
      await _database.upsertSyncMetadata(
        tableName: 'sessions',
        localId: entity.localId,
        remoteId: entity.remoteId,
        lastSyncedAt: DateTime.now(),
        needsUpload: false,
      );
    }
  }

  Future<void> _pushTraining(SyncMetadataData entity) async {
    final trainingQuery =
        await (_database.select(_database.trainings)
          ..where((t) => t.id.equals(entity.localId))).getSingleOrNull();
    if (trainingQuery == null) return;

    final request = CreateTrainingRequest(
      name: trainingQuery.name,
      isAssessment: trainingQuery.isAssessment,
      isFavorite: trainingQuery.isFavorite,
      repeaterId: trainingQuery.repeaterId,
    );

    if (entity.pendingOperation == 'create') {
      final response = await _trainingApi.createTraining(request);
      await _database.upsertSyncMetadata(
        tableName: 'trainings',
        localId: entity.localId,
        remoteId: response.id,
        lastSyncedAt: DateTime.now(),
        needsUpload: false,
      );
    } else if (entity.pendingOperation == 'update' && entity.remoteId != null) {
      final updateRequest = UpdateTrainingRequest(
        name: trainingQuery.name,
        isFavorite: trainingQuery.isFavorite,
      );
      await _trainingApi.updateTraining(entity.remoteId!, updateRequest);
      await _database.upsertSyncMetadata(
        tableName: 'trainings',
        localId: entity.localId,
        remoteId: entity.remoteId,
        lastSyncedAt: DateTime.now(),
        needsUpload: false,
      );
    } else if (entity.pendingOperation == 'delete' && entity.remoteId != null) {
      await _trainingApi.deleteTraining(entity.remoteId!);
      await _database.upsertSyncMetadata(
        tableName: 'trainings',
        localId: entity.localId,
        remoteId: entity.remoteId,
        lastSyncedAt: DateTime.now(),
        needsUpload: false,
      );
    }
  }

  Future<void> pullChanges() async {
    try {
      await _pullSessions();
      await _pullTrainings();
    } catch (e) {
      AppLoggerHelper.error('Failed to pull changes: $e');
      rethrow;
    }
  }

  Future<void> _pullSessions() async {
    final remoteSessions = await _sessionApi.getAllSessions();

    for (final remote in remoteSessions) {
      final existing = await _database.getSyncMetadata('sessions', remote.id);

      if (existing == null || existing.lastSyncedAt == null) {
        AppLoggerHelper.info('New remote session found: ${remote.id}');
      }
    }
  }

  Future<void> _pullTrainings() async {
    final remoteTrainings = await _trainingApi.getAllTrainings();

    for (final remote in remoteTrainings) {
      final existing = await _database.getSyncMetadata('trainings', remote.id);

      if (existing == null || existing.lastSyncedAt == null) {
        AppLoggerHelper.info('New remote training found: ${remote.id}');
      }
    }
  }

  Future<void> retryOfflineQueue() async {
    if (!await isOnline()) {
      return;
    }

    final queue = await _database.getQueuedOperations();

    for (final item in queue) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        final tableName = payload['table'] as String;
        final localId = payload['local_id'] as int;

        final entity = await _database.getSyncMetadata(tableName, localId);
        if (entity != null) {
          await _pushEntity(entity);
        }

        await _database.dequeueOperation(item.id);
      } catch (e) {
        AppLoggerHelper.error(
          'Failed to retry queued operation ${item.id}: $e',
        );
        await _database.incrementRetryCount(item.id);

        if (item.retryCount >= 3) {
          AppLoggerHelper.warning(
            'Max retries reached for operation ${item.id}',
          );
        }
      }
    }
  }
}
