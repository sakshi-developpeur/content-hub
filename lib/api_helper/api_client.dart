import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:estoriz/api_helper/auth_intercepter.dart';

import 'exception.dart';

class ApiClient {
  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;

  // Base configuration
  final String baseUrl = "http://13.203.145.200:8001/api/";
  final int receiveTimeout = 15000;
  final int connectionTimeout = 15000;

  ApiClient._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: connectionTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);

    // Add Interceptors
    _dio.interceptors.add(AuthInterceptor(_dio));

    // Log Interceptor (Only in Debug Mode)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }
  }

  // --- Generic GET Method ---
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // --- Generic POST Method ---
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // --- Generic PUT Method ---
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // --- Generic DELETE Method ---
  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // --- File Upload (Multipart) ---
  Future<dynamic> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? extraData,
  }) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
        if (extraData != null) ...extraData,
      });

      final response = await _dio.post(path, data: formData);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

