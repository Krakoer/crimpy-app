import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/models/session_filter.dart';

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

class LocalTrainingRepository extends TrainingRepository {
  final AppDatabase _database;

  LocalTrainingRepository({AppDatabase? database})
    : _database = database ?? gDatabase;

  @override
  Future<List<Training>> getAllTrainings({bool onlyFavs = false}) =>
      _database.getAllTrainings(onlyFavs: onlyFavs);

  @override
  Future<String> saveTraining(Training training) =>
      _database.saveTraining(training);

  @override
  Future<void> updateTraining(Training training) =>
      _database.updateTraining(training);

  @override
  Future<void> toggleFav(String trainingId) => _database.toggleFav(trainingId);

  @override
  Future<void> deleteTraining(String trainingId) =>
      _database.deleteTraining(trainingId);

  @override
  Future<List<SessionModel>> getAllSessionsWithReps({
    SessionFilter? filters,
  }) async {
    final rows = (await _database.getAllSessions())
        .where(
          (row) => filters == null || filters.matchesSession(row.toModel()),
        )
        .toList();
    final result = <SessionModel>[];
    for (final row in rows) {
      result.add(row.toModel(reps: await _database.getRepsForSession(row.id)));
    }
    return result;
  }

  @override
  Future<SessionModel?> getSessionWithData(String sessionId) =>
      _database.getSessionWithData(sessionId);

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
  }) => _database.saveSession(session, reps, points: data);

  @override
  Future<void> updateSession(SessionModel session) =>
      _database.updateSession(session);

  @override
  Future<void> deleteSession(String sessionId) =>
      _database.deleteSession(sessionId);
}

class RemoteTrainingRepository extends TrainingRepository {
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
    return result['id'] as String? ?? '';
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
    List<SessionModel> result = sessions.map(SessionModel.fromJson).toList();
    if (filters != null) {
      result = result.where((s) => filters.matchesSession(s)).toList();
    }
    return result;
  }

  @override
  Future<SessionModel?> getSessionWithData(String sessionId) async {
    final data = await _apiClient.getSession(sessionId);
    final s = data['session'] as Map<String, dynamic>? ?? data;
    final repDatas = (data['rep_datas'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final reps = repDatas.map(RepDataModel.fromJson).toList();
    return SessionModel.fromJson(s, reps: reps);
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
            if (indexed.$2.edgeSizeMm != null)
              'edge_size_mm': indexed.$2.edgeSizeMm,
            // The server reads the link against the prescription it froze, which
            // it resolves from training_id or from the program session when one
            // is sent, so a run outside both has nothing to key into.
            if ((session.trainingId != null ||
                    session.programSessionId != null) &&
                indexed.$2.trainingItemId != null)
              'training_item_id': indexed.$2.trainingItemId,
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
      'activity': session.activity.index,
      'origin': session.origin.apiValue,
      if (session.trainingId != null) 'training_id': session.trainingId,
      if (session.programSessionId != null)
        'program_session_id': session.programSessionId,
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
    return (created['session'] as Map<String, dynamic>?)?['id'] as String? ??
        created['id'] as String? ??
        '';
  }

  @override
  Future<void> updateSession(SessionModel session) async {
    if (session.id == null) return;
    await _apiClient.updateSessionApi(session.id!, {
      'name': session.name,
      'notes': session.notes ?? '',
      // The duration is always sent because the server overwrites it either
      // way, so it carries the session's own value rather than a recomputed
      // one: a played session posts back exactly what its run measured.
      'duration': session.duration,
      // A played session keeps the date its run gave it, so only a logged one
      // sends one. Omitted, the server leaves the stored date alone.
      if (!session.origin.isPlayed)
        'date': session.date.toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _apiClient.deleteSessionApi(sessionId);
  }
}
