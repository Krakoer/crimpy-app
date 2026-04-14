import 'package:crimpy/logger.dart';
import 'package:crimpy/models/sync/sync_api_models.dart';
import 'package:crimpy/services/api/api_client.dart';
import 'package:dio/dio.dart';

class SyncApiService {
  final ApiClient _apiClient;

  SyncApiService(this._apiClient);

  Future<SyncSummaryResponse> getSyncSummary() async {
    try {
      final response = await _apiClient.dio.get('/api/sync/summary');
      return SyncSummaryResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      AppLoggerHelper.error('Failed to get sync summary: ${e.message}');
      rethrow;
    }
  }

  Future<SyncPullResponse> pullChanges(int sinceVersion) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/sync/pull',
        queryParameters: {'since_version': sinceVersion},
      );
      return SyncPullResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLoggerHelper.error('Failed to pull changes: ${e.message}');
      rethrow;
    }
  }

  Future<SyncPushResponse> pushChanges(SyncPushRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/sync/push',
        data: request.toJson(),
      );
      return SyncPushResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLoggerHelper.error('Failed to push changes: ${e.message}');
      rethrow;
    }
  }

  Future<SyncPushResponse> migrateData(SyncPushRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/sync/migrate',
        data: request.toJson(),
      );
      return SyncPushResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLoggerHelper.error('Failed to migrate data: ${e.message}');
      rethrow;
    }
  }
}
