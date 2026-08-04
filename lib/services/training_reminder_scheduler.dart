import 'package:crimpy/models/cached_program_schedule.dart';
import 'package:crimpy/models/notification_preferences.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/services/notification_service.dart';
import 'package:crimpy/utils/reminder_plan.dart';

/// Turns the current preferences, cached schedule and logged sessions into the
/// set of pending reminder notifications.
class TrainingReminderScheduler {
  final NotificationService _notificationService;

  TrainingReminderScheduler(this._notificationService);

  Future<void> reschedule({
    required NotificationPreferences preferences,
    required CachedProgramSchedule? schedule,
    required List<SessionModel> sessions,
  }) async {
    if (!supportsTrainingReminders) return;

    final occurrences = planReminders(
      preferences: preferences,
      schedule: schedule,
      sessions: sessions,
      from: DateTime.now(),
    );

    if (occurrences.isEmpty) {
      await _notificationService.cancelAll();
      return;
    }
    await _notificationService.scheduleAll(occurrences);
  }
}
