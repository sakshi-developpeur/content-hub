import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:estoriz/api_helper/endpoints.dart';
import 'package:estoriz/api_helper/exception.dart';
import 'package:estoriz/core/base/api_result.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/home/data/models/announcement_model.dart';
import 'package:estoriz/features/home/data/models/banner_model.dart';
import 'package:estoriz/features/home/data/models/category_model.dart';
import 'package:estoriz/features/home/data/models/category_details_model.dart';
import 'package:estoriz/features/home/data/models/recommendation_model.dart';
import 'package:estoriz/features/home/data/models/video_model.dart'
    as video_model;
import 'package:estoriz/features/home/data/models/video_list_model.dart';

class HomeService {
  static const String _baseUrl = 'http://13.203.145.200:8004/api/';
  static const String _contentBaseUrl = 'http://13.203.145.200:8002/api/';
  late final Dio _dio;
  late final Dio _contentDio;
  final UserData _userData = UserData();

  HomeService() {
    _dio = _createDio(_baseUrl);
    _contentDio = _createDio(_contentBaseUrl);
  }

  Future<Result<List<BannerItem>>> fetchBanners({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        'videos/banner',
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = _parseList(response.data);
      return Result.success(list.map(BannerItem.fromJson).toList());
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<List<video_model.VideoItem>>> fetchVideos({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        'videos',
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = _parseVideos(response.data);
      return Result.success(list.map(video_model.VideoItem.fromJson).toList());
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<List<CategoryItem>>> fetchCategories() async {
    try {
      final response = await _dio.get(
        'categories',
        queryParameters: {'tree': false, 'parent': 'root'},
      );
      final list = _parseCategories(response.data);
      return Result.success(list.map(CategoryItem.fromJson).toList());
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<CategoryDetailsItem>> fetchCategoryDetails(
    String categoryId,
  ) async {
    try {
      final response = await _dio.get('categories/$categoryId');
      return Result.success(CategoryDetailsItem.fromJson(response.data));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<VideoListResponse>> fetchVideosByCategory(
    String categoryId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        'videos/category/$categoryId',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (kDebugMode) {
        print(' API Response received for category $categoryId');
        print(' Response data: ${response.data}');
      }

      try {
        final parsed = VideoListResponse.fromJson(response.data);
        if (kDebugMode) {
          print(' Parsed ${parsed.videos.length} videos');
        }
        return Result.success(parsed);
      } catch (e) {
        if (kDebugMode) {
          print(' Error parsing response: $e');
        }
        return Result.failure(
          message: 'Failed to parse videos response: ${e.toString()}',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print(' DIO Error: ${e.message}');
        print(' Response: ${e.response?.data}');
      }
      return Result.failure(
        message: e.response?.data?.toString() ?? e.message ?? 'API Error',
      );
    } catch (e) {
      if (kDebugMode) {
        print(' Unexpected error: $e');
      }
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<List<RecommendationItem>>> fetchRecommendations({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        'videos/recommendations',
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = _parseRecommendations(response.data);
      return Result.success(list.map(RecommendationItem.fromJson).toList());
    } on DioException catch (e) {
      // Some environments return 401/403 for recommendations.
      // Fall back to public videos so the section still renders.
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        final videosResult = await fetchVideos(page: page, limit: limit);
        if (videosResult.isSuccess && videosResult.data != null) {
          final recommendations = videosResult.data!
              .map(
                (v) => RecommendationItem(
                  id: v.id,
                  title: v.title,
                  thumbnail: v.thumbnail,
                ),
              )
              .toList(growable: false);
          return Result.success(recommendations);
        }
        return Result.failure(
          message: videosResult.message ?? 'Failed to load recommendations',
        );
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<List<AnnouncementItem>>> fetchAnnouncements({
    int page = 1,
    int limit = 20,
    bool upcomingOnly = true,
  }) async {
    try {
      final response = await _contentDio.get(
        Endpoints.announcements,
        queryParameters: {
          'page': page,
          'limit': limit,
          'upcomingOnly': upcomingOnly,
        },
      );
      final list = _parseAnnouncements(response.data);
      return Result.success(list.map(AnnouncementItem.fromJson).toList());
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  Dio _createDio(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
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
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }

    return dio;
  }

  /// Handles multiple common API response shapes:
  /// - `[...]`  (bare list)
  /// - `{ "data": [...] }`
  /// - `{ "data": { "list": [...] } }`
  /// - `{ "list": [...] }` / `{ "videos": [...] }` etc.
  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);
    }
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) {
        return inner
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false);
      }
      if (inner is Map<String, dynamic>) {
        for (final key in ['list', 'videos', 'items', 'results']) {
          if (inner[key] is List) {
            final list = inner[key] as List;
            return list
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList(growable: false);
          }
        }
      }
      for (final key in ['list', 'videos', 'items', 'results']) {
        if (data[key] is List) {
          final list = data[key] as List;
          return list
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(growable: false);
        }
      }
    }
    return [];
  }

  /// Handles `/videos` response shapes including grouped categories:
  /// - `{ "data": [ { "videos": [ ... ] }, ... ] }`
  /// - `{ "videos": [ ... ] }`
  /// - fallback to generic list parser for flat payloads
  List<Map<String, dynamic>> _parseVideos(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['data'];

      if (inner is List) {
        final flattened = <Map<String, dynamic>>[];
        for (final group in inner) {
          if (group is Map<String, dynamic> && group['videos'] is List) {
            flattened.addAll(
              List<Map<String, dynamic>>.from(group['videos'] as List),
            );
          }
        }
        if (flattened.isNotEmpty) return flattened;
      }

      if (data['videos'] is List) {
        final list = data['videos'] as List;
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false);
      }
    }

    return _parseList(data);
  }

  /// Handles recommendation response variants:
  /// - `{ "data": [ ... ] }`
  /// - `{ "data": { "recommendations": [ ... ] } }`
  /// - `{ "recommendations": [ ... ] }`
  /// - `{ "data": { "videos": [ ... ] } }`
  List<Map<String, dynamic>> _parseRecommendations(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['data'];

      if (inner is List) {
        return inner
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false);
      }

      if (inner is Map<String, dynamic>) {
        for (final key in [
          'recommendations',
          'recommendedVideos',
          'recommended',
          'recommendationVideos',
          'videos',
          'items',
          'results',
          'list',
        ]) {
          if (inner[key] is List) {
            final list = inner[key] as List;
            return list
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList(growable: false);
          }
        }
      }

      for (final key in [
        'recommendations',
        'recommendedVideos',
        'recommended',
        'recommendationVideos',
        'videos',
        'items',
        'results',
        'list',
      ]) {
        if (data[key] is List) {
          final list = data[key] as List;
          return list
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(growable: false);
        }
      }
    }

    return _parseVideos(data);
  }

  List<Map<String, dynamic>> _parseAnnouncements(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['data'];

      if (inner is List) {
        return inner
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false);
      }

      if (inner is Map<String, dynamic>) {
        for (final key in [
          'announcements',
          'items',
          'results',
          'list',
          'docs',
        ]) {
          if (inner[key] is List) {
            final list = inner[key] as List;
            return list
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList(growable: false);
          }
        }
      }

      for (final key in ['announcements', 'items', 'results', 'list', 'docs']) {
        if (data[key] is List) {
          final list = data[key] as List;
          return list
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(growable: false);
        }
      }
    }

    return _parseList(data);
  }

  List<Map<String, dynamic>> _parseCategories(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['data'];

      if (inner is List) {
        return inner
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false);
      }

      if (inner is Map<String, dynamic>) {
        for (final key in ['categories', 'items', 'results', 'list']) {
          if (inner[key] is List) {
            final list = inner[key] as List;
            return list
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList(growable: false);
          }
        }
      }

      for (final key in ['categories', 'items', 'results', 'list']) {
        if (data[key] is List) {
          final list = data[key] as List;
          return list
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(growable: false);
        }
      }
    }

    return _parseList(data);
  }
}
