class WatchHistoryModel {
  static const String _apiOrigin = 'http://13.203.145.200:8004';

  final String videoId;
  final String title;
  final String thumbnail;
  final String videoUrl;
  final int totalDuration;
  final int watchedPosition;
  final DateTime lastWatched;

  const WatchHistoryModel({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.videoUrl,
    required this.totalDuration,
    required this.watchedPosition,
    required this.lastWatched,
  });

  factory WatchHistoryModel.fromJson(Map<String, dynamic> json) {
    final source = _resolveSource(json);
    final playbackId = source['muxPlaybackId']?.toString();

    return WatchHistoryModel(
      videoId:
          _firstNonEmpty([
            json['videoId']?.toString(),
            json['video_id']?.toString(),
            source['_id']?.toString(),
            source['id']?.toString(),
          ]) ??
          '',
      title:
          _firstNonEmpty([
            source['title']?.toString(),
            source['name']?.toString(),
            source['videoTitle']?.toString(),
            json['title']?.toString(),
            json['name']?.toString(),
            json['videoTitle']?.toString(),
          ]) ??
          'Untitled',
      thumbnail: _normalizeUrl(
        _firstNonEmpty([
              source['thumbnail']?.toString(),
              source['thumbnailUrl']?.toString(),
              source['thumbnail_url']?.toString(),
              source['thumb']?.toString(),
              source['image']?.toString(),
              source['poster']?.toString(),
              source['banner']?.toString(),
              json['thumbnail']?.toString(),
              json['thumbnailUrl']?.toString(),
              json['thumbnail_url']?.toString(),
              json['thumb']?.toString(),
              json['image']?.toString(),
              json['poster']?.toString(),
              json['banner']?.toString(),
              (playbackId != null && playbackId.isNotEmpty)
                  ? 'https://image.mux.com/$playbackId/thumbnail.jpg?time=1'
                  : null,
            ]) ??
            '',
      ),
      videoUrl: _normalizeUrl(
        _firstNonEmpty([
              source['videoUrl']?.toString(),
              source['video_url']?.toString(),
              source['streamUrl']?.toString(),
              source['hlsManifest']?.toString(),
              source['url']?.toString(),
              json['videoUrl']?.toString(),
              json['video_url']?.toString(),
              json['streamUrl']?.toString(),
              (playbackId != null && playbackId.isNotEmpty)
                  ? 'https://stream.mux.com/$playbackId.m3u8'
                  : null,
            ]) ??
            '',
      ),
      totalDuration: _readInt(
        json['totalDuration'] ??
            json['total_duration'] ??
            source['durationSeconds'] ??
            source['duration'] ??
            json['durationSeconds'],
      ),
      watchedPosition: _readInt(
        json['watchedPosition'] ??
            json['watched_position'] ??
            json['lastPositionSeconds'] ??
            json['last_position_seconds'] ??
            json['lastPosition'] ??
            source['lastPositionSeconds'],
      ),
      lastWatched:
          DateTime.tryParse(
            json['lastWatched']?.toString() ??
                json['watchedAt']?.toString() ??
                json['updatedAt']?.toString() ??
                json['createdAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'thumbnail': thumbnail,
      'videoUrl': videoUrl,
      'totalDuration': totalDuration,
      'watchedPosition': watchedPosition,
      'lastWatched': lastWatched.toIso8601String(),
    };
  }

  WatchHistoryModel copyWith({
    String? videoId,
    String? title,
    String? thumbnail,
    String? videoUrl,
    int? totalDuration,
    int? watchedPosition,
    DateTime? lastWatched,
  }) {
    return WatchHistoryModel(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      videoUrl: videoUrl ?? this.videoUrl,
      totalDuration: totalDuration ?? this.totalDuration,
      watchedPosition: watchedPosition ?? this.watchedPosition,
      lastWatched: lastWatched ?? this.lastWatched,
    );
  }

  static Map<String, dynamic> _resolveSource(Map<String, dynamic> json) {
    bool hasVideoFields(Map<String, dynamic> map) {
      const probeKeys = [
        '_id',
        'id',
        'title',
        'name',
        'videoTitle',
        'thumbnail',
        'thumbnailUrl',
        'thumbnail_url',
        'thumb',
        'videoUrl',
        'video_url',
        'muxPlaybackId',
      ];
      for (final key in probeKeys) {
        if (map.containsKey(key)) return true;
      }
      return false;
    }

    Map<String, dynamic>? mapFrom(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return null;
    }

    final candidates = <Map<String, dynamic>>[];

    for (final key in [
      'video',
      'videoData',
      'videoDetails',
      'details',
      'item',
      'content',
      'data',
      'videoId',
    ]) {
      final value = json[key];
      final asMap = mapFrom(value);
      if (asMap != null) {
        candidates.add(asMap);
        for (final nestedKey in ['video', 'data', 'details']) {
          final nested = mapFrom(asMap[nestedKey]);
          if (nested != null) candidates.add(nested);
        }
      }
    }

    candidates.add(json);

    Map<String, dynamic> best = json;
    int bestScore = -1;
    for (final candidate in candidates) {
      var score = 0;
      if (hasVideoFields(candidate)) score += 2;
      if ((candidate['title'] ?? candidate['name']) != null) score += 2;
      if ((candidate['thumbnail'] ??
              candidate['thumbnailUrl'] ??
              candidate['thumb']) !=
          null) {
        score += 2;
      }
      if ((candidate['videoUrl'] ?? candidate['video_url']) != null) score += 1;
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }

    return best;
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  static int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _normalizeUrl(String url) {
    final value = url.trim();
    if (value.isEmpty) return value;
    if (value == 'null' || value == 'undefined') return '';
    if (value.startsWith('//')) return 'https:$value';
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;
    if (value.startsWith('/')) return '$_apiOrigin$value';
    return '$_apiOrigin/$value';
  }
}
