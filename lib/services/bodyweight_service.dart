import 'package:shared_preferences/shared_preferences.dart';

/// A measurement the device holds but the server has not been told about.
class PendingBodyweight {
  final double weightKg;
  final DateTime measuredAt;

  const PendingBodyweight(this.weightKg, this.measuredAt);
}

/// Device-local storage for the athlete bodyweight in kilograms, used to turn
/// the loads coaches express as a percentage of the bodyweight into kilograms.
///
/// The series itself lives on the server, where the coach can read it. This is
/// the cache a run resolves against, because a run must not need the network,
/// and the holding place for a measurement that has not reached the server.
class BodyweightService {
  static const String _bodyweightKey = 'bodyweight_kg';
  static const String _pendingWeightKey = 'bodyweight_pending_kg';
  static const String _pendingMeasuredAtKey = 'bodyweight_pending_measured_at';

  Future<double?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_bodyweightKey);
  }

  Future<void> save(double kilograms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_bodyweightKey, kilograms);
  }

  /// Holds a measurement until the server has it, weight and all.
  ///
  /// The weight is stored here rather than read back from the cache at send
  /// time: the cache moves on as soon as the athlete weighs in again, and a
  /// measurement waiting to be sent must not be replaced by a later one it was
  /// never about.
  Future<void> markPending(double kilograms, DateTime measuredAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_pendingWeightKey, kilograms);
    await prefs.setString(
      _pendingMeasuredAtKey,
      measuredAt.toUtc().toIso8601String(),
    );
  }

  /// The measurement waiting to be sent, or null when there is none.
  Future<PendingBodyweight?> pending() async {
    final prefs = await SharedPreferences.getInstance();
    final kilograms = prefs.getDouble(_pendingWeightKey);
    final measuredAt = DateTime.tryParse(
      prefs.getString(_pendingMeasuredAtKey) ?? '',
    );
    if (kilograms == null || measuredAt == null) return null;
    return PendingBodyweight(kilograms, measuredAt);
  }

  Future<void> clearPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingWeightKey);
    await prefs.remove(_pendingMeasuredAtKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bodyweightKey);
    await clearPending();
  }
}
