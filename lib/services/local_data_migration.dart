import 'package:crimpy/database/database.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';

/// How much guest data is sitting on the device, so the user can be asked
/// whether to keep it before signing in.
class LocalImportStatus {
  final int sessionCount;
  final int trainingCount;

  const LocalImportStatus({
    required this.sessionCount,
    required this.trainingCount,
  });

  bool get hasData => sessionCount > 0 || trainingCount > 0;
}

/// What the server called the trainings it was just given, keyed by the local
/// ids the rest of the guest data still names.
///
/// The API mints its own ids on create and takes none from the client, so a
/// session played in guest mode names a training, and its reps and open counts
/// name items, that the server has never seen. Every one of those links has to
/// be rewritten through this before the session is posted, or the create is
/// refused.
class _ImportedTrainingIds {
  /// Server id per local training id, for the trainings that made it up whole.
  final Map<String, String> trainings = {};

  /// Server id per local training item id, across every imported training.
  final Map<String, String> items = {};

  /// Local trainings the import could not put on the server. Their sessions are
  /// held back rather than imported against a link nothing would resolve: the
  /// local copy is kept whenever the run reports a failure, so they are still
  /// there for the next attempt.
  final Set<String> failed = {};
}

/// Moves data recorded in guest mode up to the API when the user signs in.
///
/// This is storage work rather than auth state, so it lives beside the other
/// services and takes its collaborators explicitly: the migration can then be
/// exercised against an in-memory database and fake repositories.
class LocalDataMigration {
  final AppDatabase _database;
  final ApiClient _apiClient;
  final TrainingRepository _remoteTrainings;
  final AssessmentRepository _remoteAssessments;

  LocalDataMigration({
    required ApiClient apiClient,
    required TrainingRepository remoteTrainings,
    required AssessmentRepository remoteAssessments,
    AppDatabase? database,
  }) : _apiClient = apiClient,
       _remoteTrainings = remoteTrainings,
       _remoteAssessments = remoteAssessments,
       _database = database ?? gDatabase;

  /// What is currently stored locally, without uploading anything.
  Future<LocalImportStatus> pendingData() async {
    final sessions = await _database.getAllSessions();
    final trainings = await _database.getAllTrainings();
    return LocalImportStatus(
      sessionCount: sessions.length,
      trainingCount: trainings.length,
    );
  }

  /// Uploads every locally stored entity to the API. Individual failures are
  /// logged and counted rather than aborting the run, so a single bad row does
  /// not block the rest; the returned count tells the caller whether the local
  /// copy is now safe to delete.
  Future<int> uploadAll() async {
    var failures = 0;
    // Trainings go up first and hand over the ids they were given: a session
    // can only name the training it was played from once the server holds one.
    final ids = _ImportedTrainingIds();
    failures += await _uploadTrainings(ids);
    failures += await _uploadSessions(ids);
    failures += await _uploadPinnedBuiltins();
    failures += await _uploadBuiltinWeights();
    AppLoggerHelper.info('Local data import complete, $failures failure(s)');
    return failures;
  }

  /// Removes the local copy once it is safely on the server.
  Future<void> clearLocalData() => _database.wipeLocalData();

  Future<int> _uploadSessions(_ImportedTrainingIds ids) async {
    var failures = 0;
    for (final row in await _database.getAllSessions()) {
      final localTrainingId = row.trainingId;
      if (localTrainingId != null && ids.failed.contains(localTrainingId)) {
        failures++;
        AppLoggerHelper.error(
          'Skipped session ${row.id}: training $localTrainingId was not imported',
        );
        continue;
      }
      try {
        // Null both when the session was logged or played from a builtin, and
        // when the athlete deleted the training after playing it. The session
        // still goes up in that last case, without the links it can no longer
        // resolve: holding it back would leave the import failing for good.
        final serverTrainingId = localTrainingId == null
            ? null
            : ids.trainings[localTrainingId];

        String? serverItemId(String? localItemId) {
          if (serverTrainingId == null || localItemId == null) return null;
          return ids.items[localItemId];
        }

        final localReps = await _database.getRepsForSession(row.id);
        final reps = [
          for (final rep in localReps)
            rep.withTrainingItem(serverItemId(rep.trainingItemId)),
        ];
        // Only the reps that had a link and lost it. A rest, and any rep
        // recorded outside a training, names no item to begin with.
        final droppedRepLinks = localReps
            .where(
              (rep) =>
                  rep.trainingItemId != null &&
                  serverItemId(rep.trainingItemId) == null,
            )
            .length;
        final itemResults = <SessionItemResultModel>[];
        for (final result in await _database.getItemResultsForSession(row.id)) {
          final itemId = serverItemId(result.trainingItemId);
          if (itemId == null) {
            // The item the count answers is gone, and the server refuses a
            // count naming an item its prescription does not hold. Nothing is
            // left to attach it to, so it is dropped rather than failing the
            // whole session over it.
            AppLoggerHelper.warning(
              'Dropped an open count of session ${row.id}: '
              'item ${result.trainingItemId} is not on the server',
            );
            continue;
          }
          itemResults.add(result.withTrainingItem(itemId));
        }

        // Reported once for the session rather than once per rep, which a
        // training edited after it was played would turn into a wall of lines.
        if (droppedRepLinks > 0 && serverTrainingId != null) {
          AppLoggerHelper.warning(
            'Session ${row.id} imported with $droppedRepLinks of '
            '${localReps.length} rep(s) naming an item that is not on the '
            'server',
          );
        }

        final serverSessionId = await _remoteTrainings.saveSession(
          row.toModel().withTrainingId(serverTrainingId),
          reps,
          itemResults: itemResults,
        );
        if (row.isAssessment) {
          failures += await _uploadAssessmentsFor(row.id, serverSessionId);
        }
      } catch (e) {
        failures++;
        AppLoggerHelper.error('Failed to import session ${row.id}: $e');
      }
    }
    return failures;
  }

  Future<int> _uploadAssessmentsFor(
    String localSessionId,
    String serverSessionId,
  ) async {
    var failures = 0;
    final rows = await _database.getAssessmentsForSession(localSessionId);
    for (final row in rows) {
      try {
        await _remoteAssessments.saveAssessment(
          row.toResult(),
          serverSessionId,
        );
      } catch (e) {
        failures++;
        AppLoggerHelper.error(
          'Failed to import assessment for session $localSessionId: $e',
        );
      }
    }
    return failures;
  }

  Future<int> _uploadTrainings(_ImportedTrainingIds ids) async {
    var failures = 0;
    for (final training in await _database.getAllTrainings()) {
      try {
        // The save answers with the training as the server now holds it, under
        // the ids it minted. Nothing else says which stored item each local one
        // became, and the reps and the open counts of every session played from
        // this training are keyed on that.
        final stored = await _remoteTrainings.saveTraining(training);
        final itemIds = <String, String>{};
        if (!_pairItemIds(training.items, stored.items, itemIds)) {
          throw StateError(
            'imported training ${stored.id} came back a different shape',
          );
        }
        ids.trainings[training.id] = stored.id;
        ids.items.addAll(itemIds);
      } catch (e) {
        failures++;
        ids.failed.add(training.id);
        AppLoggerHelper.error('Failed to import training ${training.id}: $e');
      }
    }
    return failures;
  }

  /// Pairs the items sent up with the ones that came back, which the server
  /// stores and returns in the order it was given them, and records the id each
  /// local item now has. False when the two trees do not line up, which leaves
  /// the caller to fail the training rather than link its reps to whichever
  /// item happens to sit at the same index.
  bool _pairItemIds(
    List<TrainingItem> local,
    List<TrainingItem> stored,
    Map<String, String> into,
  ) {
    if (local.length != stored.length) return false;
    for (var i = 0; i < local.length; i++) {
      into[local[i].id] = stored[i].id;
      if (!_pairItemIds(local[i].items, stored[i].items, into)) return false;
    }
    return true;
  }

  Future<int> _uploadPinnedBuiltins() async {
    var failures = 0;
    for (final id in await _database.getPinnedBuiltinTrainingIds()) {
      try {
        await _apiClient.pinBuiltinTrainingApi(id);
      } catch (e) {
        failures++;
        AppLoggerHelper.error('Failed to import pinned builtin $id: $e');
      }
    }
    return failures;
  }

  Future<int> _uploadBuiltinWeights() async {
    var failures = 0;
    for (final w in await _database.getAllBuiltinTrainingWeights()) {
      try {
        await _apiClient.createBuiltinTrainingWeight({
          'id': w.id,
          'builtin_training_id': w.builtinTrainingId,
          'custom_weight_right': w.customWeightRight ?? 0.0,
          'custom_weight_left': w.customWeightLeft ?? 0.0,
        });
      } catch (e) {
        failures++;
        AppLoggerHelper.error(
          'Failed to import builtin weight ${w.builtinTrainingId}: $e',
        );
      }
    }
    return failures;
  }
}
