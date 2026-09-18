import 'package:crimpy/logger.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/api_exception.dart';

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

  /// Every assessment training a program has ever prescribed to the athlete.
  ///
  /// This is the half of the recordable set the athlete cannot fetch as a
  /// catalog: an assessment their coach owns is only readable through the
  /// program that prescribed its training, so the prescriptions are what says
  /// which ones exist. A training prescribed by two programs is fetched once,
  /// and a week or a training that fails to load leaves the others alone rather
  /// than emptying the list.
  Future<List<Training>> getPrescribedAssessmentTrainings() async {
    final programs = await getPrograms();
    final programOfTraining = <String, String>{};
    await Future.wait(
      programs.map((program) async {
        final weeks = await _weeksOf(program.id);
        for (final week in weeks) {
          for (final session in week.sessions) {
            programOfTraining.putIfAbsent(session.trainingId, () => program.id);
          }
        }
      }),
    );

    final trainings = await Future.wait(
      programOfTraining.entries.map(
        (entry) => _tryGetProgramTraining(entry.value, entry.key),
      ),
    );
    return trainings
        .whereType<Training>()
        .where((training) => training.assessment != null)
        .toList();
  }

  /// The published weeks of a program, with their sessions. A program whose
  /// weeks cannot be read contributes nothing rather than failing the walk.
  Future<List<Week>> _weeksOf(String programId) async {
    final List<WeekSummary> summaries;
    try {
      summaries = await getWeeks(programId);
    } catch (e) {
      AppLoggerHelper.warning("Could not load the weeks of $programId: $e");
      return const [];
    }
    final weeks = await Future.wait(
      summaries.map((summary) async {
        try {
          return await getWeek(programId, summary.weekNumber);
        } catch (e) {
          AppLoggerHelper.warning(
            "Could not load week ${summary.weekNumber} of $programId: $e",
          );
          return null;
        }
      }),
    );
    return weeks.whereType<Week>().toList();
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
