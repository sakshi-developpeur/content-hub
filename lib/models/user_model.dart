class UserModel {
  final String? id;
  final String? email;
  final String? name;
  final String? role;
  final String? subscriptionStatus;
  final bool? twoFAEnabled;
  final String? phone;
  final String? avatar;
  final List<String>? authProviders;

  UserModel({
    this.id,
    this.email,
    this.name,
    this.role,
    this.subscriptionStatus,
    this.twoFAEnabled,
    this.phone,
    this.avatar,
    this.authProviders,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? readString(Map<String, dynamic> m, List<String> keys) {
      for (var k in keys) {
        if (m[k] != null && m[k].toString().isNotEmpty) return m[k].toString();
      }
      return null;
    }

    return UserModel(
      id: readString(json, ['id', '_id', 'userId']),
      email: readString(json, ['email', 'gmail', 'user_email']),
      name: readString(json, ['name', 'fullName', 'full_name', 'username']),
      role: readString(json, ['role', 'user_role']),
      subscriptionStatus: readString(json, ['subscriptionStatus', 'subscription_status', 'plan', 'tier']),
      twoFAEnabled: json['twoFAEnabled'] == true || json['two_fa_enabled'] == true,
      phone: readString(json, ['phone', 'mobile', 'phone_number', 'phoneNumber', 'phone_no', 'contact']),
      avatar: readString(json, ['avatar', 'avatarUrl', 'profileImage', 'image']),
      authProviders: (json['authProviders'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'subscriptionStatus': subscriptionStatus,
      'twoFAEnabled': twoFAEnabled,
      'phone': phone,
      'avatar': avatar,
      'authProviders': authProviders,
    };
  }
}
