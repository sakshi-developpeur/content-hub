class UserProfileModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isKidsMode;
  final String? maturityRating;
  final String? language;
  final bool isPinEnabled;
  final bool isActive;

  UserProfileModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isKidsMode = false,
    this.maturityRating,
    this.language,
    this.isPinEnabled = false,
    this.isActive = true,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      isKidsMode: json['isKidsMode'] == true,
      maturityRating: json['maturityRating']?.toString(),
      language: json['language']?.toString(),
      isPinEnabled: json['isPinEnabled'] == true,
      isActive: json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'isKidsMode': isKidsMode,
      'maturityRating': maturityRating,
      'language': language,
      'isPinEnabled': isPinEnabled,
      'isActive': isActive,
    };
  }
}
