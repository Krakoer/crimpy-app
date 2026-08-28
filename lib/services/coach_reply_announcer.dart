import 'package:crimpy/logger.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// First notification id reserved for coach replies. Kept clear of the training
/// reminder block in reminder_plan.dart, which is cancelled wholesale on every
/// reschedule and would otherwise take these down with it.
const int coachReplyIdBase = 800000;

/// Number of ids reserved. A session maps into the block by its id, so two
/// sessions can collide and replace each other's notification. That costs at
/// worst one announcement, and the badge in the history still carries both.
const int coachReplyIdBlockSize = 500;

/// Raises a notification for each coach reply the athlete has not been told
/// about yet. Which replies were announced is remembered on the device: the
/// server only knows whether one has been read, and an answer sitting unread
/// must not be announced again on every refresh.
class CoachReplyAnnouncer {
  static const String _announcedKey = 'announced_coach_replies';

  final NotificationService _notifications;

  CoachReplyAnnouncer(this._notifications);

  /// Announces the unread replies among [sessions] that have not been announced
  /// yet, and forgets the ones no longer waiting to be read, so a coach
  /// rewriting an answer raises a fresh notification.
  Future<void> announce(List<SessionModel> sessions) async {
    final unread = sessions
        .where((session) => session.id != null && session.hasUnreadCoachReply)
        .toList();
    final unreadIds = unread.map((session) => session.id!).toSet();

    final prefs = await SharedPreferences.getInstance();
    final announced = (prefs.getStringList(_announcedKey) ?? const []).toSet();

    for (final session in unread) {
      if (announced.contains(session.id)) continue;
      await _notifications.showCoachReply(
        id: notificationIdFor(session.id!),
        title: 'Your coach answered',
        body: '${session.name}: ${session.coachReply}',
      );
      AppLoggerHelper.debug('Announced the coach reply on ${session.id}');
    }

    // Only the ids still unread are kept: an answer the athlete has read, or
    // the coach took back, has nothing left to announce, and dropping it is
    // what lets a later answer on the same session be announced again.
    await prefs.setStringList(_announcedKey, unreadIds.toList());
  }

  /// Drops what has been announced. Called on sign out, since the replies
  /// belong to the account leaving and not to whoever signs in next.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_announcedKey);
  }

  /// Folded from the code units rather than through [String.hashCode], which
  /// Dart does not promise to keep stable between runs: a notification already
  /// in the tray has to be replaceable by the next launch of the app.
  static int notificationIdFor(String sessionId) {
    var folded = 0;
    for (final unit in sessionId.codeUnits) {
      folded = (folded * 31 + unit) % coachReplyIdBlockSize;
    }
    return coachReplyIdBase + folded;
  }
}
