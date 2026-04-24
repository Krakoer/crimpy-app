import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/services/api_exception.dart';

class ApiClient {
  static const String baseUrl = 'https://devapi.crimpy.app';
  static const String tokenKey = 'auth_token';

  final Dio _dio;
  final FlutterSecureStorage _storage;

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
          if (error.response?.statusCode == 401) {
            AppLoggerHelper.info('Token expired, clearing stored token');
            await clearToken();
          }
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

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Dio get dio => _dio;

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
      final message = _extractErrorMessage(e);
      AppLoggerHelper.error('GET $path failed: $message');
      throw ApiException(message, statusCode: e.response?.statusCode);
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
      final message = _extractErrorMessage(e);
      AppLoggerHelper.error('POST $path failed: $message');
      throw ApiException(message, statusCode: e.response?.statusCode);
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
      final message = _extractErrorMessage(e);
      AppLoggerHelper.error('PUT $path failed: $message');
      throw ApiException(message, statusCode: e.response?.statusCode);
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
      final message = _extractErrorMessage(e);
      AppLoggerHelper.error('DELETE $path failed: $message');
      throw ApiException(message, statusCode: e.response?.statusCode);
    }
  }
}
