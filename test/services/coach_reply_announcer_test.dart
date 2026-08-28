import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/services/coach_reply_announcer.dart';
import 'package:crimpy/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records what would have been posted, so the announcer can be exercised
/// without the notifications plugin. The platform check inside the real service
/// answers false off a device, so permission is stated here instead.
class _RecordingNotificationService extends NotificationService {
  _RecordingNotificationService({this.permitted = true});

  final bool permitted;
  final List<String> shown = [];
  final List<int> cancelled = [];

  @override
  Future<bool> hasPermission() async => permitted;

  @override
  Future<void> showCoachReply({
    required int id,
    required String title,
    required String body,
  }) async {
    shown.add(body);
  }

  @override
  Future<void> cancelCoachReply(int id) async {
    cancelled.add(id);
  }
}

SessionModel _session({
  required String id,
  String? coachReply,
  bool coachReplyRead = false,
}) => SessionModel(
  id: id,
  name: 'Repeaters',
  notes: 'Felt heavy',
  isAssessment: false,
  origin: SessionOrigin.logged,
  activity: SessionActivity.hangboard,
  coachReply: coachReply,
  coachReplyAt: coachReply == null ? null : DateTime(2026, 8, 28),
  coachReplyRead: coachReplyRead,
);

void main() {
  late _RecordingNotificationService notifications;
  late CoachReplyAnnouncer announcer;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    notifications = _RecordingNotificationService();
    announcer = CoachReplyAnnouncer(notifications);
  });

  test('announces an unread reply once', () async {
    final sessions = [_session(id: 's-1', coachReply: 'Rest more')];

    await announcer.announce(sessions);
    await announcer.announce(sessions);

    expect(notifications.shown, ['Repeaters: Rest more']);
  });

  test('says nothing about a reply the athlete has read', () async {
    await announcer.announce([
      _session(id: 's-1', coachReply: 'Rest more', coachReplyRead: true),
    ]);

    expect(notifications.shown, isEmpty);
  });

  test('says nothing about a session with no reply', () async {
    await announcer.announce([_session(id: 's-1')]);

    expect(notifications.shown, isEmpty);
  });

  test('announces a rewritten reply again once the first was read', () async {
    await announcer.announce([_session(id: 's-1', coachReply: 'Rest more')]);
    await announcer.announce([
      _session(id: 's-1', coachReply: 'Rest more', coachReplyRead: true),
    ]);
    await announcer.announce([_session(id: 's-1', coachReply: 'Correction')]);

    expect(notifications.shown, [
      'Repeaters: Rest more',
      'Repeaters: Correction',
    ]);
  });

  test('forgets what was announced when the account signs out', () async {
    final sessions = [_session(id: 's-1', coachReply: 'Rest more')];
    await announcer.announce(sessions);

    await announcer.clear();
    await announcer.announce(sessions);

    expect(notifications.shown, [
      'Repeaters: Rest more',
      'Repeaters: Rest more',
    ]);
  });

  test('says nothing, and records nothing, without the permission', () async {
    final blocked = _RecordingNotificationService(permitted: false);
    final sessions = [_session(id: 's-1', coachReply: 'Rest more')];

    await CoachReplyAnnouncer(blocked).announce(sessions);

    expect(blocked.shown, isEmpty);

    // Nothing was recorded, so the answer is still announced the first time the
    // athlete allows notifications.
    await announcer.announce(sessions);
    expect(notifications.shown, ['Repeaters: Rest more']);
  });

  test('takes the notification down once the answer has been read', () async {
    await announcer.announce([_session(id: 's-1', coachReply: 'Rest more')]);

    await announcer.announce([
      _session(id: 's-1', coachReply: 'Rest more', coachReplyRead: true),
    ]);

    expect(notifications.cancelled, [
      CoachReplyAnnouncer.notificationIdFor('s-1'),
    ]);
  });

  test('keeps the record when handed a history that omits the session', () async {
    final sessions = [_session(id: 's-1', coachReply: 'Rest more')];
    await announcer.announce(sessions);

    // The guest store answers with nothing while the sign in resolves. Treating
    // that as "no longer unread" would re-announce everything on the next run.
    await announcer.announce(const []);
    await announcer.announce(sessions);

    expect(notifications.shown, ['Repeaters: Rest more']);
    expect(notifications.cancelled, isEmpty);
  });

  test('keeps a notification id inside the block it reserved', () {
    for (final id in ['s-1', 'a-much-longer-session-uuid', '']) {
      final notificationId = CoachReplyAnnouncer.notificationIdFor(id);
      expect(notificationId, greaterThanOrEqualTo(coachReplyIdBase));
      expect(
        notificationId,
        lessThan(coachReplyIdBase + coachReplyIdBlockSize),
      );
    }
  });
}
