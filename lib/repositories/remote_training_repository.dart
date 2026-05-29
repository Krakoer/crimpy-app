import 'dart:convert';
import 'dart:io';

import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class RemoteTrainingRepository implements TrainingRepository {
  final ApiClient _apiClient;

  RemoteTrainingRepository(this._apiClient);

  // ----- Trainings -----

  @override
  Future<List<TrainingWithReps>> getAllTrainings({
    bool onlyFavs = false,
  }) async {
    final trainings = await _apiClient.getTrainings();
    final filtered = onlyFavs
        ? trainings.where((t) => t['IsFavorite'] == true).toList()
        : trainings;

    final results = await Future.wait(
      filtered.map((t) async => _fetchTrainingWithReps(t['ID'] as String)),
    );
    return results.whereType<TrainingWithReps>().toList();
  }

  Future<TrainingWithReps?> _fetchTrainingWithReps(String id) async {
    final data = await _apiClient.getTraining(id);
    return _parseTrainingWithReps(data);
  }

  TrainingWithReps? _parseTrainingWithReps(Map<String, dynamic> data) {
    final training = data['training'] as Map<String, dynamic>?;
    if (training == null) return null;

    final repTemplates = (data['rep_templates'] as List? ?? [])
        .cast<Map<String, dynamic>>();

    RepeaterModel? repeater;
    final List<RepModel> reps;

    reps = repTemplates.map((r) {
      return RepModel(
        id: r['ID'] as String?,
        durationInSeconds: (r['Duration'] as num).toInt(),
        isRest: r['IsRest'] as bool,
        handSide: (r['RightHand'] as bool) ? HandSide.right : HandSide.left,
        targetWeight: (r['TargetWeight'] as num).toDouble(),
        index: (r['Index'] as num).toInt(),
        gripPosition:
            GripPosition.values[(r['GripPosition'] as num? ?? 0).toInt()],
      );
    }).toList();

    return TrainingWithReps(
      id: training['ID'] as String,
      name: training['Name'] as String,
      isFav: training['IsFavorite'] as bool,
      reps: reps,
      repeater: repeater,
    );
  }

  @override
  Future<void> saveTraining(String name, List<RepModel> reps) async {
    await _apiClient.createTraining({
      'name': name,
      'is_favorite': false,
      'is_assessment': false,
      'rep_templates': reps.map((r) => _repModelToJson(r)).toList(),
    });
  }

  @override
  Future<void> saveRepeaterTraining(String name, RepeaterModel model) async {
    final repeaterRes = await _apiClient.createRepeater({
      'sets': model.sets,
      'reps': model.repsBySet,
      'worktime': model.workTime,
      'resttime': model.restTime,
      'set_rest': model.restBteweenSets,
      'target_weight_right': model.weightRight,
      'target_weight_left': model.weightLeft,
      'split_hand': model.splitHand,
      'grip_position': model.gripPosition.index,
    });
    await _apiClient.createTraining({
      'name': name,
      'repeater_id': repeaterRes['ID'],
      'is_favorite': false,
      'is_assessment': false,
    });
  }

  @override
  Future<void> editTraining(
    String trainingId, {
    String? name,
    List<RepModel>? reps,
  }) async {
    final current = await _apiClient.getTraining(trainingId);
    final training = current['training'] as Map<String, dynamic>? ?? current;
    await _apiClient.updateTrainingApi(trainingId, {
      'name': name ?? training['Name'],
      'is_favorite': training['IsFavorite'],
      if (reps != null) 'rep_templates': reps.map(_repModelToJson).toList(),
    });
  }

  @override
  Future<void> editRepeaterTraining(
    String trainingId, {
    String? name,
    RepeaterModel? model,
  }) async {
    final current = await _apiClient.getTraining(trainingId);
    final training = current['training'] as Map<String, dynamic>? ?? current;

    if (name != null) {
      await _apiClient.updateTrainingApi(trainingId, {
        'name': name,
        'is_favorite': training['IsFavorite'],
      });
    }

    if (model != null && training['RepeaterID'] != null) {
      await _apiClient.updateRepeaterApi(training['RepeaterID'] as String, {
        'sets': model.sets,
        'reps': model.repsBySet,
        'worktime': model.workTime,
        'resttime': model.restTime,
        'set_rest': model.restBteweenSets,
        'target_weight_right': model.weightRight,
        'target_weight_left': model.weightLeft,
        'split_hand': model.splitHand,
        'grip_position': model.gripPosition.index,
      });
    }
  }

  @override
  Future<void> toggleFav(String trainingId) async {
    final current = await _apiClient.getTraining(trainingId);
    final training = current['training'] as Map<String, dynamic>? ?? current;
    await _apiClient.updateTrainingApi(trainingId, {
      'name': training['Name'],
      'is_favorite': !(training['IsFavorite'] as bool),
    });
  }

  @override
  Future<void> deleteTraining(String trainingId) async {
    await _apiClient.deleteTrainingApi(trainingId);
  }

  // ----- Sessions -----

  @override
  Future<List<SessionModel>> getAllSessionsWithReps({
    SessionFilter? filters,
  }) async {
    final sessions = await _apiClient.getSessions();

    List<SessionModel> result = sessions.map((s) {
      return _parseSessionBasic(s);
    }).toList();

    if (filters != null) {
      result = result.where((s) => filters.matchesSession(s)).toList();
    }

    return result;
  }

  SessionModel _parseSessionBasic(Map<String, dynamic> s) {
    RepeaterConfig? repeaterConfig;
    if (s['RepeaterSets'] != null &&
        s['RepeaterReps'] != null &&
        s['RepeaterWorkTime'] != null &&
        s['RepeaterRestTime'] != null &&
        s['RepeaterSetRest'] != null &&
        s['RepeaterSplitHand'] != null) {
      repeaterConfig = RepeaterConfig(
        sets: (s['RepeaterSets'] as num).toInt(),
        repsPerSet: (s['RepeaterReps'] as num).toInt(),
        workTime: (s['RepeaterWorkTime'] as num).toInt(),
        restTime: (s['RepeaterRestTime'] as num).toInt(),
        setRest: (s['RepeaterSetRest'] as num).toInt(),
        splitHand: s['RepeaterSplitHand'] as bool,
      );
    }

    return SessionModel(
      id: s['ID'] as String,
      name: s['Name'] as String,
      notes: s['Notes'] as String? ?? '',
      date: DateTime.parse(s['Date'] as String),
      reps: null,
      isAssessment: s['IsAssessment'] as bool? ?? false,
      sessionType: SessionType.values[(s['SessionType'] as num? ?? 0).toInt()],
      durationInSeconds: (s['Duration'] as num? ?? 0).toInt(),
      repeaterConfig: repeaterConfig,
    );
  }

  @override
  Future<SessionModel?> getSessionWithData(String sessionId) async {
    final data = await _apiClient.getSession(sessionId);
    final s = data['session'] as Map<String, dynamic>? ?? data;
    final repDatas = (data['rep_datas'] as List? ?? [])
        .cast<Map<String, dynamic>>();

    RepeaterConfig? repeaterConfig;
    if (s['RepeaterSets'] != null) {
      repeaterConfig = RepeaterConfig(
        sets: (s['RepeaterSets'] as num).toInt(),
        repsPerSet: (s['RepeaterReps'] as num).toInt(),
        workTime: (s['RepeaterWorkTime'] as num).toInt(),
        restTime: (s['RepeaterRestTime'] as num).toInt(),
        setRest: (s['RepeaterSetRest'] as num).toInt(),
        splitHand: s['RepeaterSplitHand'] as bool,
      );
    }

    final reps = repDatas.map((r) {
      return RepData(
        sessionId: sessionId,
        averageWeight: (r['AverageWeight'] as num).toDouble(),
        duration: (r['Duration'] as num).toInt(),
        index: (r['Index'] as num).toInt(),
        isRest: r['IsRest'] as bool,
        rightHand: r['RightHand'] as bool,
        targetWeight: (r['TargetWeight'] as num).toDouble(),
        gripPosition: (r['GripPosition'] as num? ?? 0).toInt(),
        id: r['ID'] as String,
        updatedAt: DateTime.now(),
      );
    }).toList();

    return SessionModel(
      id: s['ID'] as String,
      name: s['Name'] as String,
      notes: s['Notes'] as String? ?? '',
      date: DateTime.parse(s['Date'] as String),
      reps: reps,
      isAssessment: s['IsAssessment'] as bool? ?? false,
      sessionType: SessionType.values[(s['SessionType'] as num? ?? 0).toInt()],
      durationInSeconds: (s['Duration'] as num? ?? 0).toInt(),
      repeaterConfig: repeaterConfig,
    );
  }

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
  }) async {
    final id = const Uuid().v4();

    // Write BLE data points to local filesystem if provided
    String dataPath = '';
    if (data != null && data.isNotEmpty) {
      final dirPath = await getApplicationDocumentsDirectory();
      dataPath = '${dirPath.path}/${DateTime.now().millisecondsSinceEpoch}';
      await File(dataPath).writeAsString(jsonEncode(data));
    }

    final int duration =
        session.durationInSeconds ?? reps.fold(0, (p, r) => p + r.duration);

    final repDatas = reps.indexed.map((indexed) {
      final r = indexed.$2;
      return {
        'average_weight': r.averageWeight,
        'is_rest': r.isRest,
        'right_hand': r.handSide.isRightHand,
        'duration': r.duration,
        'target_weight': r.targetWeight,
        'index': indexed.$1,
        'grip_position': r.gripPosition.index,
      };
    }).toList();

    final body = {
      'id': id,
      'name': session.name,
      'notes': session.notes ?? '',
      'is_assessment': session.isAssessment,
      'session_type': session.sessionType.index,
      'duration': duration,
      if (session.repeaterConfig != null) ...{
        'repeater_sets': session.repeaterConfig!.sets,
        'repeater_reps': session.repeaterConfig!.repsPerSet,
        'repeater_work_time': session.repeaterConfig!.workTime,
        'repeater_rest_time': session.repeaterConfig!.restTime,
        'repeater_set_rest': session.repeaterConfig!.setRest,
        'repeater_split_hand': session.repeaterConfig!.splitHand,
      },
      'rep_datas': repDatas,
    };

    final created = await _apiClient.createSession(body);
    return (created['session'] as Map<String, dynamic>?)?['ID'] as String? ??
        created['ID'] as String? ??
        id;
  }

  @override
  Future<void> updateSession(SessionModel session) async {
    if (session.id == null) return;
    final int duration =
        session.durationInSeconds ??
        (session.reps != null
            ? session.reps!.fold(0, (p, r) => p + r.duration)
            : 0);
    await _apiClient.updateSessionApi(session.id!, {
      'name': session.name,
      'notes': session.notes ?? '',
      'duration': duration,
    });
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _apiClient.deleteSessionApi(sessionId);
  }

  Map<String, dynamic> _repModelToJson(RepModel r) => {
    'is_rest': r.isRest,
    'right_hand': r.handSide.isRightHand,
    'duration': r.durationInSeconds,
    'target_weight': r.targetWeight,
    'index': r.index,
    'grip_position': r.gripPosition.index,
  };
}
