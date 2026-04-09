import 'package:crimpy/models/sync/api_models.dart';
import 'package:crimpy/services/api/api_client.dart';
import 'package:dio/dio.dart';

class TrainingApiService {
  final ApiClient _apiClient;

  TrainingApiService(this._apiClient);

  Future<List<TrainingResponse>> getAllTrainings() async {
    try {
      final response = await _apiClient.dio.get('/api/trainings');
      return (response.data as List)
          .map((json) => TrainingResponse.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch trainings: ${e.message}');
    }
  }

  Future<TrainingResponse> getTraining(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/trainings/$id');
      return TrainingResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch training: ${e.message}');
    }
  }

  Future<TrainingResponse> createTraining(CreateTrainingRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/trainings',
        data: request.toJson(),
      );
      return TrainingResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create training: ${e.message}');
    }
  }

  Future<TrainingResponse> updateTraining(
    int id,
    UpdateTrainingRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/trainings/$id',
        data: request.toJson(),
      );
      return TrainingResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update training: ${e.message}');
    }
  }

  Future<void> deleteTraining(int id) async {
    try {
      await _apiClient.dio.delete('/api/trainings/$id');
    } on DioException catch (e) {
      throw Exception('Failed to delete training: ${e.message}');
    }
  }
}
