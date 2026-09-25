import 'dart:convert';

import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers each path from a table, standing in for the backend so the 401
/// handling runs against real Dio rather than a faked get.
class _ScriptedAdapter implements HttpClientAdapter {
  final Map<String, ResponseBody Function(RequestOptions options)> routes;
  final List<String> requestedPaths = [];

  _ScriptedAdapter(this.routes);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedPaths.add(options.path);
    final route = routes[options.path];
    if (route == null) throw StateError('No route for ${options.path}');
    return route(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

ResponseBody Function(RequestOptions) _expiredUnlessFresh(
  ResponseBody Function() answer,
) =>
    (options) => options.headers['Authorization'] == 'Bearer fresh'
    ? answer()
    : _json(401, {'error': 'Invalid or expired token'});

/// Secure storage whose access token writes fail, the way a keystore that
/// went unavailable mid refresh does, while every other key works.
class _AccessTokenWriteFailingStorage extends FlutterSecureStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    if (key == ApiClient.tokenKey) {
      throw PlatformException(code: 'keystore_unavailable');
    }
    return super.write(
      key: key,
      value: value,
      iOptions: iOptions,
      aOptions: aOptions,
      lOptions: lOptions,
      webOptions: webOptions,
      mOptions: mOptions,
      wOptions: wOptions,
    );
  }
}

void main() {
  late int unauthorizedCalls;

  setUp(() {
    unauthorizedCalls = 0;
    FlutterSecureStorage.setMockInitialValues({
      ApiClient.tokenKey: 'expired',
      ApiClient.refreshTokenKey: 'still-valid',
    });
  });

  ApiClient clientFor(_ScriptedAdapter adapter) =>
      ApiClient(httpClientAdapter: adapter)
        ..onUnauthorized = () => unauthorizedCalls++;

  final refreshed = {
    '/auth/refresh': (_) =>
        _json(200, {'token': 'fresh', 'refresh_token': 'rotated'}),
  };

  // The access token lives an hour, so the first request of nearly every cold
  // start is a 401 that a refresh answers. An athlete with no coach gets a 404
  // for their enrollment on the retry, and that used to sign them out.
  test('a retry that fails for its own reasons keeps the session', () async {
    final client = clientFor(
      _ScriptedAdapter({
        ...refreshed,
        '/api/user/enrollment': _expiredUnlessFresh(
          () => _json(404, {'error': 'No enrollment'}),
        ),
      }),
    );

    await expectLater(
      client.getUserEnrollment(),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 404)),
    );

    expect(await client.getToken(), 'fresh');
    expect(await client.getRefreshToken(), 'rotated');
    expect(unauthorizedCalls, 0);
  });

  test('a refreshed request is answered on the retry', () async {
    final client = clientFor(
      _ScriptedAdapter({
        ...refreshed,
        '/api/sessions': _expiredUnlessFresh(() => _json(200, [])),
      }),
    );

    expect(await client.getSessions(), isEmpty);
    expect(unauthorizedCalls, 0);
  });

  // Opening the app in a gym basement must not cost the athlete their sign in:
  // the server never saw the refresh token, so nothing says it is wrong.
  test('a refresh that never reached the server keeps the session', () async {
    final client = clientFor(
      _ScriptedAdapter({
        '/auth/refresh': (options) => throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        ),
        '/api/sessions': _expiredUnlessFresh(() => _json(200, [])),
      }),
    );

    await expectLater(
      client.getSessions(),
      throwsA(isA<ApiException>().having((e) => e.isOffline, 'offline', true)),
    );

    expect(await client.getToken(), 'expired');
    expect(await client.getRefreshToken(), 'still-valid');
    expect(unauthorizedCalls, 0);
  });

  test('a server error on refresh keeps the session', () async {
    final client = clientFor(
      _ScriptedAdapter({
        '/auth/refresh': (_) => _json(500, {'error': 'Failed to refresh'}),
        '/api/sessions': _expiredUnlessFresh(() => _json(200, [])),
      }),
    );

    await expectLater(client.getSessions(), throwsA(isA<ApiException>()));

    expect(await client.getRefreshToken(), 'still-valid');
    expect(unauthorizedCalls, 0);
  });

  test('a refresh token the server turns down ends the session', () async {
    final client = clientFor(
      _ScriptedAdapter({
        '/auth/refresh': (_) => _json(401, {'error': 'Invalid refresh token'}),
        '/api/sessions': _expiredUnlessFresh(() => _json(200, [])),
      }),
    );

    await expectLater(client.getSessions(), throwsA(isA<ApiException>()));

    expect(await client.getToken(), isNull);
    expect(await client.getRefreshToken(), isNull);
    expect(unauthorizedCalls, 1);
  });

  test('a fresh access token turned away ends the session', () async {
    final client = clientFor(
      _ScriptedAdapter({
        ...refreshed,
        '/api/sessions': (_) => _json(401, {'error': 'Invalid token'}),
      }),
    );

    await expectLater(client.getSessions(), throwsA(isA<ApiException>()));

    expect(await client.getRefreshToken(), isNull);
    expect(unauthorizedCalls, 1);
  });

  // Several requests fire at once on a cold start. The refresh token rotates,
  // so a second refresh with the one the first spent would be turned down.
  test('concurrent 401s share one refresh', () async {
    final adapter = _ScriptedAdapter({
      ...refreshed,
      '/api/sessions': _expiredUnlessFresh(() => _json(200, [])),
      '/api/repeaters': _expiredUnlessFresh(() => _json(200, [])),
    });
    final client = clientFor(adapter);

    await Future.wait([client.getSessions(), client.getRepeaters()]);

    expect(adapter.requestedPaths.where((p) => p == '/auth/refresh').length, 1);
    expect(unauthorizedCalls, 0);
  });

  // The auth limiter allows 20 calls a minute per address, and a gym Wi-Fi puts
  // every athlete in the room behind one. Being throttled is not being denied.
  test('a throttled refresh keeps the session', () async {
    final client = clientFor(
      _ScriptedAdapter({
        '/auth/refresh': (_) => _json(429, {'error': 'Too many requests'}),
        '/api/sessions': _expiredUnlessFresh(() => _json(200, [])),
      }),
    );

    await expectLater(
      client.getSessions(),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 429)),
    );

    expect(await client.getRefreshToken(), 'still-valid');
    expect(unauthorizedCalls, 0);
  });

  test('a refresh the server reads as malformed ends the session', () async {
    final client = clientFor(
      _ScriptedAdapter({
        '/auth/refresh': (_) => _json(400, {'error': 'Refresh token required'}),
        '/api/sessions': _expiredUnlessFresh(() => _json(200, [])),
      }),
    );

    await expectLater(client.getSessions(), throwsA(isA<ApiException>()));

    expect(await client.getRefreshToken(), isNull);
    expect(unauthorizedCalls, 1);
  });

  // With nothing to refresh with, the 401 is the last word on the session.
  test('no refresh token stored ends the session', () async {
    FlutterSecureStorage.setMockInitialValues({ApiClient.tokenKey: 'expired'});
    final adapter = _ScriptedAdapter({
      '/api/sessions': _expiredUnlessFresh(() => _json(200, [])),
    });
    final client = clientFor(adapter);

    await expectLater(client.getSessions(), throwsA(isA<ApiException>()));

    expect(adapter.requestedPaths, isNot(contains('/auth/refresh')));
    expect(await client.getToken(), isNull);
    expect(unauthorizedCalls, 1);
  });

  // An answer the app cannot use is a server fault, and must not reach the
  // athlete as a sign in they got wrong.
  test('a refresh answer without a token keeps the session', () async {
    final client = clientFor(
      _ScriptedAdapter({
        '/auth/refresh': (_) => _json(200, {'refresh_token': 'rotated'}),
        '/api/sessions': _expiredUnlessFresh(() => _json(200, [])),
      }),
    );

    await expectLater(
      client.getSessions(),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'status', isNot(401))
            .having((e) => e.isOffline, 'offline', false),
      ),
    );

    expect(await client.getRefreshToken(), 'rotated');
    expect(unauthorizedCalls, 0);
  });

  // The server revoked the old refresh token before it answered, so the one it
  // sent back is the only one still worth anything, whatever fails after it.
  test('an access token that cannot be stored keeps the rotated one', () async {
    final storage = _AccessTokenWriteFailingStorage();
    final client = ApiClient(
      storage: storage,
      httpClientAdapter: _ScriptedAdapter({
        ...refreshed,
        '/api/sessions': _expiredUnlessFresh(() => _json(200, [])),
      }),
    )..onUnauthorized = () => unauthorizedCalls++;

    await expectLater(
      client.getSessions(),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 200)),
    );

    expect(await client.getRefreshToken(), 'rotated');
    expect(unauthorizedCalls, 0);
  });

  test('a retry that loses its connection keeps the session', () async {
    final client = clientFor(
      _ScriptedAdapter({
        ...refreshed,
        '/api/sessions': (options) =>
            options.headers['Authorization'] == 'Bearer fresh'
            ? throw DioException.connectionError(
                requestOptions: options,
                reason: 'reset',
              )
            : _json(401, {'error': 'Invalid or expired token'}),
      }),
    );

    await expectLater(
      client.getSessions(),
      throwsA(isA<ApiException>().having((e) => e.isOffline, 'offline', true)),
    );

    expect(await client.getToken(), 'fresh');
    expect(await client.getRefreshToken(), 'rotated');
    expect(unauthorizedCalls, 0);
  });
}
