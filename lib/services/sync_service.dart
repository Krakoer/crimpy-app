import 'package:crimpy/logger.dart';
import 'package:crimpy/models/sync_models.dart';
import 'package:crimpy/services/api_client.dart';

class SyncService {
  final ApiClient _apiClient;

  SyncService(this._apiClient);

  Future<SyncSummaryResponse> getSyncSummary() async {
    try {
      AppLoggerHelper.info('Fetching sync summary');
      final response = await _apiClient.get('/api/sync/summary');
      return SyncSummaryResponse.fromJson(response.data);
    } catch (e, s) {
      AppLoggerHelper.error(
        'Failed to fetch sync summary: $e (stacktrace: $s)',
      );
      rethrow;
    }
  }

  Future<PullResponse> pullChanges({int sinceVersion = 0}) async {
    try {
      AppLoggerHelper.info('Pulling changes since version $sinceVersion');
      final response = await _apiClient.get(
        '/api/sync/pull',
        queryParameters: {'since_version': sinceVersion},
      );
      return PullResponse.fromJson(response.data);
    } catch (e) {
      AppLoggerHelper.error('Failed to pull changes: $e');
      rethrow;
    }
  }

  Future<PushResponse> pushChanges(Map<String, dynamic> records) async {
    try {
      AppLoggerHelper.info(
        'Pushing ${records.length} collection(s) of changes',
      );
      final response = await _apiClient.post(
        '/api/sync/push',
        data: {'records': records},
      );
      return PushResponse.fromJson(response.data);
    } catch (e) {
      AppLoggerHelper.error('Failed to push changes: $e');
      rethrow;
    }
  }

  Future<PushResponse> migrateLocalData(Map<String, dynamic> records) async {
    try {
      AppLoggerHelper.info('Migrating local data to cloud');
      final response = await _apiClient.post(
        '/api/sync/migrate',
        data: {'records': records},
      );
      return PushResponse.fromJson(response.data);
    } catch (e) {
      AppLoggerHelper.error('Failed to migrate local data: $e');
      rethrow;
    }
  }
}
