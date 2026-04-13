import 'package:crimpy/database/database.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/sync/auth_models.dart';
import 'package:crimpy/services/api/api_client.dart';
import 'package:crimpy/services/api/auth_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late final AuthApiService _authService;
  late final ApiClient _apiClient;
  late final AppDatabase _database;

  @override
  AuthState build() {
    _apiClient = ApiClient();
    _authService = AuthApiService(_apiClient);
    _database = gDatabase;
    _loadAuthState();
    return const AuthState();
  }

  Future<void> _loadAuthState() async {
    final profile = await _database.getUserProfile();
    if (profile != null && await _apiClient.getToken() != null) {
      state = AuthState(
        isAuthenticated: true,
        userId: profile.id,
        email: profile.email,
        firstname: profile.firstname,
        lastname: profile.lastname,
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);

      await _apiClient.saveToken(response.token);
      await _database.saveUserProfile(
        id: response.user.id,
        email: response.user.email,
        firstname: response.user.firstname,
        lastname: response.user.lastname,
      );

      state = AuthState(
        isAuthenticated: true,
        userId: response.user.id,
        email: response.user.email,
        firstname: response.user.firstname,
        lastname: response.user.lastname,
      );

      AppLoggerHelper.info('Login successful for user: ${response.user.email}');
    } catch (e) {
      AppLoggerHelper.error('Login failed: $e');
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? firstname,
    String? lastname,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        firstname: firstname,
        lastname: lastname,
      );
      final response = await _authService.register(request);

      await _apiClient.saveToken(response.token);
      await _database.saveUserProfile(
        id: response.user.id,
        email: response.user.email,
        firstname: response.user.firstname,
        lastname: response.user.lastname,
      );

      state = AuthState(
        isAuthenticated: true,
        userId: response.user.id,
        email: response.user.email,
        firstname: response.user.firstname,
        lastname: response.user.lastname,
      );

      AppLoggerHelper.info(
        'Registration successful for user: ${response.user.email}',
      );
    } catch (e) {
      AppLoggerHelper.error('Registration failed: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.clearToken();
      await _database.deleteUserProfile();

      state = const AuthState(isAuthenticated: false);

      AppLoggerHelper.info('User logged out');
    } catch (e) {
      AppLoggerHelper.error('Logout failed: $e');
      rethrow;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        userId: state.userId,
      );

      AppLoggerHelper.info('Password changed successfully');
    } catch (e) {
      AppLoggerHelper.error('Password change failed: $e');
      rethrow;
    }
  }
}
