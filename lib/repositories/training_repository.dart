import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/models/session_filter.dart';

abstract class TrainingRepository {
  Future<List<Training>> getAllTrainings({bool onlyFavs = false});

  /// One training by id, or null when it no longer exists. Used to read a
  /// played session against the items it was run from.
  Future<Training?> getTraining(String trainingId);

  /// Saves a new training and hands back the stored copy: storage mints the
  /// ids, for the items as much as for the training itself, so the argument
  /// cannot say what was written.
  Future<Training> saveTraining(Training training);

  /// Writes an existing training and hands back the stored copy, for the same
  /// reason [saveTraining] does: an item the edit added is stored under an id
  /// storage mints, and only the answer says which one.
  Future<Training> updateTraining(Training training);
  Future<void> toggleFav(String trainingId);
  Future<void> deleteTraining(String trainingId);
  Future<List<SessionModel>> getAllSessionsWithReps({SessionFilter? filters});
  Future<SessionModel?> getSessionWithData(String sessionId);

  /// Saves a session with its reps and with the counts the run resolved for the
  /// items the prescription left open.
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  });
  Future<void> updateSession(SessionModel session);
  Future<void> deleteSession(String sessionId);

  /// Stamps the coach's answer to a session as seen. A store with no coach
  /// behind it has nothing to stamp and answers by doing nothing.
  Future<void> markCoachReplyRead(String sessionId);
}

class LocalTrainingRepository extends TrainingRepository {
  final AppDatabase _database;

  LocalTrainingRepository({AppDatabase? database})
    : _database = database ?? gDatabase;

  @override
  Future<List<Training>> getAllTrainings({bool onlyFavs = false}) =>
      _database.getAllTrainings(onlyFavs: onlyFavs);

  @override
  Future<Training?> getTraining(String trainingId) =>
      _database.getTraining(trainingId);

  @override
  Future<Training> saveTraining(Training training) async {
    final id = await _database.saveTraining(training);
    return (await _database.getTraining(id))!;
  }

  @override
  Future<Training> updateTraining(Training training) async {
    await _database.updateTraining(training);
    return (await _database.getTraining(training.id))!;
  }

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
      // The counts ride along with the reps rather than waiting for the detail
      // read: this list already fills the reps, so a session it hands over is
      // never fetched again and the detail screen would have nothing to show.
      result.add(
        row.toModel(
          reps: await _database.getRepsForSession(row.id),
          itemResults: await _database.getItemResultsForSession(row.id),
        ),
      );
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
    List<SessionItemResultModel> itemResults = const [],
  }) => _database.saveSession(
    session,
    reps,
    points: data,
    itemResults: itemResults,
  );

  @override
  Future<void> updateSession(SessionModel session) =>
      _database.updateSession(session);

  @override
  Future<void> deleteSession(String sessionId) =>
      _database.deleteSession(sessionId);

  // A guest-mode session was never seen by a coach, so it can carry no answer
  // to mark as read.
  @override
  Future<void> markCoachReplyRead(String sessionId) async {}
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

  @override
  Future<Training?> getTraining(String trainingId) =>
      _fetchTraining(trainingId);

  Future<Training?> _fetchTraining(String id) async {
    final data = await _apiClient.getTraining(id);
    if (data.isEmpty) return null;
    return Training.fromJson(data);
  }

  @override
  Future<Training> saveTraining(Training training) async {
    // The create answers with the training as the server now holds it, every
    // item under an id it minted itself. Reading it out of the response is what
    // spares the caller a second round trip to learn them.
    final result = await _apiClient.createTraining(training.toJson());
    return Training.fromJson(result);
  }

  @override
  Future<Training> updateTraining(Training training) async {
    final result = await _apiClient.updateTrainingApi(
      training.id,
      training.toJson(),
    );
    return Training.fromJson(result);
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
    final itemResults = (data['item_results'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(SessionItemResultModel.fromJson)
        .toList();
    return SessionModel.fromJson(
      s,
      reps: reps,
      itemResults: itemResults,
      dataPoints: ForceCurve.fromJson(s['samples'] as Map<String, dynamic>?),
    );
  }

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) async {
    final repDatas = reps.indexed
        .map(
          (indexed) => {
            'average_weight': indexed.$2.averageWeight,
            'is_rest': indexed.$2.isRest,
            'hand': indexed.$2.handSide.apiValue,
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
            'target_unmeasured': indexed.$2.targetUnmeasured,
          },
        )
        .toList();

    final int duration =
        session.durationInSeconds ?? reps.fold(0, (p, r) => p + r.duration);

    final curve = ForceCurve.toJson(data ?? const []);

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
      'rep_datas': repDatas,
      // The server reads a count against the prescription it froze, so a run
      // that answers no prescription has nothing to key one into.
      if ((session.trainingId != null || session.programSessionId != null) &&
          itemResults.isNotEmpty)
        'item_results': itemResults.map((r) => r.toJson()).toList(),
      // The force curve is what a critical force or an MVC result means, so it
      // goes up with the assessment that recorded it. The API takes it on an
      // assessment only: on an ordinary repeater the samples are bulk nothing
      // reads, and sending them anyway is refused rather than stored.
      if (session.isAssessment && curve != null) 'samples': curve,
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

  @override
  Future<void> markCoachReplyRead(String sessionId) async {
    await _apiClient.markCoachReplyRead(sessionId);
  }
}
