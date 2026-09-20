import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/api_exception.dart';
import 'package:crimpy/utils/availability_window.dart';

/// The athlete's declared availability, and the reminder their coach set for
/// it. Server owned like the programs, so there is no local mirror here: the
/// only copy kept on the device is the one the reminders are planned from.
class AvailabilityRepository {
  final ApiClient _apiClient;

  AvailabilityRepository(this._apiClient);

  /// The declared weeks inside [window], with what was planned in them. A null
  /// window reads every week the athlete ever declared, which is only worth
  /// asking for when nothing narrower is known.
  Future<List<WeekAvailability>> getWeeks({AvailabilityWindow? window}) async {
    final list = await _apiClient.getMyAvailability(
      from: window == null ? null : formatWeekStart(window.from),
      to: window == null ? null : formatWeekStart(window.to),
    );
    return list.map(WeekAvailability.fromJson).toList();
  }

  /// Every calendar week the athlete has declared, dates alone.
  ///
  /// Read off its own endpoint rather than off [getWeeks], which is windowed.
  /// The reminder planner skips a nudge for a week already answered, so a set
  /// missing a week nudges the athlete about one they have already sent.
  Future<Set<DateTime>> getDeclaredWeekStarts() async {
    final weeks = await _apiClient.getMyDeclaredWeeks();
    return weeks.map(DateTime.parse).toSet();
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
