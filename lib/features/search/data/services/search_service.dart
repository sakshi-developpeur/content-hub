import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:estoriz/api_helper/exception.dart';
import 'package:estoriz/core/base/api_result.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/home/data/models/video_model.dart';

class SearchService {
  static const String _baseUrl = 'http://13.203.145.200:8004/api/';

  late final Dio _dio;
  final UserData _userData = UserData();

  SearchService() {
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

  Future<Result<List<VideoItem>>> searchVideos(
    String query, {
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      Response<dynamic>? response;

      // Send only one key at a time to avoid backend schema validation errors.
      for (final key in ['q', 'query', 'search', 'keyword']) {
        try {
          response = await _dio.get(
            'videos/search',
            queryParameters: {key: query, 'limit': limit},
            cancelToken: cancelToken,
          );
          break;
        } on DioException catch (e) {
          if (CancelToken.isCancel(e)) {
            return Result.failure(message: 'cancelled');
          }

          final message = _extractApiMessage(e.response?.data).toLowerCase();
          final isValidationIssue =
              e.response?.statusCode == 400 &&
              (message.contains('validation failed') ||
                  message.contains('validation') ||
                  message.contains('invalid'));

          // Try next key if this one is not accepted by backend validator.
          if (isValidationIssue) {
            continue;
          }

          final apiError = ApiException.fromDioError(e);
          return Result.failure(message: apiError.message);
        }
      }

      if (response == null) {
        // Fallback directly when all search keys are rejected by backend.
        return _searchFromVideoFeed(query, cancelToken: cancelToken);
      }

      var items = _parseVideos(
        response.data,
      ).map(VideoItem.fromJson).toList(growable: false);

      // Fallback: if search endpoint returns empty, filter the videos feed.
      if (items.isEmpty) {
        final fallback = await _searchFromVideoFeed(
          query,
          cancelToken: cancelToken,
        );
        if (!fallback.isSuccess) {
          return fallback;
        }
        items = fallback.data ?? const <VideoItem>[];
      }

      return Result.success(items);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return Result.failure(message: 'cancelled');
      }
      final apiError = ApiException.fromDioError(e);
      return Result.failure(message: apiError.message);
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<List<VideoItem>>> _searchFromVideoFeed(
    String query, {
    CancelToken? cancelToken,
  }) async {
    try {
      final fallbackResponse = await _dio.get(
        'videos',
        queryParameters: {'page': 1, 'limit': 100},
        cancelToken: cancelToken,
      );

      final allVideos = _parseVideos(
        fallbackResponse.data,
      ).map(VideoItem.fromJson).toList(growable: false);

      final normalized = query.trim().toLowerCase();
      final filtered = allVideos
          .where((video) {
            return video.title.toLowerCase().contains(normalized) ||
                (video.description ?? '').toLowerCase().contains(normalized) ||
                (video.category ?? '').toLowerCase().contains(normalized);
          })
          .toList(growable: false);

      return Result.success(filtered);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return Result.failure(message: 'cancelled');
      }
      final apiError = ApiException.fromDioError(e);
      return Result.failure(message: apiError.message);
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  String _extractApiMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['details']?.toString() ??
          '';
    }
    return data?.toString() ?? '';
  }

  List<Map<String, dynamic>> _parseVideos(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    if (data is Map<String, dynamic>) {
      final inner = data['data'];

      // Handle grouped shape: { data: [ { videos: [...] }, ... ] }
      if (inner is List) {
        final flattened = <Map<String, dynamic>>[];
        for (final group in inner) {
          if (group is Map<String, dynamic> && group['videos'] is List) {
            flattened.addAll(
              (group['videos'] as List).whereType<Map>().map(
                (item) => Map<String, dynamic>.from(item),
              ),
            );
          }
        }
        if (flattened.isNotEmpty) {
          return flattened;
        }
      }

      if (inner is List) {
        return inner
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }

      if (inner is Map<String, dynamic>) {
        for (final key in ['list', 'videos', 'items', 'results']) {
          final candidate = inner[key];
          if (candidate is List) {
            return candidate
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList(growable: false);
          }
        }
      }

      for (final key in ['list', 'videos', 'items', 'results']) {
        final candidate = data[key];
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList(growable: false);
        }
      }
    }

    return const <Map<String, dynamic>>[];
  }
}
