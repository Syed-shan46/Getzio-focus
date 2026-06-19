import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../../config/env.dart';
import '../storage/hive_database.dart';

class DioClient {
  late final Dio _dio;
  final HiveDatabase _hiveDb;

  DioClient(this._hiveDb) {
    final baseUrl = EnvConfig.baseUrl.endsWith('/')
        ? EnvConfig.baseUrl
        : '${EnvConfig.baseUrl}/';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log('[API] ${options.method} ${options.path}');
          final token = _hiveDb.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log('[API] ✓ ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          log('[API] ✗ ${error.response?.statusCode} ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  String _normalizePath(String path) {
    return path.startsWith('/') ? path.substring(1) : path;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        _normalizePath(path),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    String errorMessage = 'Something went wrong';

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      errorMessage = 'Network connection timed out.';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'No internet connection.';
    } else if (e.response != null) {
      String? msg;
      final responseData = e.response?.data;
      if (responseData is Map) {
        msg = responseData['message']?.toString();
      } else if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);
          if (decoded is Map) msg = decoded['message']?.toString();
        } catch (_) {}
      }
      errorMessage = msg ?? 'Server error: ${e.response?.statusCode}';
    }

    return ApiException(errorMessage, e.response?.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}
