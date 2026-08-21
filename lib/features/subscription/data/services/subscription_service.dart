import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:estoriz/core/base/api_result.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/subscription/data/models/subscription_plan_model.dart';

class ActiveSubscriptionPlan {
  final String planId;
  final String? planCode;

  const ActiveSubscriptionPlan({required this.planId, this.planCode});
}

class SubscriptionService {
  static const String _baseUrl = 'http://13.203.145.200:8003/api/billing/v1/';

  late final Dio _dio;

  SubscriptionService() {
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

  Future<Result<List<SubscriptionPlan>>> fetchPlans() async {
    try {
      final response = await _dio.get('plans/catalog');
      final rawData = response.data;

      if (rawData is! Map<String, dynamic>) {
        return Result.failure(message: 'Invalid plans response');
      }

      final rawList = rawData['data'];
      if (rawList is! List) {
        return Result.failure(message: 'Plans catalog is empty');
      }

      final plans =
          rawList
              .whereType<Map>()
              .map(
                (item) =>
                    SubscriptionPlan.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
            ..sort((a, b) => a.tierRank.compareTo(b.tierRank));

      return Result.success(plans);
    } on DioException catch (e) {
      return Result.failure(
        message:
            e.response?.data?['message']?.toString() ??
            e.message ??
            'Failed to load plans',
      );
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }

  Future<Result<ActiveSubscriptionPlan?>> fetchActiveSubscriptionPlan() async {
    try {
      final token = UserData().accessToken;
      if (token == null || token.isEmpty) {
        return Result.success<ActiveSubscriptionPlan?>(null);
      }

      final response = await _dio.get(
        'subscriptions/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final rawData = response.data;
      if (rawData is! Map<String, dynamic>) {
        return Result.success<ActiveSubscriptionPlan?>(null);
      }

      final data = rawData['data'];
      if (data is! Map) {
        return Result.success<ActiveSubscriptionPlan?>(null);
      }

      final subscription = data['subscription'];
      if (subscription is! Map) {
        return Result.success<ActiveSubscriptionPlan?>(null);
      }

      final planNode = subscription['planId'];
      String planId = '';
      String? planCode;

      if (planNode is Map) {
        planId = planNode['_id']?.toString() ?? '';
        planCode = planNode['code']?.toString();
      } else {
        planId = planNode?.toString() ?? '';
      }

      if (planId.isEmpty) {
        return Result.success<ActiveSubscriptionPlan?>(null);
      }

      return Result.success(
        ActiveSubscriptionPlan(planId: planId, planCode: planCode),
      );
    } on DioException catch (e) {
      return Result.failure(
        message:
            e.response?.data?['message']?.toString() ??
            e.message ??
            'Failed to load active subscription',
      );
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }
}
