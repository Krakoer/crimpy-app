import 'dart:convert';

import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/models/notification_preferences.dart';
import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/notification_preferences_service.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/availability_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _user = auth_models.User(
  id: 'user-1',
  email: 'climber@example.com',
  firstname: 'Test',
  lastname: 'Climber',
  emailVerified: true,
  createdAt: '2026-01-01T00:00:00Z',
);

/// Auth as it behaves on a cold start: still pending when the app shell first
/// watches the reminder sync, resolving a moment later.
class _SlowAuthState extends AuthState {
  _SlowAuthState(this._user);

  final auth_models.User? _user;

  @override
  Future<auth_models.User?> build() =>
      Future.delayed(const Duration(milliseconds: 50), () => _user);
}

class _StubAuthState extends AuthState {
  _StubAuthState(this._user);

  final auth_models.User? _user;

  @override
  Future<auth_models.User?> build() async => _user;
}

/// The launch the mirror exists for: signed in, but nothing reaches the API.
/// Stubbed at the client rather than at the repository, because the repository
/// provider going null while auth is pending is the very window under test.
class _OfflineApiClient extends ApiClient {
  @override
  Future<Map<String, dynamic>> getAvailabilityReminder() async =>
      throw Exception('offline');

  @override
  Future<List<Map<String, dynamic>>> getMyAvailability({
    String? from,
    String? to,
  }) async => throw Exception('offline');

  @override
  Future<List<String>> getMyDeclaredWeeks() async => throw Exception('offline');
}

/// An API that answers the way the real one does now: the week list is bounded
/// to the window it was asked for, the declared weeks are not bounded at all.
///
/// The week it returns is built at the window's own near bound, so the test
/// does not have to know which week it is running in.
class _WindowedApiClient extends ApiClient {
  /// A declared week far enough back that no editable window reaches it.
  static final oldDeclaredWeek = DateTime(2026, 1, 5);

  String? lastFrom;

  @override
  Future<Map<String, dynamic>> getAvailabilityReminder() async => {
    'enabled': true,
    'day_of_week': 4,
    'hour': 21,
    'minute': 0,
  };

  @override
  Future<List<Map<String, dynamic>>> getMyAvailability({
    String? from,
    String? to,
  }) async {
    lastFrom = from;
    return [
      {
        'user_id': 'user-1',
        'week_start': from,
        'updated_at': '2026-01-01T00:00:00Z',
        'days': [
          for (var day = 0; day < 7; day++)
            {'day_of_week': day, 'activities': <Map<String, dynamic>>[]},
        ],
      },
    ];
  }

  @override
  Future<List<String>> getMyDeclaredWeeks() async => [
    formatWeekStart(oldDeclaredWeek),
    if (lastFrom != null) lastFrom!,
  ];
}

final _storedPlan = CachedAvailabilityPlan(
  reminder: const CoachAvailabilityReminder(
    enabled: true,
    dayOfWeek: 4,
    time: ReminderTime(21, 0),
  ),
  declaredWeekStarts: {DateTime(2026, 8, 24)},
);

Map<String, Object> _mirror() => {
  'availability_reminder_plan': jsonEncode(_storedPlan.toJson()),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('availability plan cache', () {
    test(
      'the mirror survives a cold start that never reaches the API',
      () async {
        // The regression this guards: the auth state is pending on every launch,
        // so the repository is null and the mirror was deleted before auth had
        // said anything. An athlete opening the app offline then lost the nudge
        // their coach set, with nothing left on the device to restore it from.
        SharedPreferences.setMockInitialValues(_mirror());
        final container = ProviderContainer.test(
          overrides: [
            authStateProvider.overrideWith(() => _SlowAuthState(_user)),
            apiClientProvider.overrideWithValue(_OfflineApiClient()),
          ],
        );

        final plan = await container
            .read(availabilityPlanCacheProvider.future)
            .timeout(const Duration(seconds: 5));

        expect(plan?.reminder?.enabled, isTrue);
        expect(plan?.declaredWeekStarts, {DateTime(2026, 8, 24)});
        expect(
          (await NotificationPreferencesService().loadAvailabilityPlan())
              ?.reminder
              ?.time
              .hour,
          21,
        );
      },
    );

    // The regression bounding the week list could introduce silently: the
    // planner drops a nudge for a week already answered, so a set of declared
    // weeks taken from the windowed list forgets every week outside the window
    // and nudges the athlete about weeks they have already sent.
    //
    // Point availabilityPlanCache at myAvailabilityProvider again and this
    // fails: the windowed list never carries oldDeclaredWeek.
    test(
      'the plan holds a declared week the windowed list never carried',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final api = _WindowedApiClient();
        final container = ProviderContainer.test(
          overrides: [
            authStateProvider.overrideWith(() => _StubAuthState(_user)),
            apiClientProvider.overrideWithValue(api),
          ],
        );

        // Waited on first, so the repository exists by the time the plan is
        // built: isAuthenticated reads the resolved auth state, and the plan
        // would otherwise answer from the mirror on its first pass.
        await container.read(authStateProvider.future);

        final plan = await container
            .read(availabilityPlanCacheProvider.future)
            .timeout(const Duration(seconds: 5));

        expect(
          plan?.declaredWeekStarts,
          contains(_WindowedApiClient.oldDeclaredWeek),
        );

        // The premise the assertion above rests on: the week list really is
        // windowed and really does not carry that week, so the plan can only
        // have learned it from the unwindowed read.
        final held = await container.read(myAvailabilityProvider.future);
        expect(
          held.weeks.map((week) => week.weekStart),
          isNot(contains(_WindowedApiClient.oldDeclaredWeek)),
        );
        expect(held.weeks, hasLength(1));
        expect(held.window.covers(_WindowedApiClient.oldDeclaredWeek), isFalse);
      },
    );

    test(
      'a signed out device drops the plan of the previous athlete',
      () async {
        // The other half: a resolved absence of user does have to clear it, or
        // the next account on the device inherits someone else's nudge.
        SharedPreferences.setMockInitialValues(_mirror());
        final container = ProviderContainer.test(
          overrides: [
            authStateProvider.overrideWith(() => _StubAuthState(null)),
          ],
        );

        expect(
          await container.read(availabilityPlanCacheProvider.future),
          isNull,
        );
        expect(
          await NotificationPreferencesService().loadAvailabilityPlan(),
          isNull,
        );
      },
    );
  });
}
