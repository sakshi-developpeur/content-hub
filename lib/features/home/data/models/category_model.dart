class CategoryItem {
  final String id;
  final String name;
  final String imageUrl;
  final String? description;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    final image =
        json['thumbnail']?.toString() ??
        json['thumbnailUrl']?.toString() ??
        json['image']?.toString() ??
        json['icon']?.toString() ??
        '';

    return CategoryItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name:
          json['name']?.toString() ??
          json['title']?.toString() ??
          json['label']?.toString() ??
          'Category',
      imageUrl: image,
      description: json['description']?.toString(),
    );
  }
}

