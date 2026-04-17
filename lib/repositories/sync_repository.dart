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

    if (records.containsKey('repeaters')) {
      await _applyRepeaters(records['repeaters'] as List<dynamic>);
    }

    if (records.containsKey('trainings')) {
      await _applyTrainings(records['trainings'] as List<dynamic>);
    }

    if (records.containsKey('sessions')) {
      await _applySessions(records['sessions'] as List<dynamic>);
    }

    if (records.containsKey('rep_templates')) {
      await _applyRepTemplates(records['rep_templates'] as List<dynamic>);
    }

    if (records.containsKey('rep_datas')) {
      await _applyRepDatas(records['rep_datas'] as List<dynamic>);
    }

    if (records.containsKey('assessments')) {
      await _applyAssessments(records['assessments'] as List<dynamic>);
    }

    if (records.containsKey('sensor_configs')) {
      await _applySensorConfigs(records['sensor_configs'] as List<dynamic>);
    }

    if (records.containsKey('builtin_training_weights')) {
      await _applyBuiltinTrainingWeights(
        records['builtin_training_weights'] as List<dynamic>,
      );
    }

    if (records.containsKey('pinned_builtin_trainings')) {
      await _applyPinnedBuiltinTrainings(
        records['pinned_builtin_trainings'] as List<dynamic>,
      );
    }
  }

  Future<void> _applyRepeaters(List<dynamic> repeaters) async {
    for (final record in repeaters) {
      final remoteId = record['id'] as String;
      final deletedAt =
          record['deleted_at'] != null
              ? DateTime.parse(record['deleted_at'] as String)
              : null;

      final existing =
          await (_database.select(_database.repeaters)
            ..where((r) => r.remoteId.equals(remoteId))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database.delete(_database.repeaters).delete(existing);
        }
        continue;
      }

      final companion = RepeatersCompanion(
        sets: Value(record['sets'] as int),
        reps: Value(record['reps'] as int),
        worktime: Value(record['worktime'] as int),
        resttime: Value(record['resttime'] as int),
        setRest: Value(record['set_rest'] as int),
        targetWeigthRight: Value(record['target_weight_right'] as double?),
        targetWeigthLeft: Value(record['target_weight_left'] as double?),
        splitHand: Value(record['split_hand'] as bool),
        gripPosition: Value(record['grip_position'] as int),
        remoteId: Value(remoteId),
        updatedAt: Value(DateTime.parse(record['updated_at'] as String)),
        createdAt: Value(
          record['created_at'] != null
              ? DateTime.parse(record['created_at'] as String)
              : null,
        ),
        dirty: const Value(false),
      );

      if (existing != null) {
        await (_database.update(_database.repeaters)
          ..where((r) => r.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.repeaters).insert(companion);
      }
    }
    AppLoggerHelper.info('Applied ${repeaters.length} repeater records');
  }

  Future<void> _applyTrainings(List<dynamic> trainings) async {
    for (final record in trainings) {
      final remoteId = record['id'] as String;
      final deletedAt =
          record['deleted_at'] != null
              ? DateTime.parse(record['deleted_at'] as String)
              : null;

      final existing =
          await (_database.select(_database.trainings)
            ..where((t) => t.remoteId.equals(remoteId))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database.delete(_database.trainings).delete(existing);
        }
        continue;
      }

      int? repeaterId;
      if (record['repeater_id'] != null) {
        final repeaterRemoteId = record['repeater_id'] as String;
        final repeater =
            await (_database.select(_database.repeaters)..where(
              (r) => r.remoteId.equals(repeaterRemoteId),
            )).getSingleOrNull();
        repeaterId = repeater?.id;
      }

      final companion = TrainingsCompanion(
        name: Value(record['name'] as String),
        repeaterId: Value(repeaterId),
        isFavorite: Value(record['is_favorite'] as bool),
        isAssessment: Value(record['is_assessment'] as bool),
        isBuiltin: const Value(false),
        remoteId: Value(remoteId),
        updatedAt: Value(DateTime.parse(record['updated_at'] as String)),
        createdAt: Value(
          record['created_at'] != null
              ? DateTime.parse(record['created_at'] as String)
              : null,
        ),
        deletedAt: Value(deletedAt),
        dirty: const Value(false),
      );

      if (existing != null) {
        await (_database.update(_database.trainings)
          ..where((t) => t.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.trainings).insert(companion);
      }
    }
    AppLoggerHelper.info('Applied ${trainings.length} training records');
  }

  Future<void> _applySessions(List<dynamic> sessions) async {
    for (final record in sessions) {
      final remoteId = record['id'] as String;
      final deletedAt =
          record['deleted_at'] != null
              ? DateTime.parse(record['deleted_at'] as String)
              : null;

      final existing =
          await (_database.select(_database.sessions)
            ..where((s) => s.remoteId.equals(remoteId))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database.delete(_database.sessions).delete(existing);
        }
        continue;
      }

      final companion = SessionsCompanion(
        name: Value(record['name'] as String),
        notes: Value(record['notes'] as String? ?? ''),
        date: Value(DateTime.parse(record['date'] as String)),
        dataPath: Value(record['data_path'] as String? ?? ''),
        isAssessment: Value(record['is_assessment'] as bool),
        sessionType: Value(record['session_type'] as int),
        duration: Value(record['duration'] as int),
        repeaterSets: Value(record['repeater_sets'] as int?),
        repeaterReps: Value(record['repeater_reps'] as int?),
        repeaterWorkTime: Value(record['repeater_work_time'] as int?),
        repeaterRestTime: Value(record['repeater_rest_time'] as int?),
        repeaterSetRest: Value(record['repeater_set_rest'] as int?),
        repeaterSplitHand: Value(record['repeater_split_hand'] as bool?),
        remoteId: Value(remoteId),
        updatedAt: Value(DateTime.parse(record['updated_at'] as String)),
        createdAt: Value(
          record['created_at'] != null
              ? DateTime.parse(record['created_at'] as String)
              : null,
        ),
        deletedAt: Value(deletedAt),
        dirty: const Value(false),
      );

      if (existing != null) {
        await (_database.update(_database.sessions)
          ..where((s) => s.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.sessions).insert(companion);
      }
    }
    AppLoggerHelper.info('Applied ${sessions.length} session records');
  }

  Future<void> _applyRepTemplates(List<dynamic> repTemplates) async {
    for (final record in repTemplates) {
      final remoteId = record['id'] as String;
      final deletedAt =
          record['deleted_at'] != null
              ? DateTime.parse(record['deleted_at'] as String)
              : null;

      final existing =
          await (_database.select(_database.repTemplates)
            ..where((r) => r.remoteId.equals(remoteId))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database.delete(_database.repTemplates).delete(existing);
        }
        continue;
      }

      final trainingRemoteId = record['training_id'] as String;
      final training =
          await (_database.select(_database.trainings)..where(
            (t) => t.remoteId.equals(trainingRemoteId),
          )).getSingleOrNull();

      if (training == null) {
        AppLoggerHelper.warning(
          'Training not found for rep_template $remoteId, skipping',
        );
        continue;
      }

      final companion = RepTemplatesCompanion(
        isRest: Value(record['is_rest'] as bool),
        rightHand: Value(record['right_hand'] as bool),
        duration: Value(record['duration'] as int),
        trainingId: Value(training.id),
        targetWeight: Value(record['target_weight'] as double),
        index: Value(record['index'] as int),
        gripPosition: Value(record['grip_position'] as int),
        remoteId: Value(remoteId),
        updatedAt: Value(DateTime.parse(record['updated_at'] as String)),
        createdAt: Value(
          record['created_at'] != null
              ? DateTime.parse(record['created_at'] as String)
              : null,
        ),
        deletedAt: Value(deletedAt),
        dirty: const Value(false),
      );

      if (existing != null) {
        await (_database.update(_database.repTemplates)
          ..where((r) => r.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.repTemplates).insert(companion);
      }
    }
    AppLoggerHelper.info('Applied ${repTemplates.length} rep_template records');
  }

  Future<void> _applyRepDatas(List<dynamic> repDatas) async {
    for (final record in repDatas) {
      final remoteId = record['id'] as String;
      final deletedAt =
          record['deleted_at'] != null
              ? DateTime.parse(record['deleted_at'] as String)
              : null;

      final existing =
          await (_database.select(_database.repDatas)
            ..where((r) => r.remoteId.equals(remoteId))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database.delete(_database.repDatas).delete(existing);
        }
        continue;
      }

      final sessionRemoteId = record['session_id'] as String;
      final session =
          await (_database.select(_database.sessions)..where(
            (s) => s.remoteId.equals(sessionRemoteId),
          )).getSingleOrNull();

      if (session == null) {
        AppLoggerHelper.warning(
          'Session not found for rep_data $remoteId, skipping',
        );
        continue;
      }

      final companion = RepDatasCompanion(
        averageWeight: Value(record['average_weight'] as double),
        sessionId: Value(session.id),
        isRest: Value(record['is_rest'] as bool),
        rightHand: Value(record['right_hand'] as bool),
        duration: Value(record['duration'] as int),
        targetWeight: Value(record['target_weight'] as double),
        index: Value(record['index'] as int),
        gripPosition: Value(record['grip_position'] as int),
        remoteId: Value(remoteId),
        updatedAt: Value(DateTime.parse(record['updated_at'] as String)),
        createdAt: Value(
          record['created_at'] != null
              ? DateTime.parse(record['created_at'] as String)
              : null,
        ),
        deletedAt: Value(deletedAt),
        dirty: const Value(false),
      );

      if (existing != null) {
        await (_database.update(_database.repDatas)
          ..where((r) => r.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.repDatas).insert(companion);
      }
    }
    AppLoggerHelper.info('Applied ${repDatas.length} rep_data records');
  }

  Future<void> _applyAssessments(List<dynamic> assessments) async {
    for (final record in assessments) {
      final remoteId = record['id'] as String;
      final deletedAt =
          record['deleted_at'] != null
              ? DateTime.parse(record['deleted_at'] as String)
              : null;

      final existing =
          await (_database.select(_database.assessments)
            ..where((a) => a.remoteId.equals(remoteId))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database.delete(_database.assessments).delete(existing);
        }
        continue;
      }

      final sessionRemoteId = record['session_id'] as String;
      final session =
          await (_database.select(_database.sessions)..where(
            (s) => s.remoteId.equals(sessionRemoteId),
          )).getSingleOrNull();

      if (session == null) {
        AppLoggerHelper.warning(
          'Session not found for assessment $remoteId, skipping',
        );
        continue;
      }

      final companion = AssessmentsCompanion(
        type: Value(record['type'] as int),
        rightValue: Value(record['right_value'] as double?),
        leftValue: Value(record['left_value'] as double?),
        sessionId: Value(session.id),
        gripPosition: Value(record['grip_position'] as int?),
        remoteId: Value(remoteId),
        updatedAt: Value(DateTime.parse(record['updated_at'] as String)),
        createdAt: Value(
          record['created_at'] != null
              ? DateTime.parse(record['created_at'] as String)
              : null,
        ),
        deletedAt: Value(deletedAt),
        dirty: const Value(false),
      );

      if (existing != null) {
        await (_database.update(_database.assessments)
          ..where((a) => a.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.assessments).insert(companion);
      }
    }
    AppLoggerHelper.info('Applied ${assessments.length} assessment records');
  }

  Future<void> _applySensorConfigs(List<dynamic> sensorConfigs) async {
    for (final record in sensorConfigs) {
      final remoteId = record['id'] as String;
      final deletedAt =
          record['deleted_at'] != null
              ? DateTime.parse(record['deleted_at'] as String)
              : null;

      final existing =
          await (_database.select(_database.sensorConfigs)
            ..where((s) => s.remoteId.equals(remoteId))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database.delete(_database.sensorConfigs).delete(existing);
        }
        continue;
      }

      final companion = SensorConfigsCompanion(
        name: Value(record['name'] as String),
        index: Value(record['index'] as int),
        tare: Value(record['tare'] as double),
        coef: Value(record['coef'] as double),
        remoteId: Value(remoteId),
        updatedAt: Value(DateTime.parse(record['updated_at'] as String)),
        createdAt: Value(
          record['created_at'] != null
              ? DateTime.parse(record['created_at'] as String)
              : null,
        ),
        deletedAt: Value(deletedAt),
        dirty: const Value(false),
      );

      if (existing != null) {
        await (_database.update(_database.sensorConfigs)
          ..where((s) => s.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.sensorConfigs).insert(companion);
      }
    }
    AppLoggerHelper.info(
      'Applied ${sensorConfigs.length} sensor_config records',
    );
  }

  Future<void> _applyBuiltinTrainingWeights(
    List<dynamic> builtinTrainingWeights,
  ) async {
    for (final record in builtinTrainingWeights) {
      final remoteId = record['id'] as String;
      final deletedAt =
          record['deleted_at'] != null
              ? DateTime.parse(record['deleted_at'] as String)
              : null;

      final existing =
          await (_database.select(_database.builtinTrainingWeights)
            ..where((w) => w.remoteId.equals(remoteId))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database
              .delete(_database.builtinTrainingWeights)
              .delete(existing);
        }
        continue;
      }

      final builtinTrainingId = record['builtin_training_id'] as int;

      final companion = BuiltinTrainingWeightsCompanion(
        builtinTrainingId: Value(builtinTrainingId),
        customWeightRight: Value(record['custom_weight_right'] as double?),
        customWeightLeft: Value(record['custom_weight_left'] as double?),
        remoteId: Value(remoteId),
        updatedAt: Value(DateTime.parse(record['updated_at'] as String)),
        createdAt: Value(DateTime.parse(record['created_at'] as String)),
        deletedAt: Value(deletedAt),
        dirty: const Value(false),
      );

      if (existing != null) {
        await (_database.update(_database.builtinTrainingWeights)
          ..where((w) => w.id.equals(existing.id))).write(companion);
      } else {
        await _database
            .into(_database.builtinTrainingWeights)
            .insert(companion);
      }
    }
    AppLoggerHelper.info(
      'Applied ${builtinTrainingWeights.length} builtin_training_weight records',
    );
  }

  Future<void> _applyPinnedBuiltinTrainings(
    List<dynamic> pinnedBuiltinTrainings,
  ) async {
    for (final record in pinnedBuiltinTrainings) {
      final remoteId = record['id'] as String;
      final deletedAt =
          record['deleted_at'] != null
              ? DateTime.parse(record['deleted_at'] as String)
              : null;

      final existing =
          await (_database.select(_database.pinnedBuiltinTrainings)
            ..where((p) => p.remoteId.equals(remoteId))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database
              .delete(_database.pinnedBuiltinTrainings)
              .delete(existing);
        }
        continue;
      }

      final builtinTrainingId = record['builtin_training_id'] as int;

      final companion = PinnedBuiltinTrainingsCompanion(
        builtinTrainingId: Value(builtinTrainingId),
        remoteId: Value(remoteId),
        updatedAt: Value(DateTime.parse(record['updated_at'] as String)),
        createdAt: Value(
          record['created_at'] != null
              ? DateTime.parse(record['created_at'] as String)
              : null,
        ),
        deletedAt: Value(deletedAt),
        dirty: const Value(false),
      );

      if (existing != null) {
        await (_database.update(_database.pinnedBuiltinTrainings)..where(
          (p) => p.builtinTrainingId.equals(existing.builtinTrainingId),
        )).write(companion);
      } else {
        await _database
            .into(_database.pinnedBuiltinTrainings)
            .insert(companion);
      }
    }
    AppLoggerHelper.info(
      'Applied ${pinnedBuiltinTrainings.length} pinned_builtin_training records',
    );
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
