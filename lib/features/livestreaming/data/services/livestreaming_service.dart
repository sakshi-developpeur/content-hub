import 'package:dio/dio.dart';
import 'package:estoriz/api_helper/exception.dart';
import 'package:estoriz/core/base/api_result.dart';
import 'package:estoriz/core/utils/user_data.dart';
import '../models/live_event_model.dart';
import '../models/agora_join_result_model.dart';

class LivestreamingService {
  static const String _baseUrl = 'http://13.203.145.200:8002/api/';
  late final Dio _dio;
  final UserData _userData = UserData();

  LivestreamingService() {
    _dio = _createDio(_baseUrl);
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
          print('DEBUG: [REQUEST] ${options.method} ${options.uri}');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('DEBUG: [HEADERS] ${options.headers}');
          handler.next(options);
        },
      ),
    );

    return dio;
  }

  Future<Result<List<LiveEvent>>> fetchLiveEvents({
    int page = 1,
    int limit = 20,
    String? status,
    bool? upcoming,
    String? sortBy,
    String? sortOrder,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      
      if (status != null && status != 'all') queryParams['status'] = status;
      if (upcoming != null) queryParams['upcoming'] = upcoming;
      if (sortBy != null && sortBy != 'all') queryParams['sortBy'] = sortBy;
      if (sortOrder != null && sortOrder != 'all') queryParams['sortOrder'] = sortOrder;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('livestreams', queryParameters: queryParams);
      
      final data = response.data['data'] as List?;
      if (data == null) {
         return Result.success([]);
      }
      
      final list = data.map((e) => LiveEvent.fromJson(e)).toList();
      return Result.success(list);
    } on DioException catch (e) {
      print('DEBUG: fetchLiveEvents Error: ${e.response?.statusCode} - ${e.response?.data}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<LiveEvent>> fetchLiveEventById(String id) async {
    try {
      final response = await _dio.get('livestreams/$id');
      final data = response.data['data'];
      return Result.success(LiveEvent.fromJson(data));
    } on DioException catch (e) {
      print('DEBUG: fetchLiveEventById Error: ${e.response?.statusCode} - ${e.response?.data}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<AgoraJoinResult>> joinLivestream(String id) async {
    try {
      // Correctly setting contentType to empty to match curl -d '' without conflicts
      final response = await _dio.post(
        'livestreams/$id/join',
        data: '',
        options: Options(
          contentType: '', // Use empty string to avoid application/json default
        ),
      );
      final data = response.data['data'];
      return Result.success(AgoraJoinResult.fromJson(data));
    } on DioException catch (e) {
      print('DEBUG: joinLivestream Error: ${e.response?.statusCode} - ${e.response?.data}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<int>> sendHeartbeat(String id) async {
    try {
      final response = await _dio.post(
        'livestreams/$id/heartbeat',
        data: '',
        options: Options(
          contentType: '',
        ),
      );
      final viewerCount = response.data['data']?['viewerCount'] ?? 0;
      return Result.success(viewerCount as int);
    } on DioException catch (e) {
      print('DEBUG: sendHeartbeat Error: ${e.response?.statusCode} - ${e.response?.data}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }
}
