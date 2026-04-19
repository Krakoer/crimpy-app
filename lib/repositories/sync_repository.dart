import 'package:crimpy/database/database.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/services/sync_service.dart';
import 'package:drift/drift.dart';

class SyncRepository {
  final SyncService _syncService;
  final AppDatabase _database;

  SyncRepository(this._syncService, this._database);

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> performSync() async {
    try {
      AppLoggerHelper.info('Starting sync process');

      final metadata = await _database.getSyncMetadata();
      final lastSyncVersion = metadata?.lastSyncVersion ?? 0;

      await _pushLocalChanges();

      final newServerVersion = await _pullRemoteChanges(lastSyncVersion);

      await _database.saveSyncMetadata(
        lastSyncVersion: newServerVersion,
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

  Future<int> _pullRemoteChanges(int sinceVersion) async {
    final pullResponse = await _syncService.pullChanges(
      sinceVersion: sinceVersion,
    );

    if ((pullResponse.records as Map).isEmpty) {
      AppLoggerHelper.info('No remote changes to pull');
      return pullResponse.serverVersion;
    }

    await _applyRemoteRecords(pullResponse.records);
    AppLoggerHelper.info('Remote changes applied');
    return pullResponse.serverVersion;
  }

  Future<Map<String, dynamic>> _collectAllLocalRecords() async {
    final Map<String, dynamic> collections = {};

    final repeaters = await _database.select(_database.repeaters).get();
    if (repeaters.isNotEmpty) {
      collections['repeaters'] = repeaters
          .map(
            (r) => {
              'id': r.id,
              'sets': r.sets,
              'reps': r.reps,
              'worktime': r.worktime,
              'resttime': r.resttime,
              'set_rest': r.setRest,
              'target_weight_right': r.targetWeigthRight,
              'target_weight_left': r.targetWeigthLeft,
              'split_hand': r.splitHand,
              'grip_position': r.gripPosition,
              'updated_at': r.updatedAt.toUtc().toIso8601String(),
              'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
              'created_at': r.createdAt?.toUtc().toIso8601String(),
            },
          )
          .toList();
    }

    final trainings = await _database.getAllTrainingsWithoutAssessments();
    final customTrainings = trainings.where((t) => !t.isBuiltin).toList();
    if (customTrainings.isNotEmpty) {
      final trainingMaps = <Map<String, dynamic>>[];
      for (final t in customTrainings) {
        String? repeaterId;
        if (t.repeaterId != null) {
          final repeater = await (_database.select(
            _database.repeaters,
          )..where((r) => r.id.equals(t.repeaterId!))).getSingleOrNull();
          repeaterId = repeater?.id;
        }
        trainingMaps.add({
          'id': t.id,
          'name': t.name,
          'repeater_id': repeaterId,
          'is_favorite': t.isFavorite,
          'is_assessment': t.isAssessment,
          'updated_at': t.updatedAt.toUtc().toIso8601String(),
          'deleted_at': t.deletedAt?.toUtc().toIso8601String(),
          'created_at': t.createdAt?.toUtc().toIso8601String(),
        });
      }
      collections['trainings'] = trainingMaps;
    }

    final sessions = await _database.getAllSessions();
    if (sessions.isNotEmpty) {
      collections['sessions'] = sessions
          .map(
            (s) => {
              'id': s.id,
              'name': s.name,
              'notes': s.notes,
              'date': s.date.toUtc().toIso8601String(),
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
              'updated_at': s.updatedAt.toUtc().toIso8601String(),
              'deleted_at': s.deletedAt?.toUtc().toIso8601String(),
              'created_at': s.createdAt?.toUtc().toIso8601String(),
            },
          )
          .toList();
    }

    final repTemplates = await _database.select(_database.repTemplates).get();
    if (repTemplates.isNotEmpty) {
      final repTemplateMaps = <Map<String, dynamic>>[];
      for (final r in repTemplates) {
        final training = await (_database.select(
          _database.trainings,
        )..where((t) => t.id.equals(r.trainingId))).getSingleOrNull();
        if (training != null && !training.isBuiltin) {
          repTemplateMaps.add({
            'id': r.id,
            'training_id': training.id,
            'is_rest': r.isRest,
            'right_hand': r.rightHand,
            'duration': r.duration,
            'target_weight': r.targetWeight,
            'index': r.index,
            'grip_position': r.gripPosition,
            'updated_at': r.updatedAt.toUtc().toIso8601String(),
            'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
            'created_at': r.createdAt?.toUtc().toIso8601String(),
          });
        }
      }
      if (repTemplateMaps.isNotEmpty) {
        collections['rep_templates'] = repTemplateMaps;
      }
    }

    final repDatas = await _database.select(_database.repDatas).get();
    if (repDatas.isNotEmpty) {
      final repDataMaps = <Map<String, dynamic>>[];
      for (final r in repDatas) {
        final session = await (_database.select(
          _database.sessions,
        )..where((s) => s.id.equals(r.sessionId))).getSingleOrNull();
        if (session != null) {
          repDataMaps.add({
            'id': r.id,
            'session_id': session.id,
            'average_weight': r.averageWeight,
            'is_rest': r.isRest,
            'right_hand': r.rightHand,
            'duration': r.duration,
            'target_weight': r.targetWeight,
            'index': r.index,
            'grip_position': r.gripPosition,
            'updated_at': r.updatedAt.toUtc().toIso8601String(),
            'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
            'created_at': r.createdAt?.toUtc().toIso8601String(),
          });
        }
      }
      if (repDataMaps.isNotEmpty) {
        collections['rep_datas'] = repDataMaps;
      }
    }

    final assessments = await _database.select(_database.assessments).get();
    if (assessments.isNotEmpty) {
      final assessmentMaps = <Map<String, dynamic>>[];
      for (final a in assessments) {
        final session = await (_database.select(
          _database.sessions,
        )..where((s) => s.id.equals(a.sessionId))).getSingleOrNull();
        if (session != null) {
          assessmentMaps.add({
            'id': a.id,
            'session_id': session.id,
            'type': a.type,
            'right_value': a.rightValue,
            'left_value': a.leftValue,
            'grip_position': a.gripPosition,
            'updated_at': a.updatedAt.toUtc().toIso8601String(),
            'deleted_at': a.deletedAt?.toUtc().toIso8601String(),
            'created_at': a.createdAt?.toUtc().toIso8601String(),
          });
        }
      }
      if (assessmentMaps.isNotEmpty) {
        collections['assessments'] = assessmentMaps;
      }
    }

    final sensorConfigs = await _database.select(_database.sensorConfigs).get();
    if (sensorConfigs.isNotEmpty) {
      collections['sensor_configs'] = sensorConfigs
          .map(
            (s) => {
              'id': s.id,
              'name': s.name,
              'index': s.index,
              'tare': s.tare,
              'coef': s.coef,
              'updated_at': s.updatedAt.toUtc().toIso8601String(),
              'deleted_at': s.deletedAt?.toUtc().toIso8601String(),
              'created_at': s.createdAt?.toUtc().toIso8601String(),
            },
          )
          .toList();
    }

    final builtinTrainingWeights = await _database
        .select(_database.builtinTrainingWeights)
        .get();
    if (builtinTrainingWeights.isNotEmpty) {
      collections['builtin_training_weights'] = builtinTrainingWeights
          .map(
            (w) => {
              'id': w.id,
              'builtin_training_id': w.builtinTrainingId,
              'custom_weight_right': w.customWeightRight,
              'custom_weight_left': w.customWeightLeft,
              'updated_at': w.updatedAt.toUtc().toIso8601String(),
              'deleted_at': w.deletedAt?.toUtc().toIso8601String(),
              'created_at': w.createdAt.toUtc().toIso8601String(),
            },
          )
          .toList();
    }

    final pinnedBuiltinTrainings = await _database
        .select(_database.pinnedBuiltinTrainings)
        .get();
    if (pinnedBuiltinTrainings.isNotEmpty) {
      collections['pinned_builtin_trainings'] = pinnedBuiltinTrainings
          .map((p) => {'builtin_training_id': p.builtinTrainingId})
          .toList();
    }

    return collections;
  }

  Future<Map<String, dynamic>> _collectDirtyRecords() async {
    final Map<String, dynamic> collections = {};

    final repeaters = await (_database.select(
      _database.repeaters,
    )..where((r) => r.dirty.equals(true))).get();
    if (repeaters.isNotEmpty) {
      collections['repeaters'] = repeaters
          .map(
            (r) => {
              'id': r.id,
              'sets': r.sets,
              'reps': r.reps,
              'worktime': r.worktime,
              'resttime': r.resttime,
              'set_rest': r.setRest,
              'target_weight_right': r.targetWeigthRight,
              'target_weight_left': r.targetWeigthLeft,
              'split_hand': r.splitHand,
              'grip_position': r.gripPosition,
              'updated_at': r.updatedAt.toUtc().toIso8601String(),
              'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
              'created_at': r.createdAt?.toUtc().toIso8601String(),
            },
          )
          .toList();
    }

    final trainings = await (_database.select(
      _database.trainings,
    )..where((t) => t.dirty.equals(true) & t.isBuiltin.equals(false))).get();
    if (trainings.isNotEmpty) {
      final trainingMaps = <Map<String, dynamic>>[];
      for (final t in trainings) {
        String? repeaterId;
        if (t.repeaterId != null) {
          final repeater = await (_database.select(
            _database.repeaters,
          )..where((r) => r.id.equals(t.repeaterId!))).getSingleOrNull();
          repeaterId = repeater?.id;
        }
        trainingMaps.add({
          'id': t.id,
          'name': t.name,
          'repeater_id': repeaterId,
          'is_favorite': t.isFavorite,
          'is_assessment': t.isAssessment,
          'updated_at': t.updatedAt.toUtc().toIso8601String(),
          'deleted_at': t.deletedAt?.toUtc().toIso8601String(),
          'created_at': t.createdAt?.toUtc().toIso8601String(),
        });
      }
      collections['trainings'] = trainingMaps;
    }

    final sessions = await (_database.select(
      _database.sessions,
    )..where((s) => s.dirty.equals(true))).get();
    if (sessions.isNotEmpty) {
      collections['sessions'] = sessions
          .map(
            (s) => {
              'id': s.id,
              'name': s.name,
              'notes': s.notes,
              'date': s.date.toUtc().toIso8601String(),
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
              'updated_at': s.updatedAt.toUtc().toIso8601String(),
              'deleted_at': s.deletedAt?.toUtc().toIso8601String(),
              'created_at': s.createdAt?.toUtc().toIso8601String(),
            },
          )
          .toList();
    }

    final repTemplates = await (_database.select(
      _database.repTemplates,
    )..where((r) => r.dirty.equals(true))).get();
    if (repTemplates.isNotEmpty) {
      final repTemplateMaps = <Map<String, dynamic>>[];
      for (final r in repTemplates) {
        final training = await (_database.select(
          _database.trainings,
        )..where((t) => t.id.equals(r.trainingId))).getSingleOrNull();
        if (training != null) {
          repTemplateMaps.add({
            'id': r.id,
            'training_id': training.id,
            'is_rest': r.isRest,
            'right_hand': r.rightHand,
            'duration': r.duration,
            'target_weight': r.targetWeight,
            'index': r.index,
            'grip_position': r.gripPosition,
            'updated_at': r.updatedAt.toUtc().toIso8601String(),
            'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
            'created_at': r.createdAt?.toUtc().toIso8601String(),
          });
        }
      }
      if (repTemplateMaps.isNotEmpty) {
        collections['rep_templates'] = repTemplateMaps;
      }
    }

    final repDatas = await (_database.select(
      _database.repDatas,
    )..where((r) => r.dirty.equals(true))).get();
    if (repDatas.isNotEmpty) {
      final repDataMaps = <Map<String, dynamic>>[];
      for (final r in repDatas) {
        final session = await (_database.select(
          _database.sessions,
        )..where((s) => s.id.equals(r.sessionId))).getSingleOrNull();
        if (session != null) {
          repDataMaps.add({
            'id': r.id,
            'session_id': session.id,
            'average_weight': r.averageWeight,
            'is_rest': r.isRest,
            'right_hand': r.rightHand,
            'duration': r.duration,
            'target_weight': r.targetWeight,
            'index': r.index,
            'grip_position': r.gripPosition,
            'updated_at': r.updatedAt.toUtc().toIso8601String(),
            'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
            'created_at': r.createdAt?.toUtc().toIso8601String(),
          });
        }
      }
      if (repDataMaps.isNotEmpty) {
        collections['rep_datas'] = repDataMaps;
      }
    }

    final assessments = await (_database.select(
      _database.assessments,
    )..where((a) => a.dirty.equals(true))).get();
    if (assessments.isNotEmpty) {
      final assessmentMaps = <Map<String, dynamic>>[];
      for (final a in assessments) {
        final session = await (_database.select(
          _database.sessions,
        )..where((s) => s.id.equals(a.sessionId))).getSingleOrNull();
        if (session != null) {
          assessmentMaps.add({
            'id': a.id,
            'session_id': session.id,
            'type': a.type,
            'right_value': a.rightValue,
            'left_value': a.leftValue,
            'grip_position': a.gripPosition,
            'updated_at': a.updatedAt.toUtc().toIso8601String(),
            'deleted_at': a.deletedAt?.toUtc().toIso8601String(),
            'created_at': a.createdAt?.toUtc().toIso8601String(),
          });
        }
      }
      if (assessmentMaps.isNotEmpty) {
        collections['assessments'] = assessmentMaps;
      }
    }

    final sensorConfigs = await (_database.select(
      _database.sensorConfigs,
    )..where((s) => s.dirty.equals(true))).get();
    if (sensorConfigs.isNotEmpty) {
      collections['sensor_configs'] = sensorConfigs
          .map(
            (s) => {
              'id': s.id,
              'name': s.name,
              'index': s.index,
              'tare': s.tare,
              'coef': s.coef,
              'updated_at': s.updatedAt.toUtc().toIso8601String(),
              'deleted_at': s.deletedAt?.toUtc().toIso8601String(),
              'created_at': s.createdAt?.toUtc().toIso8601String(),
            },
          )
          .toList();
    }

    final builtinTrainingWeights = await (_database.select(
      _database.builtinTrainingWeights,
    )..where((w) => w.dirty.equals(true))).get();
    if (builtinTrainingWeights.isNotEmpty) {
      collections['builtin_training_weights'] = builtinTrainingWeights
          .map(
            (w) => {
              'id': w.id,
              'builtin_training_id': w.builtinTrainingId,
              'custom_weight_right': w.customWeightRight,
              'custom_weight_left': w.customWeightLeft,
              'updated_at': w.updatedAt.toUtc().toIso8601String(),
              'deleted_at': w.deletedAt?.toUtc().toIso8601String(),
              'created_at': w.createdAt.toUtc().toIso8601String(),
            },
          )
          .toList();
    }

    final pinnedBuiltinTrainings = await (_database.select(
      _database.pinnedBuiltinTrainings,
    )..where((p) => p.dirty.equals(true))).get();
    if (pinnedBuiltinTrainings.isNotEmpty) {
      collections['pinned_builtin_trainings'] = pinnedBuiltinTrainings
          .map((p) => {'builtin_training_id': p.builtinTrainingId})
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
      final id = record['id'] as String;
      final deletedAt = record['deleted_at'] != null
          ? DateTime.parse(record['deleted_at'] as String)
          : null;

      final existing = await (_database.select(
        _database.repeaters,
      )..where((r) => r.id.equals(id))).getSingleOrNull();

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
        targetWeigthRight: Value(_toDouble(record['target_weight_right'])),
        targetWeigthLeft: Value(_toDouble(record['target_weight_left'])),
        splitHand: Value(record['split_hand'] as bool),
        gripPosition: Value(record['grip_position'] as int),
        id: Value(id),
        updatedAt: Value(DateTime.parse(record['updated_at'] as String)),
        createdAt: Value(
          record['created_at'] != null
              ? DateTime.parse(record['created_at'] as String)
              : null,
        ),
        dirty: const Value(false),
      );

      if (existing != null) {
        await (_database.update(
          _database.repeaters,
        )..where((r) => r.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.repeaters).insert(companion);
      }
    }
    AppLoggerHelper.info('Applied ${repeaters.length} repeater records');
  }

  Future<void> _applyTrainings(List<dynamic> trainings) async {
    for (final record in trainings) {
      final id = record['id'] as String;
      final deletedAt = record['deleted_at'] != null
          ? DateTime.parse(record['deleted_at'] as String)
          : null;

      final existing = await (_database.select(
        _database.trainings,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database.delete(_database.trainings).delete(existing);
        }
        continue;
      }

      String? repeaterId = record['repeater_id'];

      final companion = TrainingsCompanion(
        name: Value(record['name'] as String),
        repeaterId: Value(repeaterId),
        isFavorite: Value(record['is_favorite'] as bool),
        isAssessment: Value(record['is_assessment'] as bool),
        isBuiltin: const Value(false),
        id: Value(id),
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
        await (_database.update(
          _database.trainings,
        )..where((t) => t.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.trainings).insert(companion);
      }
    }
    AppLoggerHelper.info('Applied ${trainings.length} training records');
  }

  Future<void> _applySessions(List<dynamic> sessions) async {
    for (final record in sessions) {
      final id = record['id'] as String;
      final deletedAt = record['deleted_at'] != null
          ? DateTime.parse(record['deleted_at'] as String)
          : null;

      final existing = await (_database.select(
        _database.sessions,
      )..where((s) => s.id.equals(id))).getSingleOrNull();

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
        id: Value(id),
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
        await (_database.update(
          _database.sessions,
        )..where((s) => s.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.sessions).insert(companion);
      }
    }
    AppLoggerHelper.info('Applied ${sessions.length} session records');
  }

  Future<void> _applyRepTemplates(List<dynamic> repTemplates) async {
    for (final record in repTemplates) {
      final id = record['id'] as String;
      final deletedAt = record['deleted_at'] != null
          ? DateTime.parse(record['deleted_at'] as String)
          : null;

      final existing = await (_database.select(
        _database.repTemplates,
      )..where((r) => r.id.equals(id))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database.delete(_database.repTemplates).delete(existing);
        }
        continue;
      }

      final trainingId = record['training_id'] as String;
      final training = await (_database.select(
        _database.trainings,
      )..where((t) => t.id.equals(trainingId))).getSingleOrNull();

      if (training == null) {
        AppLoggerHelper.warning(
          'Training not found for rep_template $id, skipping',
        );
        continue;
      }

      final companion = RepTemplatesCompanion(
        isRest: Value(record['is_rest'] as bool),
        rightHand: Value(record['right_hand'] as bool),
        duration: Value(record['duration'] as int),
        trainingId: Value(training.id),
        targetWeight: Value(_toDouble(record['target_weight'])!),
        index: Value(record['index'] as int),
        gripPosition: Value(record['grip_position'] as int),
        id: Value(id),
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
        await (_database.update(
          _database.repTemplates,
        )..where((r) => r.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.repTemplates).insert(companion);
      }
    }
    AppLoggerHelper.info('Applied ${repTemplates.length} rep_template records');
  }

  Future<void> _applyRepDatas(List<dynamic> repDatas) async {
    for (final record in repDatas) {
      final id = record['id'] as String;
      final deletedAt = record['deleted_at'] != null
          ? DateTime.parse(record['deleted_at'] as String)
          : null;

      final existing = await (_database.select(
        _database.repDatas,
      )..where((r) => r.id.equals(id))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database.delete(_database.repDatas).delete(existing);
        }
        continue;
      }

      final sessionId = record['session_id'] as String;
      final session = await (_database.select(
        _database.sessions,
      )..where((s) => s.id.equals(sessionId))).getSingleOrNull();

      if (session == null) {
        AppLoggerHelper.warning('Session not found for rep_data $id, skipping');
        continue;
      }

      final companion = RepDatasCompanion(
        averageWeight: Value(_toDouble(record['average_weight'])!),
        sessionId: Value(session.id),
        isRest: Value(record['is_rest'] as bool),
        rightHand: Value(record['right_hand'] as bool),
        duration: Value(record['duration'] as int),
        targetWeight: Value(_toDouble(record['target_weight'])!),
        index: Value(record['index'] as int),
        gripPosition: Value(record['grip_position'] as int),
        id: Value(id),
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
        await (_database.update(
          _database.repDatas,
        )..where((r) => r.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.repDatas).insert(companion);
      }
    }
    AppLoggerHelper.info('Applied ${repDatas.length} rep_data records');
  }

  Future<void> _applyAssessments(List<dynamic> assessments) async {
    for (final record in assessments) {
      final id = record['id'] as String;
      final deletedAt = record['deleted_at'] != null
          ? DateTime.parse(record['deleted_at'] as String)
          : null;

      final existing = await (_database.select(
        _database.assessments,
      )..where((a) => a.id.equals(id))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database.delete(_database.assessments).delete(existing);
        }
        continue;
      }

      final sessionId = record['session_id'] as String;
      final session = await (_database.select(
        _database.sessions,
      )..where((s) => s.id.equals(sessionId))).getSingleOrNull();

      if (session == null) {
        AppLoggerHelper.warning(
          'Session not found for assessment $id, skipping',
        );
        continue;
      }

      final companion = AssessmentsCompanion(
        type: Value(record['type'] as int),
        rightValue: Value(_toDouble(record['right_value'])),
        leftValue: Value(_toDouble(record['left_value'])),
        sessionId: Value(session.id),
        gripPosition: Value(record['grip_position'] as int?),
        id: Value(id),
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
        await (_database.update(
          _database.assessments,
        )..where((a) => a.id.equals(existing.id))).write(companion);
      } else {
        await _database.into(_database.assessments).insert(companion);
      }
    }
    AppLoggerHelper.info('Applied ${assessments.length} assessment records');
  }

  Future<void> _applySensorConfigs(List<dynamic> sensorConfigs) async {
    for (final record in sensorConfigs) {
      final id = record['id'] as String;
      final deletedAt = record['deleted_at'] != null
          ? DateTime.parse(record['deleted_at'] as String)
          : null;

      final existing = await (_database.select(
        _database.sensorConfigs,
      )..where((s) => s.id.equals(id))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database.delete(_database.sensorConfigs).delete(existing);
        }
        continue;
      }

      final companion = SensorConfigsCompanion(
        name: Value(record['name'] as String),
        index: Value(record['index'] as int),
        tare: Value(_toDouble(record['tare'])!),
        coef: Value(_toDouble(record['coef'])!),
        id: Value(id),
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
        await (_database.update(
          _database.sensorConfigs,
        )..where((s) => s.id.equals(existing.id))).write(companion);
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
      final id = record['id'] as String;
      final deletedAt = record['deleted_at'] != null
          ? DateTime.parse(record['deleted_at'] as String)
          : null;

      final existing = await (_database.select(
        _database.builtinTrainingWeights,
      )..where((w) => w.id.equals(id))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database
              .delete(_database.builtinTrainingWeights)
              .delete(existing);
        }
        continue;
      }

      final builtinTrainingId = record['builtin_training_id'] as String;

      final companion = BuiltinTrainingWeightsCompanion(
        builtinTrainingId: Value(builtinTrainingId),
        customWeightRight: Value(_toDouble(record['custom_weight_right'])),
        customWeightLeft: Value(_toDouble(record['custom_weight_left'])),
        id: Value(id),
        updatedAt: Value(DateTime.parse(record['updated_at'] as String)),
        createdAt: Value(DateTime.parse(record['created_at'] as String)),
        deletedAt: Value(deletedAt),
        dirty: const Value(false),
      );

      if (existing != null) {
        await (_database.update(
          _database.builtinTrainingWeights,
        )..where((w) => w.id.equals(existing.id))).write(companion);
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
      final id = record['id'] as String;
      final deletedAt = record['deleted_at'] != null
          ? DateTime.parse(record['deleted_at'] as String)
          : null;

      final existing = await (_database.select(
        _database.pinnedBuiltinTrainings,
      )..where((p) => p.builtinTrainingId.equals(id))).getSingleOrNull();

      if (deletedAt != null) {
        if (existing != null) {
          await _database
              .delete(_database.pinnedBuiltinTrainings)
              .delete(existing);
        }
        continue;
      }

      final builtinTrainingId = record['builtin_training_id'] as String;

      final companion = PinnedBuiltinTrainingsCompanion(
        builtinTrainingId: Value(builtinTrainingId),
        dirty: const Value(false),
      );

      if (existing != null) {
        await (_database.update(_database.pinnedBuiltinTrainings)..where(
              (p) => p.builtinTrainingId.equals(existing.builtinTrainingId),
            ))
            .write(companion);
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
    await (_database.update(_database.sessions)
          ..where((s) => s.dirty.equals(true) & s.id.isNotIn(rejected)))
        .write(SessionsCompanion(dirty: const Value(false)));

    await (_database.update(_database.trainings)
          ..where((t) => t.dirty.equals(true) & t.id.isNotIn(rejected)))
        .write(TrainingsCompanion(dirty: const Value(false)));

    await (_database.update(_database.assessments)
          ..where((a) => a.dirty.equals(true) & a.id.isNotIn(rejected)))
        .write(AssessmentsCompanion(dirty: const Value(false)));

    await (_database.update(_database.repeaters)
          ..where((r) => r.dirty.equals(true) & r.id.isNotIn(rejected)))
        .write(RepeatersCompanion(dirty: const Value(false)));

    await (_database.update(_database.repTemplates)
          ..where((r) => r.dirty.equals(true) & r.id.isNotIn(rejected)))
        .write(RepTemplatesCompanion(dirty: const Value(false)));

    await (_database.update(_database.repDatas)
          ..where((r) => r.dirty.equals(true) & r.id.isNotIn(rejected)))
        .write(RepDatasCompanion(dirty: const Value(false)));

    await (_database.update(_database.sensorConfigs)
          ..where((s) => s.dirty.equals(true) & s.id.isNotIn(rejected)))
        .write(SensorConfigsCompanion(dirty: const Value(false)));

    await (_database.update(_database.builtinTrainingWeights)
          ..where((w) => w.dirty.equals(true) & w.id.isNotIn(rejected)))
        .write(BuiltinTrainingWeightsCompanion(dirty: const Value(false)));

    await (_database.update(_database.pinnedBuiltinTrainings)..where(
          (p) => p.dirty.equals(true) & p.builtinTrainingId.isNotIn(rejected),
        ))
        .write(PinnedBuiltinTrainingsCompanion(dirty: const Value(false)));
  }

  Future<void> _wipeLocalDatabase() async {
    AppLoggerHelper.info('Wiping local database');

    await _database.delete(_database.assessments).go();
    await _database.delete(_database.repDatas).go();
    await _database.delete(_database.sessions).go();

    await _database.delete(_database.repTemplates).go();
    await (_database.delete(
      _database.trainings,
    )..where((t) => t.isBuiltin.equals(false))).go();
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
