import 'package:crimpy/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the request an endpoint method makes, so what it asks the server for
/// is pinned rather than stubbed over.
class _RecordingApiClient extends ApiClient {
  String? requestedPath;
  Map<String, dynamic>? requestedQuery;

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    requestedPath = path;
    requestedQuery = queryParameters;
    return Response<dynamic>(
      requestOptions: RequestOptions(path: path),
      data: <dynamic>[],
    );
  }
}

void main() {
  // The test binary carries no flavor and is not a release build, so it sees
  // the default every non-production build gets. Pinning it here is what stops
  // an edit to the stage logic from quietly pointing a debug run, or a beta APK
  // in a tester's hands, at the production database.
  test('the backend defaults away from production', () {
    expect(ApiClient.baseUrl, 'https://devapi.crimpy.app');
  });

  // Without the flag the server answers the catalog, which names no program, so
  // the app would list nothing a coach prescribed and have no error to show for
  // it. The flag is the whole difference between the two answers.
  test('the recordable assessments are asked for with the flag', () async {
    final client = _RecordingApiClient();

    await client.getRecordableAssessmentDefinitionsApi();

    expect(client.requestedPath, '/api/assessment-definitions');
    expect(client.requestedQuery, {'recordable': 'true'});
  });
}
