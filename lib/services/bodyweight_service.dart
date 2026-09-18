import 'package:shared_preferences/shared_preferences.dart';

/// Device-local storage for the athlete bodyweight in kilograms, used to turn
/// the loads coaches express as a percentage of the bodyweight into kilograms.
///
/// The series itself lives on the server, where the coach can read it. This is
/// the cache a run resolves against, because a run must not need the network,
/// and the holding place for a measurement taken while there was none.
class BodyweightService {
  static const String _bodyweightKey = 'bodyweight_kg';
  static const String _pendingMeasuredAtKey = 'bodyweight_pending_measured_at';

  Future<double?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_bodyweightKey);
  }

  Future<void> save(double kilograms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_bodyweightKey, kilograms);
  }

  /// Remembers that the cached weight has not reached the server yet, with the
  /// moment it was actually measured, so a later flush files it under the day
  /// it belongs to rather than the day the network came back.
  Future<void> markPending(DateTime measuredAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pendingMeasuredAtKey,
      measuredAt.toUtc().toIso8601String(),
    );
  }

  /// When the unsent measurement was taken, or null when there is none.
  Future<DateTime?> pendingMeasuredAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingMeasuredAtKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> clearPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingMeasuredAtKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bodyweightKey);
    await prefs.remove(_pendingMeasuredAtKey);
  }
}
