import 'package:crimpy/logger.dart';
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

  /// Every assessment training a program has ever prescribed to the athlete.
  ///
  /// This is the half of the recordable set the athlete cannot fetch as a
  /// catalog: an assessment their coach owns is only readable through the
  /// program that prescribed its training, so the prescriptions are what says
  /// which ones exist. A training prescribed by two programs is fetched once,
  /// and a week or a training that fails to load leaves the others alone rather
  /// than emptying the list.
  ///
  /// Walked in phases, each bounded by [inParallel], so a season of programs
  /// does not put dozens of requests on the wire at once.
  Future<List<Training>> getPrescribedAssessmentTrainings() async {
    final programs = await getPrograms();

    final weekNumbers = await inParallel(
      programs.map(
        (program) =>
            () => _weekNumbersOf(program.id),
      ),
    );
    final scheduledWeeks = [
      for (final (index, program) in programs.indexed)
        for (final weekNumber in weekNumbers[index]) (program.id, weekNumber),
    ];

    final weeks = await inParallel(
      scheduledWeeks.map(
        (scheduled) =>
            () => _weekOrNull(scheduled.$1, scheduled.$2),
      ),
    );
    final programOfTraining = <String, String>{};
    for (final (index, week) in weeks.indexed) {
      if (week == null) continue;
      for (final session in week.sessions) {
        programOfTraining.putIfAbsent(
          session.trainingId,
          () => scheduledWeeks[index].$1,
        );
      }
    }

    final trainings = await inParallel(
      programOfTraining.entries.map(
        (entry) =>
            () => _tryGetProgramTraining(entry.value, entry.key),
      ),
    );
    return trainings
        .whereType<Training>()
        .where((training) => training.assessment != null)
        .toList();
  }

  /// The weeks a program lists. A program whose weeks cannot be read
  /// contributes nothing rather than failing the walk.
  Future<List<int>> _weekNumbersOf(String programId) async {
    try {
      return (await getWeeks(
        programId,
      )).map((summary) => summary.weekNumber).toList();
    } catch (e) {
      AppLoggerHelper.warning("Could not load the weeks of $programId: $e");
      return const [];
    }
  }

  Future<Week?> _weekOrNull(String programId, int weekNumber) async {
    try {
      return await getWeek(programId, weekNumber);
    } catch (e) {
      AppLoggerHelper.warning(
        "Could not load week $weekNumber of $programId: $e",
      );
      return null;
    }
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
