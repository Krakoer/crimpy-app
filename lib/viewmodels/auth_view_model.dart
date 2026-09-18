import 'package:crimpy/logger.dart';
import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/repositories/remote_assessment_repository.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/repositories/user_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/auth_service.dart';
import 'package:crimpy/services/local_data_migration.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final client = ApiClient();
  client.onUnauthorized = () => ref.invalidate(authStateProvider);
  ref.onDispose(client.dispose);
  return client;
}

/// Whether device-local settings belong to nobody and must be dropped.
///
/// Only a resolved absence of user counts. The auth state reads the stored user
/// and its tokens asynchronously, so it is loading on every cold start, and
/// treating that as a sign out would wipe the settings on each launch. An auth
/// failure keeps them too: it says nothing about who owns them.
bool isSignedOut(AsyncValue<auth_models.User?> auth) => switch (auth) {
  // Auth state is read from the device and invalidated by signing in or out,
  // which is a change of who is looking rather than a refresh of what they see.
  // ignore: keep_the_held_value
  AsyncData(:final value) => value == null,
  _ => false,
};

/// The auth state once it has stopped loading, for the providers that must not
/// answer while it is pending. Reading it unsettled means reading the cold
/// start, where nobody is signed in yet and no device-local data is safe to
/// judge. An auth failure comes back as an error rather than as an absence, so
/// [isSignedOut] keeps the settings for it.
Future<AsyncValue<auth_models.User?>> settledAuth(Ref ref) async {
  try {
    return AsyncData(await ref.watch(authStateProvider.future));
  } catch (error, stackTrace) {
    return AsyncError(error, stackTrace);
  }
}

/// Whether a user is signed in. Repositories watch this rather than the whole
/// auth state: it only changes when the user signs in or out, so refreshing the
/// profile no longer tears down and refetches every list in the app.
@Riverpod(keepAlive: true)
bool isAuthenticated(Ref ref) =>
    // Auth state is read from the device and invalidated by signing in or out,
    // which is a change of who is looking rather than a refresh of what they see.
    // ignore: keep_the_held_value
    ref.watch(authStateProvider).asData?.value != null;

/// Uploads guest-mode data to the API after a sign in.
@Riverpod(keepAlive: true)
LocalDataMigration localDataMigration(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LocalDataMigration(
    apiClient: apiClient,
    remoteTrainings: RemoteTrainingRepository(
      apiClient,
      bodyweight: ref.watch(bodyweightRepositoryProvider),
    ),
    remoteAssessments: RemoteAssessmentRepository(apiClient),
  );
}

/// Persists the signed-in user on the device.
@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) => UserRepository();

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
}

@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  Future<auth_models.User?> build() async {
    final user = await ref.read(userRepositoryProvider).currentUser();
    if (user == null) return null;

    // A stored user with no credentials at all is a stale, inconsistent state
    // (e.g. tokens were cleared after a failed refresh). Treat it as logged out
    // so the app falls back to guest mode instead of looping on unauthorized
    // requests. A refresh token alone is enough: a new access token is minted
    // on the first request.
    final apiClient = ref.read(apiClientProvider);
    final hasAccessToken = await apiClient.hasToken();
    final refreshToken = await apiClient.getRefreshToken();
    if (!hasAccessToken && (refreshToken == null || refreshToken.isEmpty)) {
      return null;
    }

    return user;
  }

  Future<void> login(String email, String password) async {
    try {
      final authService = ref.read(authServiceProvider);
      final authResponse = await authService.login(email, password);

      await _saveUserToDb(authResponse.user);
      ref.invalidateSelf();

      AppLoggerHelper.info('Login successful');
    } catch (e, s) {
      AppLoggerHelper.error('Login error: $e (stacktrace: $s)');
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    bool isCoach = false,
  }) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.register(
        email: email,
        password: password,
        firstname: firstname,
        lastname: lastname,
      );

      ref.invalidateSelf();

      AppLoggerHelper.info('Registration successful');
    } catch (e) {
      AppLoggerHelper.error('Registration error: $e');
      rethrow;
    }
  }

  Future<void> verifyEmail(String token) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyEmail(token);

      await ref.read(userRepositoryProvider).markEmailVerified();
      ref.invalidateSelf();

      AppLoggerHelper.info('Email verification successful');
    } catch (e) {
      AppLoggerHelper.error('Email verification error: $e');
      rethrow;
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.resendVerificationEmail(email);

      AppLoggerHelper.info('Verification email resent');
    } catch (e) {
      AppLoggerHelper.error('Resend verification error: $e');
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.getCurrentUser();

      await _saveUserToDb(user);
      ref.invalidateSelf();

      AppLoggerHelper.info('User data refreshed');
    } catch (e) {
      AppLoggerHelper.error('Refresh user error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();

      await ref.read(userRepositoryProvider).clear();

      ref.invalidate(sensorPresetsProvider);
      ref.invalidateSelf();

      AppLoggerHelper.info('Logout successful, data providers invalidated');
    } catch (e) {
      AppLoggerHelper.error('Logout error: $e');
      rethrow;
    }
  }

  Future<LocalImportStatus> checkLocalDataBeforeLogin() =>
      ref.read(localDataMigrationProvider).pendingData();

  /// Uploads the guest data to the account that just signed in. The user id is
  /// read from storage rather than taken on trust: the import marks are kept
  /// per account, and marking a row against the wrong one loses it.
  Future<int> importLocalDataToApi() async {
    final user = await ref.read(userRepositoryProvider).currentUser();
    if (user == null) {
      AppLoggerHelper.error(
        'Local data import asked for with nobody signed in',
      );
      return 0;
    }
    return ref.read(localDataMigrationProvider).uploadAll(user.id);
  }

  Future<void> clearLocalDataAfterLogin() async {
    await ref.read(localDataMigrationProvider).clearLocalData();
    ref.invalidate(sensorPresetsProvider);
    ref.invalidateSelf();
  }

  Future<void> _saveUserToDb(auth_models.User user) =>
      ref.read(userRepositoryProvider).save(user);
}
