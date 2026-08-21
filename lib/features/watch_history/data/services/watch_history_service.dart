import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:estoriz/api_helper/endpoints.dart';
import 'package:estoriz/core/base/api_result.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/watch_history/data/models/watch_history_item.dart';

class WatchHistoryService {
  static const String _baseUrl = 'http://13.203.145.200:8004/api/';
  final UserData _userData = UserData();
  late final Dio _dio;

  WatchHistoryService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _userData.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }
  }

  Future<Result<WatchHistoryResponse>> fetchWatchHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        Endpoints.watchHistory,
        queryParameters: {'page': page, 'limit': limit},
      );

      final rawData = response.data;
      if (rawData is! Map<String, dynamic>) {
        return Result.failure(message: 'Invalid watch history response format');
      }

      if (!_isApiSuccess(rawData)) {
        return Result.failure(
          message:
              _extractApiMessage(rawData) ?? 'Failed to fetch watch history',
        );
      }

      return Result.success(WatchHistoryResponse.fromJson(rawData));
    } on DioException catch (e) {
      return Result.failure(
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<void>> trackWatchHistory({
    required String videoId,
    required int lastPositionSeconds,
    required bool completed,
  }) async {
    try {
      final payload = {
        'videoId': videoId,
        'lastPositionSeconds': lastPositionSeconds,
        'completed': completed,
      };

      final response = await _dio.post(Endpoints.watchHistory, data: payload);
      final rawData = response.data;
      if (rawData is Map<String, dynamic> && !_isApiSuccess(rawData)) {
        return Result.failure(
          message:
              _extractApiMessage(rawData) ?? 'Failed to update watch history',
        );
      }

      return Result.success(null);
    } on DioException catch (e) {
      return Result.failure(
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  bool _isApiSuccess(dynamic data) {
    if (data is! Map<String, dynamic>) return true;
    final success = data['success'];
    if (success is bool) return success;
    if (success is num) return success != 0;
    if (success is String) {
      final value = success.toLowerCase();
      return value == 'true' ||
          value == '1' ||
          value == 'ok' ||
          value == 'success';
    }
    return true;
  }

  String? _extractApiMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    return data['message']?.toString() ?? data['error']?.toString();
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final errorMsg = _extractApiMessage(error.response?.data);
        return errorMsg ?? 'Server error (HTTP $statusCode)';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return error.message ?? 'An error occurred';
    }
  }
}
