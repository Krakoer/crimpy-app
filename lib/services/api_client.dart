import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/services/api_exception.dart';

class ApiClient {
  /// Set to reach a local stack, or preprod, or production, from a run started
  /// in the editor, without editing this file:
  ///
  ///     flutter run --flavor beta --dart-define=CRIMPY_API_URL=http://192.168.1.10:3000
  ///
  /// Passing the key with an empty value defines it, so an empty override has to
  /// fall back rather than hand Dio a baseUrl no relative path can resolve
  /// against. appFlavor guards itself the same way.
  static const String _baseUrlOverride = String.fromEnvironment(
    'CRIMPY_API_URL',
  );

  /// The stage decides the backend. A released prod build is the only one that
  /// reaches production, so neither a beta APK in a tester's hands nor a run
  /// started from the editor can write into it by default.
  static const String baseUrl = _baseUrlOverride != ''
      ? _baseUrlOverride
      : (appFlavor == 'prod' && kReleaseMode
            ? 'https://api.crimpy.app'
            : 'https://devapi.crimpy.app');
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';

  final Dio _dio;
  final FlutterSecureStorage _storage;

  /// Called when refresh fails on a 401 so the auth state can drop to guest
  /// mode / the login screen instead of looping on denied requests.
  void Function()? onUnauthorized;

  /// Guards against firing concurrent refreshes when several requests 401 at
  /// once; they all await the same in-flight refresh.
  Future<bool>? _refreshFuture;

  ApiClient({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final isProtected = error.requestOptions.path.startsWith('/api/');
          final alreadyRetried = error.requestOptions.extra['retried'] == true;
          if (error.response?.statusCode == 401 &&
              isProtected &&
              !alreadyRetried) {
            if (await _refreshToken()) {
              try {
                final options = error.requestOptions;
                options.extra['retried'] = true;
                final retryResponse = await _dio.fetch(options);
                return handler.resolve(retryResponse);
              } catch (_) {
                // Retry still failed; fall through to the logout path below.
              }
            }
            AppLoggerHelper.info('Refresh failed, clearing tokens');
            await clearToken();
            await clearRefreshToken();
            onUnauthorized?.call();
          }
          _logDeniedRequest(error);
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: tokenKey, value: token);
      AppLoggerHelper.info('Auth token saved securely');
    } catch (e) {
      AppLoggerHelper.error('Failed to save auth token: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: tokenKey);
    } catch (e) {
      AppLoggerHelper.error('Failed to read auth token: $e');
      return null;
    }
  }

  Future<void> clearToken() async {
    try {
      await _storage.delete(key: tokenKey);
      AppLoggerHelper.info('Auth token cleared');
    } catch (e) {
      AppLoggerHelper.error('Failed to clear auth token: $e');
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: refreshTokenKey, value: token);
    } catch (e) {
      AppLoggerHelper.error('Failed to save refresh token: $e');
      rethrow;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: refreshTokenKey);
    } catch (e) {
      AppLoggerHelper.error('Failed to read refresh token: $e');
      return null;
    }
  }

  Future<void> clearRefreshToken() async {
    try {
      await _storage.delete(key: refreshTokenKey);
    } catch (e) {
      AppLoggerHelper.error('Failed to clear refresh token: $e');
    }
  }

  /// Exchanges the stored refresh token for a new access token, deduplicating
  /// concurrent callers. Returns whether a fresh access token was stored.
  Future<bool> _refreshToken() {
    return _refreshFuture ??= _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      // A bare Dio without the auth interceptor avoids recursion on 401.
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      final res = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = res.data as Map<String, dynamic>;
      final newToken = data['token'] as String?;
      final newRefresh = data['refresh_token'] as String?;
      if (newToken == null) return false;
      await saveToken(newToken);
      if (newRefresh != null) await saveRefreshToken(newRefresh);
      AppLoggerHelper.info('Access token refreshed');
      return true;
    } catch (e) {
      AppLoggerHelper.info('Token refresh failed: $e');
      return false;
    }
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Dio get dio => _dio;

  void _logDeniedRequest(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == null) return;

    final timestamp = DateTime.now().toIso8601String();
    final request = e.requestOptions;

    final headers = Map<String, dynamic>.from(request.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = '[REDACTED]';
    }

    final parts = <String>[
      '[$timestamp] Request denied',
      '  ${request.method} ${request.uri}',
      '  Status: $statusCode',
      '  Headers: $headers',
    ];
    if (request.data != null) {
      parts.add('  Request body: ${request.data}');
    }
    if (e.response?.data != null) {
      parts.add('  Response body: ${e.response!.data}');
    }

    AppLoggerHelper.error(parts.join('\n'));
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      if (e.response!.data is Map && e.response!.data['error'] != null) {
        return e.response!.data['error'].toString();
      }
      if (e.response!.data is Map && e.response!.data['message'] != null) {
        return e.response!.data['message'].toString();
      }
    }

    switch (e.response?.statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Invalid credentials. Please try again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'This email is already registered.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return 'Connection timeout. Please check your internet connection.';
        }
        if (e.type == DioExceptionType.connectionError) {
          return 'Connection error. Please check your internet connection.';
        }
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Whether the request never got an answer, as opposed to getting one that
  /// said no. A response of any status means the server was reached.
  ///
  /// The absent response is the whole test. Naming the connection error types
  /// as well would miss the ones dio cannot classify: a TLS handshake refused
  /// by a captive portal, or a socket reset after the request went out, both
  /// arrive as `unknown` with no response and are as offline as the rest.
  static bool _neverReachedTheServer(DioException e) => e.response == null;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        isOffline: _neverReachedTheServer(e),
      );
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        isOffline: _neverReachedTheServer(e),
      );
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        isOffline: _neverReachedTheServer(e),
      );
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        isOffline: _neverReachedTheServer(e),
      );
    }
  }

  /// A null body is a valid empty collection, so never cast it blindly.
  static List<Map<String, dynamic>> _asList(dynamic data) =>
      (data as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  // ----- Sessions -----
  Future<List<Map<String, dynamic>>> getSessions() async {
    final res = await get('/api/sessions');
    return _asList(res.data);
  }

  Future<Map<String, dynamic>> getSession(String id) async {
    final res = await get('/api/sessions/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSession(Map<String, dynamic> body) async {
    final res = await post('/api/sessions', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<void> updateSessionApi(String id, Map<String, dynamic> body) async {
    await put('/api/sessions/$id', data: body);
  }

  Future<void> deleteSessionApi(String id) async {
    await delete('/api/sessions/$id');
  }

  /// Stamps the coach's answer to a session as seen. Idempotent on the server,
  /// which keeps the first read.
  Future<void> markCoachReplyRead(String id) async {
    await put('/api/sessions/$id/coach-reply/read');
  }

  // ----- Trainings -----
  Future<List<Map<String, dynamic>>> getTrainings() async {
    final res = await get('/api/trainings');
    return _asList(res.data);
  }

  Future<Map<String, dynamic>> getTraining(String id) async {
    final res = await get('/api/trainings/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createTraining(Map<String, dynamic> body) async {
    final res = await post('/api/trainings', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTrainingApi(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await put('/api/trainings/$id', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteTrainingApi(String id) async {
    await delete('/api/trainings/$id');
  }

  // ----- Coach enrollment (coachee) -----

  /// The coach this account is enrolled with. The endpoint answers 404 rather
  /// than an empty body when there is none, which the repository turns into a
  /// null.
  Future<Map<String, dynamic>> getUserEnrollment() async {
    final res = await get('/api/user/enrollment');
    return res.data as Map<String, dynamic>;
  }

  // ----- Availability (coachee) -----

  /// The calendar weeks the athlete has declared, keyed by their Monday.
  ///
  /// [from] and [to] are Mondays in YYYY-MM-DD and bound the answer to that
  /// range of weeks, both ends included. Sending neither reads every week ever
  /// declared, which a week holding up to 140 activities makes far too large to
  /// ask for on a screen showing one week.
  Future<List<Map<String, dynamic>>> getMyAvailability({
    String? from,
    String? to,
  }) async {
    final res = await get(
      '/api/user/availability',
      queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );
    return _asList(res.data);
  }

  /// Every Monday the athlete has declared, as YYYY-MM-DD and with no
  /// activities on them.
  ///
  /// Deliberately its own endpoint rather than a read of the list above: the
  /// reminder planner drops a nudge for a week already answered, so it needs
  /// every declared week and not the window a screen happens to be showing.
  Future<List<String>> getMyDeclaredWeeks() async {
    final res = await get('/api/user/availability/declared-weeks');
    final data = res.data;
    if (data is! List) return const [];
    return data.map((week) => week.toString()).toList();
  }

  /// Declares one week. The body carries all seven days: the API only holds a
  /// week written whole, and its presence is what says the week was declared.
  Future<Map<String, dynamic>> putMyWeekAvailability(
    String weekStart,
    Map<String, dynamic> body,
  ) async {
    final res = await put('/api/user/availability/$weekStart', data: body);
    return res.data as Map<String, dynamic>;
  }

  /// The reminder this athlete's coach configured. The endpoint answers 404
  /// when there is no coach or no reminder, which the repository turns into a
  /// null.
  Future<Map<String, dynamic>> getAvailabilityReminder() async {
    final res = await get('/api/user/availability-reminder');
    return res.data as Map<String, dynamic>;
  }

  // ----- Bodyweight (coachee owns the series) -----

  /// Appends a measurement. [measuredAt] is when the athlete weighed
  /// themselves, which is not when this call is made: a measurement taken while
  /// the device was offline is sent later and keeps the day it belongs to.
  Future<Map<String, dynamic>> createBodyweight(
    double weightKg,
    DateTime measuredAt,
  ) async {
    final res = await post(
      '/api/user/bodyweights',
      data: {
        'weight_kg': weightKg,
        'measured_at': measuredAt.toUtc().toIso8601String(),
      },
    );
    return res.data as Map<String, dynamic>;
  }

  /// The athlete's own series, most recently measured first.
  Future<List<Map<String, dynamic>>> getMyBodyweights() async {
    final res = await get('/api/user/bodyweights');
    return _asList(res.data);
  }

  // ----- Programs (coachee, read-only) -----
  Future<List<Map<String, dynamic>>> getMyPrograms() async {
    final res = await get('/api/user/programs');
    return _asList(res.data);
  }

  Future<Map<String, dynamic>> getMyProgram(String programId) async {
    final res = await get('/api/user/programs/$programId');
    return res.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMyWeeks(String programId) async {
    final res = await get('/api/user/programs/$programId/weeks');
    return _asList(res.data);
  }

  Future<Map<String, dynamic>> getMyWeek(
    String programId,
    int weekNumber,
  ) async {
    final res = await get('/api/user/programs/$programId/weeks/$weekNumber');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMyProgramTraining(
    String programId,
    String trainingId,
  ) async {
    final res = await get(
      '/api/user/programs/$programId/trainings/$trainingId',
    );
    return res.data as Map<String, dynamic>;
  }

  // ----- Repeaters -----
  Future<List<Map<String, dynamic>>> getRepeaters() async {
    final res = await get('/api/repeaters');
    return _asList(res.data);
  }

  Future<Map<String, dynamic>> getRepeater(String id) async {
    final res = await get('/api/repeaters/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createRepeater(Map<String, dynamic> body) async {
    final res = await post('/api/repeaters', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateRepeaterApi(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await put('/api/repeaters/$id', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteRepeaterApi(String id) async {
    await delete('/api/repeaters/$id');
  }

  // ----- Sensor Configs -----
  Future<List<Map<String, dynamic>>> getSensorConfigs() async {
    final res = await get('/api/sensor-configs');
    return _asList(res.data);
  }

  Future<Map<String, dynamic>> createSensorConfig(
    Map<String, dynamic> body,
  ) async {
    final res = await post('/api/sensor-configs', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSensorConfigApi(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await put('/api/sensor-configs/$id', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteSensorConfigApi(String id) async {
    await delete('/api/sensor-configs/$id');
  }

  // ----- Pinned Builtin Trainings -----
  Future<List<Map<String, dynamic>>> getPinnedBuiltinTrainings() async {
    final res = await get('/api/pinned-builtin-trainings');
    return _asList(res.data);
  }

  Future<void> pinBuiltinTrainingApi(String builtinTrainingId) async {
    await post(
      '/api/pinned-builtin-trainings',
      data: {'builtin_training_id': builtinTrainingId},
    );
  }

  Future<void> unpinBuiltinTrainingApi(String builtinTrainingId) async {
    await delete('/api/pinned-builtin-trainings/$builtinTrainingId');
  }

  // ----- Builtin Training Weights -----
  Future<List<Map<String, dynamic>>> getBuiltinTrainingWeights() async {
    final res = await get('/api/builtin-training-weights');
    return _asList(res.data);
  }

  Future<Map<String, dynamic>> createBuiltinTrainingWeight(
    Map<String, dynamic> body,
  ) async {
    final res = await post('/api/builtin-training-weights', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateBuiltinTrainingWeightApi(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await put('/api/builtin-training-weights/$id', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteBuiltinTrainingWeightApi(String id) async {
    await delete('/api/builtin-training-weights/$id');
  }

  // ----- Assessments -----
  Future<Map<String, dynamic>> createAssessmentApi(
    Map<String, dynamic> body,
  ) async {
    final res = await post('/api/assessments', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getAssessmentsApi() async {
    final res = await get('/api/assessments');
    return _asList(res.data);
  }

  Future<void> deleteAssessmentApi(String id) async {
    await delete('/api/assessments/$id');
  }

  /// The assessments the athlete may reference: the ones Crimpy ships and their
  /// own.
  Future<List<Map<String, dynamic>>> getAssessmentDefinitionsApi() async {
    final res = await get('/api/assessment-definitions');
    return _asList(res.data);
  }

  /// The assessments the athlete may record a result against, which widens the
  /// listing above with the ones a coach prescribed them.
  ///
  /// A prescribed row carries the program_id that reads its training, since a
  /// coach's training is not served on its own.
  Future<List<Map<String, dynamic>>>
  getRecordableAssessmentDefinitionsApi() async {
    final res = await get(
      '/api/assessment-definitions',
      queryParameters: {'recordable': 'true'},
    );
    return _asList(res.data);
  }

  /// Releases the idle HTTP connections and drops the unauthorized callback so
  /// a discarded client cannot call back into a disposed provider.
  void dispose() {
    onUnauthorized = null;
    _dio.close();
  }
}
