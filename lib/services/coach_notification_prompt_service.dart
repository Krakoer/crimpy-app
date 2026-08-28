import 'package:shared_preferences/shared_preferences.dart';

/// Why an athlete is being asked to allow notifications, which is also what the
/// explanation shown to them says.
enum CoachNotificationPrompt {
  /// The account is enrolled with a coach and has never been asked. Nothing is
  /// waiting yet, so this only explains what the permission is for.
  enrolled,

  /// A coach answer is sitting unread and could not be delivered. Asked apart
  /// from [enrolled] on purpose: an athlete who waved the first ask away before
  /// ever hearing from their coach would otherwise never be asked again.
  unreadReply,
}

/// Remembers which of the notification permission asks an athlete has already
/// seen, so neither is repeated on every launch.
///
/// Kept on the device rather than on the server: the permission is a property
/// of this install, and the same account on another phone has to be asked
/// again.
class CoachNotificationPromptService {
  static const String _prefix = 'coach_notification_prompt_';

  Future<bool> hasAsked(CoachNotificationPrompt prompt) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix${prompt.name}') ?? false;
  }

  Future<void> markAsked(CoachNotificationPrompt prompt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix${prompt.name}', true);
  }

  /// Drops the record on sign out: the next account on this device is a
  /// different athlete, with a different coach, and has never been asked.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    for (final prompt in CoachNotificationPrompt.values) {
      await prefs.remove('$_prefix${prompt.name}');
    }
  }
}
