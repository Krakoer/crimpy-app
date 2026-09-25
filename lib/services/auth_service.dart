import 'package:crimpy/logger.dart';
import 'package:crimpy/models/auth_models.dart';
import 'package:crimpy/services/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: LoginRequest(email: email, password: password).toJson(),
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _apiClient.saveToken(authResponse.token);
    if (authResponse.refreshToken != null) {
      await _apiClient.saveRefreshToken(authResponse.refreshToken!);
    }

    AppLoggerHelper.info(
      'User logged in successfully: ${authResponse.user.email}',
    );
    return authResponse;
  }

  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: RegisterRequest(
        email: email,
        password: password,
        firstname: firstname,
        lastname: lastname,
        isCoach: false,
      ).toJson(),
    );

    final registerResponse = RegisterResponse.fromJson(response.data);

    AppLoggerHelper.info(
      'User registered successfully: ${registerResponse.user.email}',
    );
    return registerResponse;
  }

  Future<void> verifyEmail(String token) async {
    await _apiClient.post(
      '/auth/verify',
      data: VerifyEmailRequest(token: token).toJson(),
    );

    AppLoggerHelper.info('Email verified successfully');
  }

  Future<void> resendVerificationEmail(String email) async {
    await _apiClient.post(
      '/auth/resend-verification',
      data: ResendVerificationRequest(email: email).toJson(),
    );

    AppLoggerHelper.info('Verification email resent to: $email');
  }

  Future<void> requestPasswordReset(String email) async {
    await _apiClient.post('/auth/forgot-password', data: {'email': email});

    AppLoggerHelper.info('Password reset requested');
  }

  Future<User> getCurrentUser() async {
    final response = await _apiClient.get('/api/user');
    final user = User.fromJson(response.data);

    AppLoggerHelper.info('Fetched current user: ${user.email}');
    return user;
  }

  Future<void> logout() async {
    final refreshToken = await _apiClient.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _apiClient.post(
          '/auth/logout',
          data: {'refresh_token': refreshToken},
        );
      } catch (e) {
        AppLoggerHelper.error('Failed to revoke refresh token: $e');
      }
    }
    await _apiClient.clearToken();
    await _apiClient.clearRefreshToken();
    AppLoggerHelper.info('User logged out');
  }

  Future<bool> isLoggedIn() async {
    return await _apiClient.hasToken();
  }
}
