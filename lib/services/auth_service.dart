import 'package:crimpy/logger.dart';
import 'package:crimpy/models/auth_models.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: LoginRequest(email: email, password: password).toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _apiClient.saveToken(authResponse.token);

      AppLoggerHelper.info(
        'User logged in successfully: ${authResponse.user.email}',
      );
      return authResponse;
    } on DioException catch (e) {
      AppLoggerHelper.error('Login failed: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    bool isCoach = false,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data:
            RegisterRequest(
              email: email,
              password: password,
              firstname: firstname,
              lastname: lastname,
              isCoach: isCoach,
            ).toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _apiClient.saveToken(authResponse.token);

      AppLoggerHelper.info(
        'User registered successfully: ${authResponse.user.email}',
      );
      return authResponse;
    } on DioException catch (e) {
      AppLoggerHelper.error(
        'Registration failed: ${e.response?.data ?? e.message}',
      );
      rethrow;
    }
  }

  Future<void> verifyEmail(String token) async {
    try {
      await _apiClient.post(
        '/auth/verify',
        data: VerifyEmailRequest(token: token).toJson(),
      );

      AppLoggerHelper.info('Email verified successfully');
    } on DioException catch (e) {
      AppLoggerHelper.error(
        'Email verification failed: ${e.response?.data ?? e.message}',
      );
      rethrow;
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    try {
      await _apiClient.post(
        '/auth/resend-verification',
        data: ResendVerificationRequest(email: email).toJson(),
      );

      AppLoggerHelper.info('Verification email resent to: $email');
    } on DioException catch (e) {
      AppLoggerHelper.error(
        'Resend verification failed: ${e.response?.data ?? e.message}',
      );
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/api/user');
      final user = User.fromJson(response.data);

      AppLoggerHelper.info('Fetched current user: ${user.email}');
      return user;
    } on DioException catch (e) {
      AppLoggerHelper.error(
        'Get current user failed: ${e.response?.data ?? e.message}',
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
    AppLoggerHelper.info('User logged out');
  }

  Future<bool> isLoggedIn() async {
    return await _apiClient.hasToken();
  }
}
