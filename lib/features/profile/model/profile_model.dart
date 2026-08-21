class ProfileModel {
  final String id;
  final String name;
  final String avatar;
  final bool isKids;
  final bool isMain;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.avatar,
    this.isKids = false,
    this.isMain = false,
  });

  bool get isDeletable => !isMain && !isKids;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'isKids': isKids,
      'isMain': isMain,
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      avatar: (json['avatar'] ?? '').toString(),
      isKids: json['isKids'] == true,
      isMain: json['isMain'] == true,
    );
  }
}
