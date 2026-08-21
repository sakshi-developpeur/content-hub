import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:estoriz/api_helper/endpoints.dart';
import 'package:estoriz/api_helper/exception.dart';
import 'package:estoriz/core/base/api_result.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/watchlist/data/models/watch_later_model.dart';

class WatchlistService {
  static const String _baseUrl = 'http://13.203.145.200:8004/api/';
  static const String _watchLaterEndpoint = Endpoints.watchLater;
  late final Dio _dio;
  final UserData _userData = UserData();

  WatchlistService() {
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
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }
  }

  Future<Result<WatchLaterResponse>> fetchWatchLater({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = <String, dynamic>{};
      final token = _userData.accessToken;
      if (token == null || token.isEmpty) {
        return Result.failure(message: 'Please login again. Session expired.');
      }
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get(
        _watchLaterEndpoint,
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: headers),
      );

      if (!_isApiSuccess(response.data)) {
        return Result.failure(
          message:
              _extractApiMessage(response.data) ?? 'Failed to fetch watchlist',
        );
      }

      final watchLaterResponse = WatchLaterResponse.fromJson(response.data);
      return Result.success(watchLaterResponse);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('WatchlistService error: ${e.message}');
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WatchlistService error: $e');
      }
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> addToWatchLater(String videoId) async {
    try {
      final headers = <String, dynamic>{};
      final token = _userData.accessToken;
      if (token == null || token.isEmpty) {
        return Result.failure(message: 'Please login again. Session expired.');
      }
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      try {
        final response = await _dio.post(
          _watchLaterEndpoint,
          data: {'videoId': videoId},
          options: Options(headers: headers),
        );
        final data = response.data;
        final payload = data is Map<String, dynamic>
            ? data
            : <String, dynamic>{'data': data, 'success': true};
        if (!_isApiSuccess(payload)) {
          return Result.failure(
            message:
                _extractApiMessage(payload) ?? 'Failed to add to watchlist',
          );
        }
        return Result.success(payload);
      } on DioException catch (e) {
        // Some backend builds accept snake_case only.
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode == 400 || statusCode == 422) {
          final fallbackResponse = await _dio.post(
            _watchLaterEndpoint,
            data: {'video_id': videoId},
            options: Options(headers: headers),
          );
          final fallbackData = fallbackResponse.data;
          final payload = fallbackData is Map<String, dynamic>
              ? fallbackData
              : <String, dynamic>{'data': fallbackData, 'success': true};
          if (!_isApiSuccess(payload)) {
            return Result.failure(
              message:
                  _extractApiMessage(payload) ?? 'Failed to add to watchlist',
            );
          }
          return Result.success(payload);
        }
        rethrow;
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('WatchlistService addToWatchLater error: ${e.message}');
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WatchlistService addToWatchLater error: $e');
      }
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> removeFromWatchLater(
    String videoId,
  ) async {
    try {
      final headers = <String, dynamic>{};
      final token = _userData.accessToken;
      if (token == null || token.isEmpty) {
        return Result.failure(message: 'Please login again. Session expired.');
      }
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.delete(
        '$_watchLaterEndpoint/$videoId',
        options: Options(headers: headers),
      );

      final data = response.data;
      final payload = data is Map<String, dynamic>
          ? data
          : <String, dynamic>{'data': data, 'success': true};
      if (!_isApiSuccess(payload)) {
        return Result.failure(
          message:
              _extractApiMessage(payload) ?? 'Failed to remove from watchlist',
        );
      }
      return Result.success(payload);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('WatchlistService removeFromWatchLater error: ${e.message}');
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WatchlistService removeFromWatchLater error: $e');
      }
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
    return data['message']?.toString() ??
        data['error']?.toString() ??
        (data['errors'] is List && (data['errors'] as List).isNotEmpty
            ? (data['errors'] as List).first.toString()
            : null);
  }
}
