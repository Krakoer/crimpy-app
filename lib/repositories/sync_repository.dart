import 'package:crimpy/database/database.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/services/sync_service.dart';
import 'package:drift/drift.dart';

class SyncRepository {
  final SyncService _syncService;
  final AppDatabase _database;

  SyncRepository(this._syncService, this._database);

  Future<void> performSync() async {
    try {
      AppLoggerHelper.info('Starting sync process');

      final metadata = await _database.getSyncMetadata();
      final lastSyncVersion = metadata?.lastSyncVersion ?? 0;

      await _pushLocalChanges();

      await _pullRemoteChanges(lastSyncVersion);

      await _database.saveSyncMetadata(
        lastSyncVersion: lastSyncVersion,
        lastSyncTime: DateTime.now(),
      );
      await _database.resetPendingChanges();

      AppLoggerHelper.info('Sync completed successfully');
    } catch (e) {
      AppLoggerHelper.error('Sync failed: $e');
      rethrow;
    }
  }

  Future<void> handleFirstLogin() async {
    try {
      AppLoggerHelper.info('Handling first login sync');

      final summary = await _syncService.getSyncSummary();
      final totalRemoteRecords = summary.collections.values.fold(
        0,
        (a, b) => a + b,
      );

      if (totalRemoteRecords == 0) {
        AppLoggerHelper.info('Remote is empty, migrating local data');
        await _migrateLocalData();
      } else {
        AppLoggerHelper.info('Remote has data, pulling and replacing local');
        await _replaceLocalWithRemote();
      }

      await _database.saveSyncMetadata(
        lastSyncVersion: summary.lastSyncVersion,
        lastSyncTime: DateTime.now(),
      );
      await _database.resetPendingChanges();
    } catch (e) {
      AppLoggerHelper.error('First login sync failed: $e');
      rethrow;
    }
  }

  Future<void> _migrateLocalData() async {
    final records = await _collectAllLocalRecords();
    if (records.isEmpty) {
      AppLoggerHelper.info('No local data to migrate');
      return;
    }

    final response = await _syncService.migrateLocalData(records);
    AppLoggerHelper.info(
      'Migration complete: ${response.accepted.length} accepted, ${response.rejected.length} rejected',
    );

    if (response.rejected.isNotEmpty) {
      AppLoggerHelper.warning(
        'Some records were rejected: ${response.rejected}',
      );
    }

    await _clearDirtyFlags(response.rejected);
  }

  Future<void> _replaceLocalWithRemote() async {
    await _wipeLocalDatabase();

    final pullResponse = await _syncService.pullChanges(sinceVersion: 0);
    await _applyRemoteRecords(pullResponse.records);

    AppLoggerHelper.info('Local database replaced with remote data');
  }

  Future<void> _pushLocalChanges() async {
    final dirtyRecords = await _collectDirtyRecords();
    if (dirtyRecords.isEmpty) {
      AppLoggerHelper.info('No local changes to push');
      return;
    }

    final response = await _syncService.pushChanges(dirtyRecords);
    AppLoggerHelper.info(
      'Push complete: ${response.accepted.length} accepted, ${response.rejected.length} rejected',
    );

    if (response.rejected.isNotEmpty) {
      AppLoggerHelper.warning(
        'Some records were rejected: ${response.rejected}',
      );
    }

    await _clearDirtyFlags(response.rejected);
  }

  Future<void> _pullRemoteChanges(int sinceVersion) async {
    final pullResponse = await _syncService.pullChanges(
      sinceVersion: sinceVersion,
    );

    if ((pullResponse.records as Map).isEmpty) {
      AppLoggerHelper.info('No remote changes to pull');
      return;
    }

    await _applyRemoteRecords(pullResponse.records);
    AppLoggerHelper.info('Remote changes applied');
  }

  Future<Map<String, dynamic>> _collectAllLocalRecords() async {
    final Map<String, dynamic> collections = {};

    final sessions = await _database.getAllSessions();
    if (sessions.isNotEmpty) {
      collections['sessions'] =
          sessions
              .map(
                (s) => {
                  'id': s.remoteId,
                  'name': s.name,
                  'notes': s.notes,
                  'date': s.date.toIso8601String(),
                  'data_path': s.dataPath,
                  'is_assessment': s.isAssessment,
                  'session_type': s.sessionType,
                  'duration': s.duration,
                  'repeater_sets': s.repeaterSets,
                  'repeater_reps': s.repeaterReps,
                  'repeater_work_time': s.repeaterWorkTime,
                  'repeater_rest_time': s.repeaterRestTime,
                  'repeater_set_rest': s.repeaterSetRest,
                  'repeater_split_hand': s.repeaterSplitHand,
                  'updated_at': s.updatedAt.toIso8601String(),
                  'deleted_at': s.deletedAt?.toIso8601String(),
                  'created_at': s.createdAt?.toIso8601String(),
                },
              )
              .toList();
    }

    final trainings = await _database.getAllTrainingsWithoutAssessments();
    final customTrainings = trainings.where((t) => !t.isBuiltin).toList();
    if (customTrainings.isNotEmpty) {
      collections['trainings'] =
          customTrainings
              .map(
                (t) => {
                  'id': t.remoteId,
                  'name': t.name,
                  'repeater_id': t.repeaterId,
                  'is_favorite': t.isFavorite,
                  'is_assessment': t.isAssessment,
                  'updated_at': t.updatedAt.toIso8601String(),
                  'deleted_at': t.deletedAt?.toIso8601String(),
                  'created_at': t.createdAt?.toIso8601String(),
                },
              )
              .toList();
    }

    return collections;
  }

  Future<Map<String, dynamic>> _collectDirtyRecords() async {
    final Map<String, dynamic> collections = {};

    final sessions =
        await (_database.select(_database.sessions)
          ..where((s) => s.dirty.equals(true))).get();
    if (sessions.isNotEmpty) {
      collections['sessions'] =
          sessions
              .map(
                (s) => {
                  'id': s.remoteId,
                  'name': s.name,
                  'notes': s.notes,
                  'date': s.date.toIso8601String(),
                  'data_path': s.dataPath,
                  'is_assessment': s.isAssessment,
                  'session_type': s.sessionType,
                  'duration': s.duration,
                  'repeater_sets': s.repeaterSets,
                  'repeater_reps': s.repeaterReps,
                  'repeater_work_time': s.repeaterWorkTime,
                  'repeater_rest_time': s.repeaterRestTime,
                  'repeater_set_rest': s.repeaterSetRest,
                  'repeater_split_hand': s.repeaterSplitHand,
                  'updated_at': s.updatedAt.toIso8601String(),
                  'deleted_at': s.deletedAt?.toIso8601String(),
                  'created_at': s.createdAt?.toIso8601String(),
                },
              )
              .toList();
    }

    final trainings =
        await (_database.select(_database.trainings)..where(
          (t) => t.dirty.equals(true) & t.isBuiltin.equals(false),
        )).get();
    if (trainings.isNotEmpty) {
      collections['trainings'] =
          trainings
              .map(
                (t) => {
                  'id': t.remoteId,
                  'name': t.name,
                  'repeater_id': t.repeaterId,
                  'is_favorite': t.isFavorite,
                  'is_assessment': t.isAssessment,
                  'updated_at': t.updatedAt.toIso8601String(),
                  'deleted_at': t.deletedAt?.toIso8601String(),
                  'created_at': t.createdAt?.toIso8601String(),
                },
              )
              .toList();
    }

    return collections;
  }

  Future<void> _applyRemoteRecords(Map<String, dynamic> records) async {
    AppLoggerHelper.info('Applying remote records: ${records.keys}');

    if (records.containsKey('sessions')) {
      final sessions = records['sessions'] as List<dynamic>;
      for (final _ in sessions) {
        AppLoggerHelper.info('TODO: Apply session record');
      }
    }

    if (records.containsKey('trainings')) {
      final trainings = records['trainings'] as List<dynamic>;
      for (final _ in trainings) {
        AppLoggerHelper.info('TODO: Apply training record');
      }
    }
  }

  Future<void> _clearDirtyFlags(List<String> rejected) async {
    await (_database.update(_database.sessions)..where(
      (s) => s.dirty.equals(true) & s.remoteId.isNotIn(rejected),
    )).write(SessionsCompanion(dirty: const Value(false)));

    await (_database.update(_database.trainings)..where(
      (t) => t.dirty.equals(true) & t.remoteId.isNotIn(rejected),
    )).write(TrainingsCompanion(dirty: const Value(false)));

    await (_database.update(_database.assessments)..where(
      (a) => a.dirty.equals(true) & a.remoteId.isNotIn(rejected),
    )).write(AssessmentsCompanion(dirty: const Value(false)));

    await (_database.update(_database.repeaters)..where(
      (r) => r.dirty.equals(true) & r.remoteId.isNotIn(rejected),
    )).write(RepeatersCompanion(dirty: const Value(false)));

    await (_database.update(_database.repTemplates)..where(
      (r) => r.dirty.equals(true) & r.remoteId.isNotIn(rejected),
    )).write(RepTemplatesCompanion(dirty: const Value(false)));

    await (_database.update(_database.repDatas)..where(
      (r) => r.dirty.equals(true) & r.remoteId.isNotIn(rejected),
    )).write(RepDatasCompanion(dirty: const Value(false)));

    await (_database.update(_database.sensorConfigs)..where(
      (s) => s.dirty.equals(true) & s.remoteId.isNotIn(rejected),
    )).write(SensorConfigsCompanion(dirty: const Value(false)));

    await (_database.update(_database.builtinTrainingWeights)..where(
      (w) => w.dirty.equals(true) & w.remoteId.isNotIn(rejected),
    )).write(BuiltinTrainingWeightsCompanion(dirty: const Value(false)));

    await (_database.update(_database.pinnedBuiltinTrainings)..where(
      (p) => p.dirty.equals(true) & p.remoteId.isNotIn(rejected),
    )).write(PinnedBuiltinTrainingsCompanion(dirty: const Value(false)));
  }

  Future<void> _wipeLocalDatabase() async {
    AppLoggerHelper.info('Wiping local database');

    await _database.delete(_database.assessments).go();
    await _database.delete(_database.repDatas).go();
    await _database.delete(_database.sessions).go();

    await _database.delete(_database.repTemplates).go();
    await (_database.delete(_database.trainings)
      ..where((t) => t.isBuiltin.equals(false))).go();
    await _database.delete(_database.repeaters).go();
    await _database.delete(_database.sensorConfigs).go();
    await _database.delete(_database.builtinTrainingWeights).go();
    await _database.delete(_database.pinnedBuiltinTrainings).go();

    AppLoggerHelper.info('Local database wiped (builtins preserved)');
  }

  Future<int> getPendingChangesCount() async {
    final metadata = await _database.getSyncMetadata();
    return metadata?.pendingChanges ?? 0;
  }

  Future<void> wipeLocalDatabase() async {
    await _wipeLocalDatabase();
    await _database.delete(_database.syncMetadata).go();
  }
}
