import 'dart:async';

import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/utils/bounded_parallel.dart';
import 'package:crimpy/repositories/bodyweight_repository.dart';
import 'package:crimpy/utils/rep_blocks.dart';
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
  // The bodyweight goes through its own repository rather than reaching past it
  // into the storage it owns, so there is one owner of that key.
  final BodyweightRepository _bodyweight;

  RemoteTrainingRepository(this._apiClient, {BodyweightRepository? bodyweight})
    : _bodyweight = bodyweight ?? BodyweightRepository(_apiClient);

  // ----- Trainings -----

  /// The athlete's library, each training read in full.
  ///
  /// One request: the list is asked to answer with the items, so a library of
  /// fifty trainings costs a single round trip rather than the list followed by
  /// a detail read per training. Every tab that reloads the library pays that
  /// once now.
  @override
  Future<List<Training>> getAllTrainings({bool onlyFavs = false}) async {
    final list = await _apiClient.getTrainings(includeItems: true);
    final rows = list
        .where((t) => !onlyFavs || (t['is_favorite'] as bool? ?? false))
        .toList();

    // A server that predates the items on the list ignores the parameter and
    // answers the cheap rows, which carry no items key at all. Reading those
    // as trainings would hand the athlete a library where nothing has any
    // steps, with no error to say why, so they are read one at a time instead,
    // the way the whole library used to be. A training that really holds no
    // items answers with an empty array and is not fetched again.
    if (rows.every((row) => row.containsKey('items'))) {
      return rows.map(Training.fromJson).toList();
    }

    final fetched = await inParallel(
      rows.map(
        (row) =>
            () => _fetchTraining(row['id'] as String),
      ),
    );
    return fetched.whereType<Training>().toList();
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
    // The prescription a run played that the server cannot read for itself: a
    // training generated on the device. Sent only then, since the server
    // freezes its own copy from a training or a program slot and refuses a
    // second opinion alongside either, and only when every step in it has a
    // name, since the API refuses the whole request over one that has not.
    final ownPrescription = session.ownPrescription;

    // Spelled once: the reps and the reports below both turn on it.
    final namesAPrescription = sessionKeepsItemReports(
      trainingId: session.trainingId,
      programSessionId: session.programSessionId,
      prescriptionItems: ownPrescription,
    );

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
            if (namesAPrescription && indexed.$2.trainingItemId != null)
              'training_item_id': indexed.$2.trainingItemId,
            'target_unmeasured': indexed.$2.targetUnmeasured,
          },
        )
        .toList();

    final int duration =
        session.durationInSeconds ?? reps.fold(0, (p, r) => p + r.duration);

    final curve = ForceCurve.toJson(data ?? const []);

    // What this device resolved the run's percent_bw loads against. Sent rather
    // than left to the server to look up, because the device can hold a weight
    // the server has not been told about: a run needs no network, so an athlete
    // can weigh themselves and train before either reaches us.
    final bodyweightKg = await _bodyweight.cached();

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
      if (namesAPrescription && itemResults.isNotEmpty)
        'item_results': itemResults.map((r) => r.toJson()).toList(),
      // What the run was asked to do, when the server has no training to read
      // it from. It is what the reps and the reports above name their steps
      // against, and what heads them when the session is read back. The same
      // shape the local store freezes, so the two cannot answer the same
      // session differently.
      if (ownPrescription != null)
        'prescription': {
          'items': ownPrescription.map((i) => i.toPrescriptionJson()).toList(),
        },
      // The force curve is what a critical force or an MVC result means, so it
      // goes up with the assessment that recorded it. The API takes it on an
      // assessment only: on an ordinary repeater the samples are bulk nothing
      // reads, and sending them anyway is refused rather than stored.
      if (session.isAssessment && curve != null) 'samples': curve,
      if (bodyweightKg != null) 'bodyweight_kg': bodyweightKg,
      // How much recovery the session cost the athlete. Both fields are sent
      // only when there is an answer: the API refuses a number beside a
      // failure, and takes an absent pair as a session nobody rated yet.
      if (session.rpeFailed)
        'rpe_failed': true
      else if (session.rpe != null)
        'rpe': session.rpe,
    };

    final created = await _apiClient.createSession(body);

    // The upload just proved there is a network, which is the scarce thing a
    // pending measurement is waiting for. Unawaited: the session is already
    // saved and the caller must not wait on this.
    unawaited(_bodyweight.flushPending().catchError((_) {}));
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
      // Always sent, and always as a pair, because this is the path an RPE is
      // given or taken back on: the server leaves the stored answer alone only
      // when a request mentions neither field, which would make clearing one
      // impossible. Sent on a played session too, since the RPE is what the
      // athlete reported and not what the run measured.
      'rpe_failed': session.rpeFailed,
      if (!session.rpeFailed && session.rpe != null) 'rpe': session.rpe,
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
