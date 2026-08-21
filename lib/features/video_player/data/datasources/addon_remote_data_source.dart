import 'package:dio/dio.dart';
import 'package:estoriz/features/video_player/data/models/addon_video_model.dart';

class AddonRemoteDataSource {
  static const String _baseUrl = 'http://13.203.145.200:8002/api/';

  AddonRemoteDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
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

  final Dio _dio;

  Future<List<AddonVideoModel>> fetchAddonVideos(String contentId) async {
    if (contentId.trim().isEmpty) {
      return const [];
    }

    try {
      final response = await _dio.get(
        'content/addons',
        queryParameters: {'contentId': contentId},
      );

      final list = _extractItems(response.data);
      return list
          .map(AddonVideoModel.fromJson)
          .where(
            (video) => video.isActive && video.hlsManifest.trim().isNotEmpty,
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw Exception(_mapDioError(error));
    } catch (error) {
      throw Exception('Failed to fetch related videos: $error');
    }
  }

  List<Map<String, dynamic>> _extractItems(dynamic data) {
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
    }

    return const [];
  }

  String _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseMessage = error.response?.data is Map<String, dynamic>
        ? (error.response?.data['message']?.toString() ?? '')
        : '';

    if (responseMessage.isNotEmpty) {
      return responseMessage;
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request for related videos.';
      case 404:
        return 'Related videos were not found.';
      case 500:
        return 'Server error while loading related videos.';
      default:
        return error.message ?? 'Network error while loading related videos.';
    }
  }
}
