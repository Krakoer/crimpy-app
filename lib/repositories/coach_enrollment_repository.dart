import 'package:crimpy/models/coach_enrollment.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/api_exception.dart';

/// Read-only access to the coach the authenticated athlete is enrolled with.
class CoachEnrollmentRepository {
  final ApiClient _apiClient;

  CoachEnrollmentRepository(this._apiClient);

  /// Returns null when the athlete has no coach, which the API reports as a
  /// 404 rather than an empty body.
  Future<CoachEnrollment?> getEnrollment() async {
    try {
      return CoachEnrollment.fromJson(await _apiClient.getUserEnrollment());
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }
}
