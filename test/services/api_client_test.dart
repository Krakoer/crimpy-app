import 'package:crimpy/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the request an endpoint method makes, so what it asks the server for
/// is pinned rather than stubbed over.
class _RecordingApiClient extends ApiClient {
  String? requestedPath;
  Map<String, dynamic>? requestedQuery;

  /// The headers the answer carries back, so the parsing that reads them can be
  /// driven. Every other test in the app fakes getTrainings whole, which leaves
  /// the header reading itself running in nothing.
  final Map<String, List<String>> responseHeaders;

  _RecordingApiClient({this.responseHeaders = const {}});

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
      headers: Headers.fromMap(responseHeaders),
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

  // The header is the app's half of a contract owned by crimpy-backend, and it
  // is the one line in the library read that no other test touches: every
  // viewmodel and repository test fakes getTrainings whole. Misspell the
  // constant and the whole suite still passes while the notice silently never
  // appears again.
  group('the truncated library header', () {
    test('is absent on a whole library', () async {
      final client = _RecordingApiClient();

      final page = await client.getTrainings(includeItems: true);

      expect(page.truncated, isFalse);
    });

    test('is read when the server cut the library', () async {
      final client = _RecordingApiClient(
        responseHeaders: {
          'X-Trainings-Truncated': ['true'],
        },
      );

      final page = await client.getTrainings(includeItems: true);

      expect(page.truncated, isTrue);
    });

    // Dio lowercases the keys it stores, and HTTP header values are not case
    // sensitive by convention, so neither spelling may be the one that decides
    // whether an athlete is told their library was cut.
    test('is read whatever case it arrives in', () async {
      final client = _RecordingApiClient(
        responseHeaders: {
          'x-trainings-truncated': ['True'],
        },
      );

      final page = await client.getTrainings(includeItems: true);

      expect(page.truncated, isTrue);
    });

    // A proxy that duplicates the header used to throw out of Headers.value and
    // take the whole library with it. Losing the rows to report a banner about
    // them is worse than any answer the banner could give.
    test('survives a header that arrives twice', () async {
      final client = _RecordingApiClient(
        responseHeaders: {
          'X-Trainings-Truncated': ['true', 'true'],
        },
      );

      final page = await client.getTrainings(includeItems: true);

      expect(page.truncated, isTrue);
      expect(page.rows, isEmpty);
    });

    // Anything that is not true is a whole library. A server that grew a second
    // value for this header must not be read as having cut anything.
    test('reads an unrecognised value as a whole library', () async {
      final client = _RecordingApiClient(
        responseHeaders: {
          'X-Trainings-Truncated': ['partial'],
        },
      );

      final page = await client.getTrainings(includeItems: true);

      expect(page.truncated, isFalse);
    });
  });
}
