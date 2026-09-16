import 'package:crimpy/services/api_exception.dart';
import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/models/coach_enrollment.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/services/coach_notification_prompt_service.dart';
import 'package:crimpy/services/notification_service.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/coach_view_model.dart';
import 'package:crimpy/viewmodels/notification_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// States the platform and permission answers the real service can only get
/// from a device: off one it reports no support and no permission, which would
/// make every case below look the same.
class _FakeNotificationService extends NotificationService {
  _FakeNotificationService({this.notifiable = true, this.permitted = false});

  final bool notifiable;
  final bool permitted;

  @override
  bool get canNotify => notifiable;

  @override
  Future<bool> hasPermission() async => permitted;
}

class _FakeAuthState extends AuthState {
  _FakeAuthState(this.user);

  final auth_models.User? user;

  @override
  Future<auth_models.User?> build() async => user;
}

class _FakeSessions extends Sessions {
  _FakeSessions(this.sessions);

  final List<SessionModel> sessions;

  @override
  Future<List<SessionModel>> build() async => sessions;
}

final _user = auth_models.User(
  id: 'athlete',
  email: 'athlete@crimpy.app',
  firstname: 'Ada',
  lastname: 'Climber',
  emailVerified: true,
  createdAt: '2026-01-01T00:00:00Z',
);

final _enrollment = CoachEnrollment(
  enrollmentId: 'enrollment',
  coachId: 'coach',
  coachFirstname: 'Remi',
  coachLastname: 'Belard',
  enrolledAt: DateTime(2026, 8, 1),
);

SessionModel _session({String? coachReply, bool coachReplyRead = false}) =>
    SessionModel(
      id: 'session',
      name: 'Repeaters',
      isAssessment: false,
      origin: SessionOrigin.logged,
      coachReply: coachReply,
      coachReplyAt: coachReply == null ? null : DateTime(2026, 8, 28),
      coachReplyRead: coachReplyRead,
    );

ProviderContainer _containerWith({
  auth_models.User? user,
  CoachEnrollment? enrollment,
  List<SessionModel> sessions = const [],
  bool notifiable = true,
  bool permitted = false,
  bool enrollmentFails = false,
}) => ProviderContainer.test(
  // A provider that throws is retried with a backoff by default, which a test
  // asserting the failure would sit through rather than observe.
  retry: (retryCount, error) => null,
  overrides: [
    notificationServiceProvider.overrideWithValue(
      _FakeNotificationService(notifiable: notifiable, permitted: permitted),
    ),
    authStateProvider.overrideWith(() => _FakeAuthState(user)),
    coachEnrollmentProvider.overrideWith(
      (ref) async => enrollmentFails
          ? throw ApiException('Connection error.', isOffline: true)
          : enrollment,
    ),
    sessionsProvider.overrideWith(() => _FakeSessions(sessions)),
  ],
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // The enrollment provider answers a failed fetch by throwing rather than by
  // saying there is no coach. Nothing is due until the app can ask who the
  // coach is, and the ask is worth keeping for a launch that can get an answer,
  // so the failure is caught here rather than escalating out of the post frame
  // callback that started it.
  test('a launch that cannot reach the enrollment is due nothing', () async {
    final container = _containerWith(user: _user, enrollmentFails: true);

    expect(
      await container.read(pendingCoachNotificationPromptProvider.future),
      isNull,
    );
  });

  test(
    'a coached athlete who was never asked is due the enrolled ask',
    () async {
      final container = _containerWith(user: _user, enrollment: _enrollment);

      expect(
        await container.read(pendingCoachNotificationPromptProvider.future),
        CoachNotificationPrompt.enrolled,
      );
    },
  );

  test('an athlete with no coach is never asked', () async {
    final container = _containerWith(user: _user);

    expect(
      await container.read(pendingCoachNotificationPromptProvider.future),
      isNull,
    );
  });

  test('guest mode is never asked', () async {
    final container = _containerWith(enrollment: _enrollment);

    expect(
      await container.read(pendingCoachNotificationPromptProvider.future),
      isNull,
    );
  });

  test('a platform that cannot notify is never asked', () async {
    final container = _containerWith(
      user: _user,
      enrollment: _enrollment,
      notifiable: false,
    );

    expect(
      await container.read(pendingCoachNotificationPromptProvider.future),
      isNull,
    );
  });

  test('permission already granted asks nothing', () async {
    final container = _containerWith(
      user: _user,
      enrollment: _enrollment,
      permitted: true,
    );

    expect(
      await container.read(pendingCoachNotificationPromptProvider.future),
      isNull,
    );
  });

  test(
    'an unread answer is asked about even once the enrolled ask is spent',
    () async {
      await CoachNotificationPromptService().markAsked(
        CoachNotificationPrompt.enrolled,
      );
      final container = _containerWith(
        user: _user,
        enrollment: _enrollment,
        sessions: [_session(coachReply: 'Nice work')],
      );

      expect(
        await container.read(pendingCoachNotificationPromptProvider.future),
        CoachNotificationPrompt.unreadReply,
      );
    },
  );

  test('an answer already read raises no ask of its own', () async {
    await CoachNotificationPromptService().markAsked(
      CoachNotificationPrompt.enrolled,
    );
    final container = _containerWith(
      user: _user,
      enrollment: _enrollment,
      sessions: [_session(coachReply: 'Nice work', coachReplyRead: true)],
    );

    expect(
      await container.read(pendingCoachNotificationPromptProvider.future),
      isNull,
    );
  });

  test(
    'the ask about a waiting answer is never followed by the weaker one',
    () async {
      await CoachNotificationPromptService().markAsked(
        CoachNotificationPrompt.unreadReply,
      );
      final container = _containerWith(
        user: _user,
        enrollment: _enrollment,
        sessions: [_session(coachReply: 'Nice work')],
      );

      expect(
        await container.read(pendingCoachNotificationPromptProvider.future),
        isNull,
      );
    },
  );

  test('signing out forgets that the account was asked', () async {
    final service = CoachNotificationPromptService();
    await service.markAsked(CoachNotificationPrompt.enrolled);
    final container = _containerWith(enrollment: _enrollment);

    await container.read(coachReplySyncProvider.future);

    expect(await service.hasAsked(CoachNotificationPrompt.enrolled), isFalse);
  });

  test('both asks spent leaves nothing due', () async {
    final service = CoachNotificationPromptService();
    await service.markAsked(CoachNotificationPrompt.enrolled);
    await service.markAsked(CoachNotificationPrompt.unreadReply);
    final container = _containerWith(
      user: _user,
      enrollment: _enrollment,
      sessions: [_session(coachReply: 'Nice work')],
    );

    expect(
      await container.read(pendingCoachNotificationPromptProvider.future),
      isNull,
    );
  });
}
