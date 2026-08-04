import 'dart:convert';

import 'package:crimpy/logger.dart';
import 'package:crimpy/models/cached_program_schedule.dart';
import 'package:crimpy/models/notification_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local storage for the training reminder settings and for the copy of
/// the program schedule the reminders are planned from. Both are kept on the
/// device rather than synced: reminders are a per-device concern.
class NotificationPreferencesService {
  static const String _preferencesKey = 'notification_preferences';
  static const String _scheduleKey = 'reminder_program_schedule';

  Future<NotificationPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_preferencesKey);
    if (raw == null) return const NotificationPreferences();
    try {
      return NotificationPreferences.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (error) {
      AppLoggerHelper.error('Unreadable notification preferences', error);
      return const NotificationPreferences();
    }
  }

  Future<void> save(NotificationPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferencesKey, jsonEncode(preferences.toJson()));
  }

  Future<CachedProgramSchedule?> loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scheduleKey);
    if (raw == null) return null;
    try {
      return CachedProgramSchedule.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (error) {
      AppLoggerHelper.error('Unreadable cached program schedule', error);
      return null;
    }
  }

  Future<void> saveSchedule(CachedProgramSchedule? schedule) async {
    final prefs = await SharedPreferences.getInstance();
    if (schedule == null) {
      await prefs.remove(_scheduleKey);
      return;
    }
    await prefs.setString(_scheduleKey, jsonEncode(schedule.toJson()));
  }
}
