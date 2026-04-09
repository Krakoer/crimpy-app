import 'package:crimpy/models/sync/api_models.dart';
import 'package:crimpy/services/api/api_client.dart';
import 'package:dio/dio.dart';

class RepeaterApiService {
  final ApiClient _apiClient;

  RepeaterApiService(this._apiClient);

  Future<RepeaterResponse> getRepeater(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/repeaters/$id');
      return RepeaterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch repeater: ${e.message}');
    }
  }

  Future<RepeaterResponse> createRepeater(CreateRepeaterRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/repeaters',
        data: request.toJson(),
      );
      return RepeaterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create repeater: ${e.message}');
    }
  }

  Future<RepeaterResponse> updateRepeater(
    int id,
    UpdateRepeaterRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/repeaters/$id',
        data: request.toJson(),
      );
      return RepeaterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update repeater: ${e.message}');
    }
  }

  Future<void> deleteRepeater(int id) async {
    try {
      await _apiClient.dio.delete('/api/repeaters/$id');
    } on DioException catch (e) {
      throw Exception('Failed to delete repeater: ${e.message}');
    }
  }
}
