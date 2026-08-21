import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:estoriz/core/base/api_result.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/subscription/data/models/payment_model.dart';
import 'package:uuid/uuid.dart';

/// Service for handling Razorpay payment operations
/// Handles:
/// - Creating orders on Razorpay backend
/// - Verifying payment signatures after successful transaction
class PaymentService {
  static const String _baseUrl = 'http://13.203.145.200:8003/api/billing/v1/';

  late final Dio _dio;

  PaymentService() {
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

  /// Create a Razorpay order for payment initiation
  ///
  /// Parameters:
  /// - planCode: The subscription plan code (for example: premium)
  /// - billingCycle: Billing cycle (for example: monthly, quarterly, yearly)
  ///
  /// Returns: Result containing RazorpayOrder with orderId, amount, currency, and key
  Future<Result<RazorpayOrder>> createOrder({
    required String planCode,
    required String billingCycle,
  }) async {
    try {
      final payload = {"planCode": planCode, "billingCycle": billingCycle};
      final token = UserData().accessToken;
      final headers = <String, dynamic>{'Idempotency-Key': const Uuid().v4()};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.post(
        'orders',
        data: payload,
        options: Options(headers: headers),
      );

      final rawData = response.data;
      if (rawData is! Map<String, dynamic>) {
        return Result.failure(
          message: 'Invalid order response format',
          statusCode: response.statusCode,
        );
      }

      debugPrint('PaymentService: createOrder response → $rawData');

      // Pass full response — RazorpayOrder.fromJson handles all nesting.
      final order = RazorpayOrder.fromJson(
        Map<String, dynamic>.from(rawData),
      );

      if (order.orderId.isEmpty) {
        return Result.failure(
          message: 'Order missing required fields',
          statusCode: response.statusCode,
        );
      }

      return Result.success(order);
    } on DioException catch (e) {
      return Result.failure(
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
        data: null,
      );
    } catch (e) {
      return Result.failure(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Verify payment signature after successful Razorpay payment
  ///
  /// Parameters:
  /// - verification: PaymentVerificationRequest containing orderId, paymentId, signature
  ///
  /// Returns: Result containing PaymentVerificationResponse with verification status
  Future<Result<PaymentVerificationResponse>> verifyPayment(
    PaymentVerificationRequest verification,
  ) async {
    try {
      final token = UserData().accessToken;
      final headers = <String, dynamic>{'Idempotency-Key': const Uuid().v4()};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.post(
        'payments/verify',
        data: verification.toJson(),
        options: Options(headers: headers),
      );

      final rawData = response.data;
      if (rawData is! Map<String, dynamic>) {
        return Result.failure(
          message: 'Invalid verification response format',
          statusCode: response.statusCode,
        );
      }

      final verificationResponse = PaymentVerificationResponse.fromJson(
        Map<String, dynamic>.from(rawData),
      );

      return Result.success(verificationResponse);
    } on DioException catch (e) {
      return Result.failure(
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Result.failure(message: 'Verification failed: ${e.toString()}');
    }
  }

  /// Verify an In-App Purchase with the backend.
  ///
  /// Accepts a pre-built payload map from [GooglePlayVerificationRequest]
  /// or [ApplePayVerificationRequest] which includes the gateway field.
  Future<Result<PaymentVerificationResponse>> verifyIapPayment(
    Map<String, dynamic> verificationData,
  ) async {
    try {
      final token = UserData().accessToken;
      final headers = <String, dynamic>{'Idempotency-Key': const Uuid().v4()};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.post(
        'payments/verify',
        data: verificationData,
        options: Options(headers: headers),
      );

      final rawData = response.data;
      if (rawData is! Map<String, dynamic>) {
        return Result.failure(
          message: 'Invalid verification response format',
          statusCode: response.statusCode,
        );
      }

      final verificationResponse = PaymentVerificationResponse.fromJson(
        Map<String, dynamic>.from(rawData),
      );

      return Result.success(verificationResponse);
    } on DioException catch (e) {
      return Result.failure(
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Result.failure(
        message: 'IAP verification failed: ${e.toString()}',
      );
    }
  }

  /// Handle Dio exceptions with user-friendly messages
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final errorMsg = error.response?.data?['message']?.toString();
        return errorMsg ?? 'Server error (HTTP $statusCode)';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return error.message ?? 'An error occurred';
    }
  }
}
