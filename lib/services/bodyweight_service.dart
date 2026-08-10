import 'package:shared_preferences/shared_preferences.dart';

/// Device-local storage for the athlete bodyweight in kilograms, used to turn
/// the loads coaches express as a percentage of the bodyweight into kilograms.
class BodyweightService {
  static const String _bodyweightKey = 'bodyweight_kg';

  Future<double?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_bodyweightKey);
  }

  Future<void> save(double kilograms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_bodyweightKey, kilograms);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bodyweightKey);
  }
}
