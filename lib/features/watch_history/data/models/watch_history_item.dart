class WatchHistoryResponse {
  final bool? success;
  final String? message;
  final List<WatchHistoryItem> items;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;

  const WatchHistoryResponse({
    this.success,
    this.message,
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
  });

  factory WatchHistoryResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'] ?? json;

    List<WatchHistoryItem> items = <WatchHistoryItem>[];
    Map<String, dynamic> map = <String, dynamic>{};

    if (rawData is List) {
      items = rawData
          .whereType<Map>()
          .map((e) => WatchHistoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } else if (rawData is Map<String, dynamic>) {
      map = rawData;
      final candidateLists = <dynamic>[
        rawData['docs'],
        rawData['items'],
        rawData['list'],
        rawData['results'],
        rawData['watchHistory'],
        rawData['history'],
        rawData['videos'],
        rawData['data'],
      ];

      final list =
          candidateLists.firstWhere(
                (value) => value is List,
                orElse: () => const <dynamic>[],
              )
              as List;

      items = list
          .whereType<Map>()
          .map((e) => WatchHistoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
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

    return WatchHistoryResponse(
      success: json['success'] is bool ? json['success'] as bool : null,
      message: json['message']?.toString(),
      items: items,
      currentPage: currentPage,
      totalPages: totalPages,
      totalCount: totalCount,
      limit: limit,
    );
  }
}

class WatchHistoryItem {
  final String id;
  final String videoId;
  final String title;
  final String? thumbnail;
  final String? description;
  final String? videoUrl;
  final int lastPositionSeconds;
  final int durationSeconds;
  final bool completed;
  final int viewCount;
  final DateTime? watchedAt;

  const WatchHistoryItem({
    required this.id,
    required this.videoId,
    required this.title,
    this.thumbnail,
    this.description,
    this.videoUrl,
    required this.lastPositionSeconds,
    required this.durationSeconds,
    required this.completed,
    required this.viewCount,
    this.watchedAt,
  });

  double get progress {
    if (durationSeconds <= 0) return 0;
    final value = lastPositionSeconds / durationSeconds;
    return value.clamp(0.0, 1.0);
  }

  bool get isResumable => !completed && lastPositionSeconds > 0;

  factory WatchHistoryItem.fromJson(Map<String, dynamic> json) {
    final dynamic rawVideo =
        json['video'] ?? json['videoId'] ?? json['videoData'];
    final Map<String, dynamic> source = rawVideo is Map<String, dynamic>
        ? rawVideo
        : (rawVideo is Map ? Map<String, dynamic>.from(rawVideo) : json);

    int readInt(dynamic value, {int fallback = 0}) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    bool readBool(dynamic value, {bool fallback = false}) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase();
        return normalized == 'true' || normalized == '1' || normalized == 'yes';
      }
      return fallback;
    }

    final playbackId = source['muxPlaybackId']?.toString();

    return WatchHistoryItem(
      id:
          json['_id']?.toString() ??
          json['id']?.toString() ??
          source['_id']?.toString() ??
          source['id']?.toString() ??
          '',
      videoId:
          source['_id']?.toString() ??
          source['id']?.toString() ??
          json['videoId']?.toString() ??
          '',
      title:
          source['title']?.toString() ??
          json['title']?.toString() ??
          'Untitled',
      thumbnail:
          source['thumbnail']?.toString() ??
          source['thumbnailUrl']?.toString() ??
          (playbackId != null && playbackId.isNotEmpty
              ? 'https://image.mux.com/$playbackId/thumbnail.jpg?time=1'
              : null),
      description: source['description']?.toString(),
      videoUrl:
          source['videoUrl']?.toString() ??
          source['video_url']?.toString() ??
          source['hlsManifest']?.toString() ??
          (playbackId != null && playbackId.isNotEmpty
              ? 'https://stream.mux.com/$playbackId.m3u8'
              : null) ??
          source['url']?.toString(),
      lastPositionSeconds: readInt(
        json['lastPositionSeconds'] ??
            json['last_position_seconds'] ??
            json['lastPosition'] ??
            source['lastPositionSeconds'],
      ),
      durationSeconds: readInt(
        source['durationSeconds'] ??
            source['duration'] ??
            json['durationSeconds'],
      ),
      completed: readBool(json['completed'] ?? json['isCompleted']),
      viewCount: readInt(json['viewCount'] ?? json['views'] ?? 0),
      watchedAt: DateTime.tryParse(
        json['updatedAt']?.toString() ??
            json['watchedAt']?.toString() ??
            json['createdAt']?.toString() ??
            '',
      ),
    );
  }
}
