import 'dart:io';

import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'network_config.dart';

class ApiClient {
  ApiClient({required String baseUrl, String? token})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: <String, dynamic>{
            'Content-Type': 'application/json',
            ...ClientIdentity.headers,
          },
        )) {
    if (token != null) setToken(token);
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  final Dio _dio;
  String? _token;

  Dio get dio => _dio;

  void setToken(String token) => _token = token;

  void clearToken() => _token = null;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _request(() => _dio.get<dynamic>(path, queryParameters: queryParameters));

  Future<Map<String, dynamic>> post(String path, {Object? data}) =>
      _mapRequest(() => _dio.post<dynamic>(path, data: data));

  Future<Map<String, dynamic>> patch(String path, {Object? data}) =>
      _mapRequest(() => _dio.patch<dynamic>(path, data: data));

  Future<Map<String, dynamic>> put(String path, {Object? data}) =>
      _mapRequest(() => _dio.put<dynamic>(path, data: data));

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) =>
      _mapRequest(() => _dio.delete<dynamic>(
            path,
            queryParameters: queryParameters,
            data: data,
          ));

  Future<Map<String, dynamic>> upload({
    required String path,
    required File file,
    required String fieldName,
    Map<String, dynamic>? queryParameters,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });
      final response = await _dio.post<dynamic>(
        path,
        data: formData,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() action) async {
    try {
      final response = await action();
      return response.data;
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Map<String, dynamic>> _mapRequest(
    Future<Response<dynamic>> Function() action,
  ) async {
    final data = await _request(action);
    return _asMap(data);
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  ApiException _mapException(DioException e) {
    final body = e.response?.data;
    String? message;
    if (body is Map) {
      message = body['error'] as String?;
    }
    return ApiException(
      message ?? e.message ?? '网络请求失败',
      statusCode: e.response?.statusCode,
    );
  }
}
