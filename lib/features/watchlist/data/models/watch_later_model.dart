class WatchLaterResponse {
  final bool? success;
  final String? message;
  final List<WatchLaterItem> items;
  final int currentPage;
  final int limit;
  final int totalPages;
  final int totalCount;

  const WatchLaterResponse({
    this.success,
    this.message,
    required this.items,
    required this.currentPage,
    required this.limit,
    required this.totalPages,
    required this.totalCount,
  });

  factory WatchLaterResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'] ?? json;
    List<WatchLaterItem> items = <WatchLaterItem>[];

    if (rawData is List) {
      items = rawData
          .whereType<Map>()
          .map((e) => WatchLaterItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      final candidateLists = <dynamic>[
        rawData['data'],
        rawData['items'],
        rawData['videos'],
        rawData['watchLaterVideos'],
        rawData['watchlistVideos'],
        rawData['docs'],
        rawData['list'],
        rawData['results'],
        rawData['watchLater'],
        rawData['watchlist'],
        rawData['savedVideos'],
      ];

      final list =
          candidateLists.firstWhere(
                (value) => value is List,
                orElse: () => const <dynamic>[],
              )
              as List;

      items = list
          .whereType<Map>()
          .map((e) => WatchLaterItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    int readInt(List<dynamic> values, int fallback) {
      for (final value in values) {
        if (value is num) return value.toInt();
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      return fallback;
    }

    final map = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    final pagination = map['pagination'] is Map<String, dynamic>
        ? map['pagination'] as Map<String, dynamic>
        : <String, dynamic>{};

    final currentPage = readInt([
      map['page'],
      map['currentPage'],
      pagination['page'],
      pagination['currentPage'],
      json['page'],
    ], 1);
    final limit = readInt([
      map['limit'],
      map['perPage'],
      pagination['limit'],
      pagination['perPage'],
      json['limit'],
    ], 20);
    final totalCount = readInt([
      map['total'],
      map['totalCount'],
      map['count'],
      pagination['total'],
      pagination['totalCount'],
      json['total'],
    ], items.length);
    final totalPages = readInt([
      map['pages'],
      map['totalPages'],
      pagination['pages'],
      pagination['totalPages'],
      json['pages'],
      (limit > 0 ? (totalCount / limit).ceil() : null),
    ], 1);

    return WatchLaterResponse(
      success: json['success'] is bool ? json['success'] as bool : null,
      message: json['message']?.toString(),
      items: items,
      currentPage: currentPage,
      limit: limit,
      totalPages: totalPages,
      totalCount: totalCount,
    );
  }
}

class WatchLaterItem {
  final String id;
  final String title;
  final String? thumbnail;
  final String? videoUrl;
  final String? description;
  final String? duration;
  final String? category;
  final DateTime? addedAt;

  const WatchLaterItem({
    required this.id,
    required this.title,
    this.thumbnail,
    this.videoUrl,
    this.description,
    this.duration,
    this.category,
    this.addedAt,
  });

  factory WatchLaterItem.fromJson(Map<String, dynamic> json) {
    final rawVideo = json['video'] ?? json['videoId'] ?? json['videoData'];
    final source = rawVideo is Map<String, dynamic>
        ? rawVideo
        : (rawVideo is Map ? Map<String, dynamic>.from(rawVideo) : json);

    final playbackId = source['muxPlaybackId']?.toString();
    final categoryValue = source['category'];
    final id =
        source['_id']?.toString() ??
        source['id']?.toString() ??
        json['_id']?.toString() ??
        json['id']?.toString() ??
        '';

    return WatchLaterItem(
      id: id,
      title: source['title']?.toString() ?? json['title']?.toString() ?? '',
      thumbnail:
          source['thumbnail']?.toString() ??
          source['thumbnailUrl']?.toString() ??
          (playbackId != null && playbackId.isNotEmpty
              ? 'https://image.mux.com/$playbackId/thumbnail.jpg?time=1'
              : null) ??
          source['image']?.toString() ??
          '',
      videoUrl:
          source['videoUrl']?.toString() ??
          source['video_url']?.toString() ??
          source['hlsManifest']?.toString() ??
          (playbackId != null && playbackId.isNotEmpty
              ? 'https://stream.mux.com/$playbackId.m3u8'
              : null) ??
          source['url']?.toString(),
      description: source['description']?.toString(),
      duration: source['duration']?.toString(),
      category: categoryValue is Map<String, dynamic>
          ? categoryValue['name']?.toString()
          : source['category']?.toString(),
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt'].toString())
          : DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'thumbnail': thumbnail,
      'videoUrl': videoUrl,
      'description': description,
      'duration': duration,
      'category': category,
      'addedAt': addedAt?.toIso8601String(),
    };
  }
}

