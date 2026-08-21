import 'package:dio/dio.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/settings/model/support_ticket_model.dart';

class SettingService {
  static const String _baseUrl = 'http://13.203.145.200:8001/api/';
  final UserData _userData = UserData();
  late final Dio _dio;

  SettingService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
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
  }

  Future<List<SupportTicketModel>> fetchTickets({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    final normalizedStatus = status?.trim().toLowerCase();
    if (normalizedStatus != null && normalizedStatus.isNotEmpty) {
      query['status'] = normalizedStatus;
    }

    final response = await _dio.get('support/tickets', queryParameters: query);
    final raw = response.data;
    if (raw is! Map<String, dynamic>) {
      return const <SupportTicketModel>[];
    }

    final list = raw['data'] is List ? raw['data'] as List : const <dynamic>[];

    return list
        .whereType<Map>()
        .map((e) => SupportTicketModel.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  Future<bool> createTicket({
    required String subject,
    required String description,
    required String priority,
  }) async {
    final payload = {
      'subject': subject.trim(),
      'description': description.trim(),
      'priority': priority.trim().toLowerCase(),
    };

    final response = await _dio.post('support/tickets', data: payload);
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      return raw['success'] == true;
    }
    return true;
  }

  Future<bool> replyToTicket({
    required String ticketId,
    required String message,
  }) async {
    final payload = {'message': message.trim()};
    final response = await _dio.post(
      'support/tickets/$ticketId/reply',
      data: payload,
    );
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      return raw['success'] == true;
    }
    return true;
  }
}
