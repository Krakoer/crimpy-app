import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/training_model.dart';
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
}
