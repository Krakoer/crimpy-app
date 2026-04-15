import 'package:crimpy/database/database.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart' as drift;

part 'auth_view_model.g.dart';

@riverpod
ApiClient apiClient(Ref ref) {
  return ApiClient();
}

@riverpod
AuthService authService(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
}

@riverpod
class AuthState extends _$AuthState {
  @override
  Future<auth_models.User?> build() async {
    final dbUser = await gDatabase.getCurrentUser();
    if (dbUser == null) return null;

    return auth_models.User(
      id: dbUser.id,
      email: dbUser.email,
      firstname: dbUser.firstname,
      lastname: dbUser.lastname,
      emailVerified: dbUser.emailVerified,
      isAdmin: dbUser.isAdmin,
      isCoach: dbUser.isCoach,
      coachValidated: dbUser.coachValidated,
      createdAt: dbUser.createdAt.toIso8601String(),
    );
  }

  Future<void> login(String email, String password) async {
    try {
      final authService = ref.read(authServiceProvider);
      final authResponse = await authService.login(email, password);

      await _saveUserToDb(authResponse.user);
      ref.invalidateSelf();

      AppLoggerHelper.info('Login successful');
    } catch (e) {
      AppLoggerHelper.error('Login error: $e');
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

      final currentUser = await gDatabase.getCurrentUser();
      if (currentUser != null) {
        await gDatabase.saveCurrentUser(
          UsersCompanion(
            id: drift.Value(currentUser.id),
            emailVerified: const drift.Value(true),
          ),
        );
        ref.invalidateSelf();
      }

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
      await gDatabase.deleteCurrentUser();
      ref.invalidateSelf();

      AppLoggerHelper.info('Logout successful');
    } catch (e) {
      AppLoggerHelper.error('Logout error: $e');
      rethrow;
    }
  }

  Future<void> _saveUserToDb(auth_models.User user) async {
    await gDatabase.saveCurrentUser(
      UsersCompanion.insert(
        id: user.id,
        email: user.email,
        firstname: user.firstname,
        lastname: user.lastname,
        emailVerified: drift.Value(user.emailVerified),
        isAdmin: drift.Value(user.isAdmin),
        isCoach: drift.Value(user.isCoach),
        coachValidated: drift.Value(user.coachValidated),
        // DateTime are in format "2006-01-02 15:04:05.999999999 +0000 UTC"
        createdAt: drift.Value(
          DateTime.parse(user.createdAt.replaceAll(" +0000 UTC", "")),
        ),
      ),
    );
  }
}
