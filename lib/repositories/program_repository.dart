import 'package:crimpy/logger.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/api_exception.dart';
import 'package:crimpy/utils/bounded_parallel.dart';

/// Read-only access to coach-assigned programs for the authenticated user.
class ProgramRepository {
  final ApiClient _apiClient;

  ProgramRepository(this._apiClient);

  Future<List<Program>> getPrograms() async {
    final list = await _apiClient.getMyPrograms();
    return list.map(Program.fromJson).toList();
  }

  Future<Program> getProgram(String programId) async {
    return Program.fromJson(await _apiClient.getMyProgram(programId));
  }

  Future<List<WeekSummary>> getWeeks(String programId) async {
    final list = await _apiClient.getMyWeeks(programId);
    return list.map(WeekSummary.fromJson).toList();
  }

  /// Returns null when the coach has not defined this week yet (404).
  Future<Week?> getWeek(String programId, int weekNumber) async {
    try {
      return Week.fromJson(await _apiClient.getMyWeek(programId, weekNumber));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Training> getProgramTraining(
    String programId,
    String trainingId,
  ) async {
    return Training.fromJson(
      await _apiClient.getMyProgramTraining(programId, trainingId),
    );
  }

  /// Every assessment training a program has prescribed to the athlete.
  ///
  /// This is the half of the recordable set the athlete cannot fetch as a
  /// catalog: an assessment their coach owns is only readable through the
  /// program that prescribed its training. The server answers which ones those
  /// are in one request, so only the trainings it names are fetched, and those
  /// through [inParallel] since the athlete may be running several programs.
  ///
  /// A training named by two prescriptions is fetched once, and one that fails
  /// to load leaves the others alone rather than emptying the list.
  Future<List<Training>> getPrescribedAssessmentTrainings() async {
    final recordable =
        (await _apiClient.getRecordableAssessmentDefinitionsApi()).map(
          RecordableAssessment.fromJson,
        );

    // The recordable set also holds the assessments Crimpy ships and the
    // athlete's own, which name no program and are already on hand from the
    // builtins and the training library. What is left is the prescribed half.
    final programOfTraining = <String, String>{};
    for (final assessment in recordable) {
      final trainingId = assessment.definition.trainingId;
      final programId = assessment.programId;
      if (trainingId == null || programId == null) continue;
      programOfTraining.putIfAbsent(trainingId, () => programId);
    }

    final trainings = await inParallel(
      programOfTraining.entries.map(
        (entry) =>
            () => _tryGetProgramTraining(entry.value, entry.key),
      ),
    );
    // The server said these are assessments, so a training that comes back
    // without one is a disagreement rather than a filter. Dropped rather than
    // handed on: what reads this list dereferences the assessment.
    return trainings
        .whereType<Training>()
        .where((training) => training.assessment != null)
        .toList();
  }

  Future<Training?> _tryGetProgramTraining(
    String programId,
    String trainingId,
  ) async {
    try {
      return await getProgramTraining(programId, trainingId);
    } catch (e) {
      AppLoggerHelper.warning("Could not load training $trainingId: $e");
      return null;
    }
  }
}
