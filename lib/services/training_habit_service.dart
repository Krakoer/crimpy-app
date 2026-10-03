import 'dart:convert';

import 'package:crimpy/logger.dart';
import 'package:crimpy/models/training_habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local storage for the athlete's training habits, one list per
/// account and one for the guest, so switching accounts on a device neither
/// mixes them nor loses them. Kept apart from the reminder settings, which are
/// wiped whenever nobody is signed in: a guest's habits have to survive that.
class TrainingHabitService {
  static const String _keyPrefix = 'training_habits';

  /// Who the habits belong to: the signed in user's id, or null for the guest.
  static String keyFor(String? userId) => '$_keyPrefix:${userId ?? 'guest'}';

  Future<List<TrainingHabit>> load(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyFor(userId));
    if (raw == null) return const [];
    try {
      return [
        for (final entry in jsonDecode(raw) as List<dynamic>)
          TrainingHabit.fromJson(entry as Map<String, dynamic>),
      ];
    } catch (error) {
      AppLoggerHelper.error('Unreadable training habits', error);
      return const [];
    }
  }

  Future<void> save(String? userId, List<TrainingHabit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      keyFor(userId),
      jsonEncode([for (final habit in habits) habit.toJson()]),
    );
  }
}
