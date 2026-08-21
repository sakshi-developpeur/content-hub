import 'package:estoriz/models/user_model.dart';

class AuthResponseModel {
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? deviceId;
  final UserModel? user;

  AuthResponseModel({
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.deviceId,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'] ?? json;
    final Map<String, dynamic> data = rawData is Map<String, dynamic>
        ? rawData
        : (rawData is Map
              ? Map<String, dynamic>.from(rawData)
              : <String, dynamic>{});

    if (data.isEmpty) return AuthResponseModel();

    String? readString(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value is String && value.isNotEmpty) return value;
      }
      return null;
    }

    int? readInt(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    // Try to find user data
    dynamic userData = data['user'] ?? data['profile'] ?? data['userData'];
    
    // If no explicit user object, check if root data contains user fields
    if (userData == null && (data.containsKey('email') || data.containsKey('name'))) {
      userData = data;
    }

    return AuthResponseModel(
      accessToken: readString(['accessToken', 'access_token', 'token', 'jwt']),
      refreshToken: readString(['refreshToken', 'refresh_token']),
      expiresIn: readInt(['expiresIn', 'expires_in']),
      deviceId: readString(['deviceId', 'device_id']),
      user: userData is Map<String, dynamic>
          ? UserModel.fromJson(userData)
          : (userData is Map
                ? UserModel.fromJson(Map<String, dynamic>.from(userData))
                : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'deviceId': deviceId,
      'user': user?.toJson(),
    };
  }
}
