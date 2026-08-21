import 'package:dio/dio.dart';
import 'package:estoriz/core/utils/user_data.dart';
// NOTE: Use a storage package like flutter_secure_storage
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final UserData _userData = UserData();
  // final storage = FlutterSecureStorage();

  AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Get token from storage
    // String? accessToken = await storage.read(key: 'access_token');
    final accessToken = _userData.accessToken;

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 2. Handle 401 Unauthorized (Token Expired)
    if (err.response?.statusCode == 401) {
      final alreadyRetried = err.requestOptions.extra['auth_retry'] == true;
      if (alreadyRetried) {
        return handler.next(err);
      }

      try {
        // A. Call your Refresh Token API
        // final refreshToken = await storage.read(key: 'refresh_token');
        // final response = await dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
        // final newAccessToken = response.data['accessToken'];

        final newAccessToken = _userData.accessToken;
        if (newAccessToken == null || newAccessToken.isEmpty) {
          return handler.next(err);
        }

        // B. Update storage
        // await storage.write(key: 'access_token', value: newAccessToken);

        // C. Update the failed request's header with the new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        err.requestOptions.extra['auth_retry'] = true;

        // D. Retry the original request
        final clonedRequest = await dio.request(
          err.requestOptions.path,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
          ),
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
        );

        return handler.resolve(clonedRequest);
      } catch (e) {
        // Refresh failed (Session Expired) -> Logout user
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}
