import 'package:estoriz/api_helper/api_client.dart';
import 'package:estoriz/api_helper/endpoints.dart';
import 'package:estoriz/api_helper/exception.dart';
import 'package:estoriz/core/base/api_result.dart';
import 'package:estoriz/models/auth_response_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// POST auth/login
  /// Returns [Result.success] with [AuthResponseModel] on 2xx.
  /// Returns [Result.failure] on API errors (400/401/etc).
  /// Rethrows network errors so [ApiRetryHelper] can show the retry dialog.
  Future<Result<AuthResponseModel>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final trimmedIdentifier = identifier.trim();
      final isEmailIdentifier = GetUtils.isEmail(trimmedIdentifier);
      final identifierKey = isEmailIdentifier ? 'email' : 'phone';
      final Map<String, dynamic> payload = <String, dynamic>{
        identifierKey: trimmedIdentifier,
      };

      // Keep the existing login method shape, but send OTP using entered identifier.
      final response = await _apiClient.post(Endpoints.login, data: payload);
      final authResponse = AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
      return Result.success(authResponse);
    } on ApiException catch (e) {
      if (e.isNetworkError) rethrow;
      return Result.failure(message: e.message, statusCode: e.statusCode);
    }
  }

  /// POST auth/register
  /// Returns [Result.success] with [AuthResponseModel] on 2xx.
  /// Returns [Result.failure] on API errors.
  /// Rethrows network errors so [ApiRetryHelper] can show the retry dialog.
  Future<Result<AuthResponseModel>> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.register,
        data: {
          'name': username,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );
      final authResponse = AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
      return Result.success(authResponse);
    } on ApiException catch (e) {
      if (e.isNetworkError) rethrow;
      return Result.failure(message: e.message, statusCode: e.statusCode);
    }
  }

  /// POST auth/otp/verify-login
  /// Returns [Result.success] with [AuthResponseModel] on 2xx.
  /// Returns [Result.failure] on API errors.
  /// Rethrows network errors so [ApiRetryHelper] can show the retry dialog.
  Future<Result<AuthResponseModel>> verifyLoginOtp({
    required String identifier,
    required String otp,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final trimmedIdentifier = identifier.trim();
      final isEmailIdentifier = GetUtils.isEmail(trimmedIdentifier);
      final identifierKey = isEmailIdentifier ? 'email' : 'phone';
      final Map<String, dynamic> payload = <String, dynamic>{
        identifierKey: trimmedIdentifier,
        'otp': otp,
        'deviceInfo': deviceInfo ?? <String, dynamic>{},
      };

      final response = await _apiClient.post(
        Endpoints.verifyLoginOtp,
        data: payload,
      );
      final authResponse = AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
      return Result.success(authResponse);
    } on ApiException catch (e) {
      if (e.isNetworkError) rethrow;
      return Result.failure(message: e.message, statusCode: e.statusCode);
    }
  }

  /// POST auth/forgot-password
  /// Sends OTP for forgot password flow to a mobile number.
  Future<Result<void>> sendForgotPasswordOtp({required String mobile}) async {
    try {
      final Map<String, dynamic> payload = <String, dynamic>{'mobile': mobile};
      await _apiClient.post(Endpoints.forgotPassword, data: payload);
      return Result.success(null);
    } on ApiException catch (e) {
      if (e.isNetworkError) rethrow;
      return Result.failure(message: e.message, statusCode: e.statusCode);
    }
  }

  /// POST auth/verify-forgot-password-otp
  /// Verifies OTP and returns reset token.
  Future<Result<String>> verifyForgotPasswordOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        'mobile': mobile,
        'otp': otp,
      };

      final response = await _apiClient.post(
        Endpoints.verifyForgotPasswordOtp,
        data: payload,
      );

      String? token;
      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        final data = map['data'];
        if (data is Map) {
          final dataMap = Map<String, dynamic>.from(data);
          token = (dataMap['token'] ?? dataMap['resetToken'])?.toString();
        }
        token ??= (map['token'] ?? map['resetToken'])?.toString();
      }

      if (token == null || token.isEmpty) {
        return Result.failure(message: 'Reset token not found in response');
      }

      return Result.success(token);
    } on ApiException catch (e) {
      if (e.isNetworkError) rethrow;
      return Result.failure(message: e.message, statusCode: e.statusCode);
    }
  }

  /// POST auth/reset-password
  /// Resets password with token and new password.
  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };
      await _apiClient.post(Endpoints.resetPassword, data: payload);
      return Result.success(null);
    } on ApiException catch (e) {
      if (e.isNetworkError) rethrow;
      return Result.failure(message: e.message, statusCode: e.statusCode);
    }
  }

  /// POST auth/oauth/google/login
  /// Sends Google ID token + device info to the backend.
  Future<Result<AuthResponseModel>> googleLogin({
    required String idToken,
    required Map<String, dynamic> deviceInfo,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.googleLogin,
        data: {'token': idToken, 'deviceInfo': deviceInfo},
      );

      final authResponse = AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
      return Result.success(authResponse);
    } on ApiException catch (e) {
      if (e.isNetworkError) rethrow;
      return Result.failure(message: e.message, statusCode: e.statusCode);
    }
  }

  /// POST auth/oauth/apple/login
  /// Sends Apple identity token + device info to the backend.
  Future<Result<AuthResponseModel>> appleLogin({
    required String identityToken,
    required Map<String, dynamic> deviceInfo,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.appleLogin,
        data: {'token': identityToken, 'deviceInfo': deviceInfo},
      );
      final authResponse = AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
      return Result.success(authResponse);
    } on ApiException catch (e) {
      if (e.isNetworkError) rethrow;
      return Result.failure(message: e.message, statusCode: e.statusCode);
    }
  }
}
