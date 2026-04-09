import 'package:crimpy/models/sync/auth_models.dart';
import 'package:crimpy/services/api/api_client.dart';
import 'package:dio/dio.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Email already registered');
      }
      throw Exception('Registration failed: ${e.message}');
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials');
      }
      throw Exception('Login failed: ${e.message}');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    String? userId,
  }) async {
    try {
      await _apiClient.dio.put(
        '/api/auth/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          if (userId != null) 'user_id': userId,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid old password');
      }
      throw Exception('Password change failed: ${e.message}');
    }
  }
}
