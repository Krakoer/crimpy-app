import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/repositories/bodyweight_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/bodyweight_service.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
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

class _StubAuthState extends AuthState {
  _StubAuthState(this._user);

  final auth_models.User? _user;

  @override
  Future<auth_models.User?> build() async => _user;
}

/// Auth as it behaves on a cold start: still pending when the rest of the app
/// first asks for the bodyweight, resolving a moment later.
class _SlowAuthState extends AuthState {
  _SlowAuthState(this._user);

  final auth_models.User? _user;

  @override
  Future<auth_models.User?> build() =>
      Future.delayed(const Duration(milliseconds: 50), () => _user);
}

/// Counts what reached the server, so these tests say what they mean about the
/// write through instead of leaning on the fact that a real Dio client cannot
/// reach one under flutter_test.
class _FakeApiClient extends ApiClient {
  final List<double> created = [];

  @override
  Future<Map<String, dynamic>> createBodyweight(
    double weightKg,
    DateTime measuredAt,
  ) async {
    created.add(weightKg);
    return {
      'id': 'bw-1',
      'user_id': 'u-1',
      'weight_kg': weightKg,
      'measured_at': measuredAt.toUtc().toIso8601String(),
      'created_at': measuredAt.toUtc().toIso8601String(),
    };
  }
}

late _FakeApiClient _api;

ProviderContainer _containerFor(AuthState Function() auth) {
  _api = _FakeApiClient();
  return ProviderContainer.test(
    overrides: [
      authStateProvider.overrideWith(auth),
      bodyweightRepositoryProvider.overrideWithValue(
        BodyweightRepository(_api),
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bodyweight', () {
    test('is unknown until it is entered', () async {
      SharedPreferences.setMockInitialValues({});
      final container = _containerFor(() => _StubAuthState(_user));

      expect(await container.read(bodyweightProvider.future), isNull);
    });

    test('a saved weight is kept on the device', () async {
      SharedPreferences.setMockInitialValues({});
      final container = _containerFor(() => _StubAuthState(_user));
      await container.read(bodyweightProvider.future);

      await container.read(bodyweightProvider.notifier).set(68.5);

      expect(container.read(bodyweightProvider).value, 68.5);
      expect(await BodyweightService().load(), 68.5);
      // And it reaches the server, which is the half that makes it the coach's
      // to read. Awaited through the provider rather than slept on.
      await container.read(bodyweightRepositoryProvider).flushPending();
      expect(_api.created, [68.5]);
    });

    test('a stored weight is read back on the next launch', () async {
      SharedPreferences.setMockInitialValues({'bodyweight_kg': 72.0});
      final container = _containerFor(() => _StubAuthState(_user));

      expect(await container.read(bodyweightProvider.future), 72.0);
    });

    test('a signed out device drops the weight of the previous user', () async {
      // The regression this guards: the next user to sign in on the device had
      // their %BW loads resolved against the weight of the one before them.
      SharedPreferences.setMockInitialValues({'bodyweight_kg': 80.0});
      final container = _containerFor(() => _StubAuthState(null));

      expect(await container.read(bodyweightProvider.future), isNull);
      expect(await BodyweightService().load(), isNull);
      // The pending marker goes with it, or the next account files a weight
      // that was never theirs.
      expect(
        await container.read(bodyweightRepositoryProvider).hasPending(),
        isFalse,
      );
    });

    test('the weight survives a cold start, and the wait for it ends', () async {
      // Two regressions in one: auth is loading on every launch, and reading
      // that as a sign out wiped the weight each time. Answering before auth
      // lands is just as bad, because the rebuild that follows strands whoever
      // was awaiting the first future, hanging the start of a training.
      SharedPreferences.setMockInitialValues({'bodyweight_kg': 72.0});
      final container = _containerFor(() => _SlowAuthState(_user));

      expect(
        await container
            .read(bodyweightProvider.future)
            .timeout(const Duration(seconds: 5)),
        72.0,
      );
      expect(await BodyweightService().load(), 72.0);
    });
  });
}
