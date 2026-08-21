class CategoryChild {
  final String id;
  final String name;
  final String thumbnailUrl;

  const CategoryChild({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
  });

  factory CategoryChild.fromJson(Map<String, dynamic> json) {
    return CategoryChild(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      thumbnailUrl:
          json['thumbnailUrl']?.toString() ??
          json['thumbnail']?.toString() ??
          json['image']?.toString() ??
          '',
    );
  }
}

class CategoryDetailsItem {
  final String id;
  final String name;
  final String imageUrl;
  final String bannerUrl;
  final String description;
  final String parentId;
  final bool isActive;
  final int order;
  final List<String> tags;
  final List<CategoryChild> children;
  final DateTime? createdAt;

  const CategoryDetailsItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.bannerUrl,
    required this.description,
    required this.parentId,
    required this.isActive,
    required this.order,
    required this.tags,
    required this.children,
    this.createdAt,
  });

  factory CategoryDetailsItem.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final childrenValue = data['children'];
    final children = childrenValue is List
        ? childrenValue
              .whereType<Map<String, dynamic>>()
              .map(CategoryChild.fromJson)
              .toList(growable: false)
        : const <CategoryChild>[];

    final tagsValue = data['tags'];
    final tags = tagsValue is List
        ? tagsValue.map((tag) => tag.toString()).toList(growable: false)
        : const <String>[];

    final imageUrl =
        data['thumbnail']?.toString() ??
        data['thumbnailUrl']?.toString() ??
        data['image']?.toString() ??
        data['icon']?.toString() ??
        '';

    final bannerUrl =
        data['banner']?.toString() ?? data['bannerUrl']?.toString() ?? imageUrl;

    return CategoryDetailsItem(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      name:
          data['name']?.toString() ??
          data['title']?.toString() ??
          data['label']?.toString() ??
          'Category',
      imageUrl: imageUrl,
      bannerUrl: bannerUrl,
      description:
          data['description']?.toString() ?? 'No description available.',
      parentId:
          data['parent']?.toString() ?? data['parentId']?.toString() ?? '',
      isActive: data['isActive'] is bool ? data['isActive'] as bool : true,
      order: data['order'] is num ? (data['order'] as num).toInt() : 0,
      tags: tags,
      children: children,
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? ''),
    );
  }
}

