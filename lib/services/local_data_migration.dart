import 'package:crimpy/database/database.dart';
import 'package:crimpy/logger.dart';
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
    failures += await _uploadSessions();
    failures += await _uploadTrainings();
    failures += await _uploadPinnedBuiltins();
    failures += await _uploadBuiltinWeights();
    AppLoggerHelper.info('Local data import complete, $failures failure(s)');
    return failures;
  }

  /// Removes the local copy once it is safely on the server.
  Future<void> clearLocalData() => _database.wipeLocalData();

  Future<int> _uploadSessions() async {
    var failures = 0;
    for (final row in await _database.getAllSessions()) {
      try {
        final reps = await _database.getRepsForSession(row.id);
        final serverSessionId = await _remoteTrainings.saveSession(
          row.toModel(),
          reps,
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

  Future<int> _uploadTrainings() async {
    var failures = 0;
    for (final training in await _database.getAllTrainings()) {
      try {
        await _remoteTrainings.saveTraining(training);
      } catch (e) {
        failures++;
        AppLoggerHelper.error('Failed to import training ${training.id}: $e');
      }
    }
    return failures;
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
