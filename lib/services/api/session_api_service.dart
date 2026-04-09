import 'package:crimpy/models/sync/api_models.dart';
import 'package:crimpy/services/api/api_client.dart';
import 'package:dio/dio.dart';

class SessionApiService {
  final ApiClient _apiClient;

  SessionApiService(this._apiClient);

  Future<List<SessionResponse>> getAllSessions() async {
    try {
      final response = await _apiClient.dio.get('/api/sessions');
      return (response.data as List)
          .map((json) => SessionResponse.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch sessions: ${e.message}');
    }
  }

  Future<SessionResponse> getSession(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/sessions/$id');
      return SessionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch session: ${e.message}');
    }
  }

  Future<SessionResponse> createSession(CreateSessionRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/sessions',
        data: request.toJson(),
      );
      return SessionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create session: ${e.message}');
    }
  }

  Future<SessionResponse> updateSession(
    int id,
    UpdateSessionRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/sessions/$id',
        data: request.toJson(),
      );
      return SessionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update session: ${e.message}');
    }
  }

  Future<void> deleteSession(int id) async {
    try {
      await _apiClient.dio.delete('/api/sessions/$id');
    } on DioException catch (e) {
      throw Exception('Failed to delete session: ${e.message}');
    }
  }
}
