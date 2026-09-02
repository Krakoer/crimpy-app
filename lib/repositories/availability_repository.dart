import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/api_exception.dart';

/// The athlete's declared availability, and the reminder their coach set for
/// it. Server owned like the programs, so there is no local mirror here: the
/// only copy kept on the device is the one the reminders are planned from.
class AvailabilityRepository {
  final ApiClient _apiClient;

  AvailabilityRepository(this._apiClient);

  Future<List<WeekAvailability>> getWeeks() async {
    final list = await _apiClient.getMyAvailability();
    return list.map(WeekAvailability.fromJson).toList();
  }

  Future<WeekAvailability> saveWeek(WeekAvailability week) async {
    return WeekAvailability.fromJson(
      await _apiClient.putMyWeekAvailability(
        formatWeekStart(week.weekStart),
        week.toJson(),
      ),
    );
  }

  /// Returns null when the athlete has no coach, or their coach set no
  /// reminder, both of which the API reports as a 404 rather than an empty
  /// body.
  Future<CoachAvailabilityReminder?> getReminder() async {
    try {
      return CoachAvailabilityReminder.fromJson(
        await _apiClient.getAvailabilityReminder(),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }
}
