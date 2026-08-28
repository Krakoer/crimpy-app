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

  /// Runs the announcements one after another. Each is a read of the stored
  /// record followed by a write, so two overlapping runs would let the older
  /// one land last and undo what the newer one recorded.
  Future<void> _pending = Future.value();

  /// Announces the unread replies among [sessions] that have not been announced
  /// yet, and takes down the notification of one that has since been read.
  Future<void> announce(List<SessionModel> sessions) {
    final result = _pending.then((_) => _announce(sessions));
    _pending = result.catchError((_) {});
    return result;
  }

  Future<void> _announce(List<SessionModel> sessions) async {
    // An answer nothing can deliver must not be recorded as announced, or it
    // would never be raised again once the athlete allows notifications.
    if (!await _notifications.hasPermission()) return;

    final knownIds = sessions.map((session) => session.id).nonNulls.toSet();
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

    // An answer this list says is read has been seen in the app, so the
    // notification still sitting in the shade is stale.
    for (final id in announced) {
      if (knownIds.contains(id) && !unreadIds.contains(id)) {
        await _notifications.cancelCoachReply(notificationIdFor(id));
      }
    }

    // An id is dropped only when this list actually describes its session and
    // says it is no longer unread. A list from another store, or one that has
    // not loaded yet, then leaves the record alone rather than emptying it and
    // announcing everything again on the next run.
    final kept =
        announced
            .where((id) => unreadIds.contains(id) || !knownIds.contains(id))
            .toSet()
          ..addAll(unreadIds);
    await prefs.setStringList(_announcedKey, kept.toList());
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
