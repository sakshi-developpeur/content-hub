class AnnouncementItem {
  static const String _contentOrigin = 'http://13.203.145.200:8002';

  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? ctaUrl;
  final DateTime? startAt;
  final DateTime? endAt;

  const AnnouncementItem({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.ctaUrl,
    this.startAt,
    this.endAt,
  });

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    final rawImage = _firstNonEmpty([
      _readValue(json, 'image'),
      _readValue(json, 'imageUrl'),
      _readValue(json, 'bannerUrl'),
      _readValue(json, 'thumbnail'),
      _readValue(json, 'banner'),
    ]);

    return AnnouncementItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title:
          json['title']?.toString() ??
          json['headline']?.toString() ??
          json['name']?.toString() ??
          '',
      description:
          json['description']?.toString() ??
          json['content']?.toString() ??
          json['message']?.toString(),
      imageUrl: _normalizeUrl(rawImage),
      ctaUrl:
          json['ctaUrl']?.toString() ??
          json['link']?.toString() ??
          json['url']?.toString(),
      startAt: _parseDate(
        json['startAt'] ?? json['startDate'] ?? json['publishedAt'],
      ),
      endAt: _parseDate(json['endAt'] ?? json['endDate'] ?? json['expiresAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String? _readValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      return _firstNonEmpty([
        map['url']?.toString(),
        map['path']?.toString(),
        map['src']?.toString(),
        map['imageUrl']?.toString(),
        map['bannerUrl']?.toString(),
      ]);
    }
    return value.toString();
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  static String? _normalizeUrl(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;

    // Encode spaces and unsafe characters while preserving URL structure.
    final encoded = Uri.encodeFull(raw);

    if (encoded.startsWith('//')) {
      return 'https:$encoded';
    }

    final parsed = Uri.tryParse(encoded);
    if (parsed != null && parsed.hasScheme) {
      return encoded;
    }

    if (encoded.startsWith('/')) {
      return '$_contentOrigin$encoded';
    }

    return '$_contentOrigin/$encoded';
  }
}
