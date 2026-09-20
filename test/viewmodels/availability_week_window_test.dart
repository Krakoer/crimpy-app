import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/availability_view_model.dart';
import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = auth_models.User(
  id: 'user-1',
  email: 'climber@example.com',
  firstname: 'Test',
  lastname: 'Climber',
  emailVerified: true,
  createdAt: '2026-01-01T00:00:00Z',
);

class _StubAuthState extends AuthState {
  @override
  Future<auth_models.User?> build() async => _user;
}

/// An API that applies the window the way the endpoint does: both bounds
/// inclusive, an absent bound unbounded.
class _WindowedApiClient extends ApiClient {
  final Set<DateTime> declared;
  final List<({String? from, String? to})> calls = [];

  _WindowedApiClient(this.declared);

  @override
  Future<List<Map<String, dynamic>>> getMyAvailability({
    String? from,
    String? to,
  }) async {
    calls.add((from: from, to: to));
    final weeks = declared.map(formatWeekStart).toList()..sort();
    return [
      for (final week in weeks)
        if ((from == null || week.compareTo(from) >= 0) &&
            (to == null || week.compareTo(to) <= 0))
          {
            'user_id': 'user-1',
            'week_start': week,
            'updated_at': '2026-01-01T00:00:00Z',
            'days': [
              for (var day = 0; day < 7; day++)
                {
                  'day_of_week': day,
                  'activities': [
                    if (day == 2) {'label': 'Bouldering in $week'},
                  ],
                },
            ],
          },
    ];
  }

  @override
  Future<List<String>> getMyDeclaredWeeks() async =>
      declared.map(formatWeekStart).toList()..sort();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final thisWeek = getStartOfWeek(DateTime.now());
  final inTwoWeeks = addCalendarDays(thisWeek, 14);
  // Far enough ahead that no editable window reaches it. The screen cannot
  // open it today, but a list pinned to an older day can be asked for it.
  final farAhead = addCalendarDays(thisWeek, 70);

  Future<MyAvailability> notifier(_WindowedApiClient api) async {
    final container = ProviderContainer.test(
      overrides: [
        authStateProvider.overrideWith(_StubAuthState.new),
        apiClientProvider.overrideWithValue(api),
      ],
    );
    await container.read(authStateProvider.future);
    return container.read(myAvailabilityProvider.notifier);
  }

  group('MyAvailability', () {
    test('asks for the three editable weeks rather than every week', () async {
      final api = _WindowedApiClient({thisWeek, farAhead});

      final held = await (await notifier(api)).future;

      expect(held.weeks.map((week) => week.weekStart), [thisWeek]);
      expect(held.window.from, thisWeek);
      expect(held.window.to, inTwoWeeks);
      expect(api.calls.single.from, formatWeekStart(thisWeek));
      expect(api.calls.single.to, formatWeekStart(inTwoWeeks));
    });

    test('reads a declared week inside the window off the list', () async {
      final api = _WindowedApiClient({inTwoWeeks});

      final read = await (await notifier(api)).weekOf(inTwoWeeks);

      expect(read.declared, isTrue);
      expect(read.week.weekStart, inTwoWeeks);
      expect(api.calls, hasLength(1));
    });

    test('an undeclared week inside the window reads as blank', () async {
      final api = _WindowedApiClient({thisWeek});

      final read = await (await notifier(api)).weekOf(inTwoWeeks);

      expect(read.declared, isFalse);
      expect(read.week.weekStart, inTwoWeeks);
      expect(api.calls, hasLength(1));
    });

    // The regression the window itself could introduce: a week the list was
    // never asked for is not a week the athlete never declared. Answering it
    // off the list would offer them a blank week to overwrite what they sent.
    test('fetches a declared week the window did not cover', () async {
      final api = _WindowedApiClient({farAhead});

      final read = await (await notifier(api)).weekOf(farAhead);

      expect(read.declared, isTrue);
      expect(read.week.weekStart, farAhead);
      expect(read.week.days[2].activities.single.label, contains('Bouldering'));
      expect(api.calls, hasLength(2));
      expect(api.calls.last.from, formatWeekStart(farAhead));
      expect(api.calls.last.to, formatWeekStart(farAhead));
    });

    test(
      'a week outside the window that was never declared is blank',
      () async {
        final api = _WindowedApiClient({thisWeek});

        final read = await (await notifier(api)).weekOf(farAhead);

        expect(read.declared, isFalse);
        expect(read.week.weekStart, farAhead);
      },
    );
  });
}
