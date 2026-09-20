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

  // The window is the whole point of the call, and the server only applies it
  // under these two names. A key renamed here answers the athlete's entire
  // history instead, which is what this endpoint was bounded to stop, and no
  // viewmodel test would notice because they all stub this method.
  test('the availability window is asked for as from and to', () async {
    final client = _RecordingApiClient();

    await client.getMyAvailability(from: '2026-01-05', to: '2026-01-19');

    expect(client.requestedPath, '/api/user/availability');
    expect(client.requestedQuery, {'from': '2026-01-05', 'to': '2026-01-19'});
  });

  // An absent bound is left out rather than sent as null, which the server
  // reads as unbounded on that side.
  test('an absent bound is not sent at all', () async {
    final client = _RecordingApiClient();

    await client.getMyAvailability();

    expect(client.requestedQuery, isEmpty);
  });

  // The reminder planner reads this path and nothing else. A typo answers 404,
  // the plan falls back to the device mirror, and the athlete is nudged about
  // weeks they already declared.
  test('the declared weeks are read off their own endpoint', () async {
    final client = _RecordingApiClient();

    await client.getMyDeclaredWeeks();

    expect(client.requestedPath, '/api/user/availability/declared-weeks');
  });
}
