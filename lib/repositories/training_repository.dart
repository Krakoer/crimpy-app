import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';

abstract class TrainingRepository {
  Future<List<Training>> getAllTrainings({bool onlyFavs = false});
  Future<String> saveTraining(Training training);
  Future<void> updateTraining(Training training);
  Future<void> toggleFav(String trainingId);
  Future<void> deleteTraining(String trainingId);
  Future<List<SessionModel>> getAllSessionsWithReps({SessionFilter? filters});
  Future<SessionModel?> getSessionWithData(String sessionId);
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
  });
  Future<void> updateSession(SessionModel session);
  Future<void> deleteSession(String sessionId);
}

class LocalTrainingRepository implements TrainingRepository {
  @override
  Future<List<Training>> getAllTrainings({bool onlyFavs = false}) =>
      gDatabase.getAllTrainings(onlyFavs: onlyFavs);

  @override
  Future<String> saveTraining(Training training) =>
      gDatabase.saveTraining(training);

  @override
  Future<void> updateTraining(Training training) =>
      gDatabase.updateTraining(training);

  @override
  Future<void> toggleFav(String trainingId) => gDatabase.toggleFav(trainingId);

  @override
  Future<void> deleteTraining(String trainingId) =>
      gDatabase.deleteTraining(trainingId);

  @override
  Future<List<SessionModel>> getAllSessionsWithReps({
    SessionFilter? filters,
  }) async {
    final sessions = await gDatabase.getAllSessions(filters: filters);
    final result = <SessionModel>[];
    for (final s in sessions) {
      final reps = await gDatabase.getRepsForSession(s.id);
      RepeaterConfig? repeaterConfig;
      if (s.repeaterSets != null &&
          s.repeaterReps != null &&
          s.repeaterWorkTime != null &&
          s.repeaterRestTime != null &&
          s.repeaterSetRest != null &&
          s.repeaterSplitHand != null) {
        repeaterConfig = RepeaterConfig(
          sets: s.repeaterSets!,
          repsPerSet: s.repeaterReps!,
          workTime: s.repeaterWorkTime!,
          restTime: s.repeaterRestTime!,
          setRest: s.repeaterSetRest!,
          splitHand: s.repeaterSplitHand!,
        );
      }
      result.add(
        SessionModel(
          id: s.id,
          name: s.name,
          notes: s.notes,
          date: s.date,
          reps: reps,
          isAssessment: s.isAssessment,
          sessionType: enumFromIndex(
            SessionType.values,
            s.sessionType,
            SessionType.crimpy,
          ),
          durationInSeconds: s.duration,
          repeaterConfig: repeaterConfig,
        ),
      );
    }
    return result;
  }

  @override
  Future<SessionModel?> getSessionWithData(String sessionId) =>
      gDatabase.getSessionWithData(sessionId);

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
  }) => gDatabase.saveSession(session, reps, points: data);

  @override
  Future<void> updateSession(SessionModel session) =>
      gDatabase.updateSession(session);

  @override
  Future<void> deleteSession(String sessionId) =>
      gDatabase.deleteSession(sessionId);
}

class RemoteTrainingRepository implements TrainingRepository {
  final ApiClient _apiClient;

  RemoteTrainingRepository(this._apiClient);

  // ----- Trainings -----

  @override
  Future<List<Training>> getAllTrainings({bool onlyFavs = false}) async {
    final list = await _apiClient.getTrainings();
    final trainings = list
        .where((t) => !onlyFavs || (t['is_favorite'] as bool? ?? false))
        .toList();

    final results = await Future.wait(
      trainings.map((t) => _fetchTraining(t['id'] as String)),
    );
    return results.whereType<Training>().toList();
  }

  Future<Training?> _fetchTraining(String id) async {
    final data = await _apiClient.getTraining(id);
    if (data.isEmpty) return null;
    return Training.fromJson(data);
  }

  @override
  Future<String> saveTraining(Training training) async {
    final result = await _apiClient.createTraining(training.toJson());
    return result['id'] as String? ?? result['ID'] as String? ?? '';
  }

  @override
  Future<void> updateTraining(Training training) async {
    await _apiClient.updateTrainingApi(training.id, training.toJson());
  }

  @override
  Future<void> toggleFav(String trainingId) async {
    final data = await _apiClient.getTraining(trainingId);
    final currentFav = data['is_favorite'] as bool? ?? false;
    await _apiClient.updateTrainingApi(trainingId, {
      'title': data['title'],
      'is_favorite': !currentFav,
      'items': data['items'] ?? [],
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
    List<SessionModel> result = sessions.map((s) => _parseSession(s)).toList();
    if (filters != null) {
      result = result.where((s) => filters.matchesSession(s)).toList();
    }
    return result;
  }

  SessionModel _parseSession(Map<String, dynamic> s) {
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
      sessionType: enumFromIndex(
        SessionType.values,
        s['SessionType'] as num?,
        SessionType.crimpy,
      ),
      durationInSeconds: (s['Duration'] as num? ?? 0).toInt(),
      repeaterConfig: repeaterConfig,
    );
  }

  @override
  Future<SessionModel?> getSessionWithData(String sessionId) async {
    final data = await _apiClient.getSession(sessionId);
    final s = data['session'] as Map<String, dynamic>? ?? data;
    final repDatas = (data['rep_datas'] as List<dynamic>? ?? [])
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

    final reps = repDatas
        .map(
          (r) => RepData(
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
          ),
        )
        .toList();

    return SessionModel(
      id: s['ID'] as String,
      name: s['Name'] as String,
      notes: s['Notes'] as String? ?? '',
      date: DateTime.parse(s['Date'] as String),
      reps: reps,
      isAssessment: s['IsAssessment'] as bool? ?? false,
      sessionType: enumFromIndex(
        SessionType.values,
        s['SessionType'] as num?,
        SessionType.crimpy,
      ),
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
    final repDatas = reps.indexed
        .map(
          (indexed) => {
            'average_weight': indexed.$2.averageWeight,
            'is_rest': indexed.$2.isRest,
            'right_hand': indexed.$2.handSide.isRightHand,
            'duration': indexed.$2.duration,
            'target_weight': indexed.$2.targetWeight,
            'index': indexed.$1,
            'grip_position': indexed.$2.gripPosition.index,
          },
        )
        .toList();

    final int duration =
        session.durationInSeconds ?? reps.fold(0, (p, r) => p + r.duration);

    final body = {
      'name': session.name,
      'notes': session.notes ?? '',
      'date': session.date.toUtc().toIso8601String(),
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
        '';
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
}
