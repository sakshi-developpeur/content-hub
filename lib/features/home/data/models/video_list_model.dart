import 'package:estoriz/features/home/data/models/audio_track_model.dart';

class VideoItem {
  static const String _apiOrigin = 'http://13.203.145.200:8004';

  final String id;
  final String title;
  final String thumbnail;
  final String? videoUrl;
  final String? muxPlaybackId;
  final String? description;
  final double? rating;
  final int? duration;
  final String? language;
  final bool accessDenied;
  final List<AudioTrackModel> audioTracks;

  VideoItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.videoUrl,
    this.muxPlaybackId,
    this.description,
    this.rating,
    this.duration,
    this.language,
    this.accessDenied = false,
    this.audioTracks = const [],
  });

  VideoItem copyWith({
    String? id,
    String? title,
    String? thumbnail,
    String? videoUrl,
    String? muxPlaybackId,
    String? description,
    double? rating,
    int? duration,
    String? language,
    bool? accessDenied,
    List<AudioTrackModel>? audioTracks,
  }) {
    return VideoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      videoUrl: videoUrl ?? this.videoUrl,
      muxPlaybackId: muxPlaybackId ?? this.muxPlaybackId,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
      language: language ?? this.language,
      accessDenied: accessDenied ?? this.accessDenied,
      audioTracks: audioTracks ?? this.audioTracks,
    );
  }

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    final source = _resolveSource(json);
    final playbackId = source['muxPlaybackId']?.toString() ?? '';

    // Try to get videoUrl from various fields
    String? videoUrl = _firstNonEmpty([
      source['videoUrl']?.toString(),
      source['video_url']?.toString(),
      source['hlsManifest']?.toString(),
      source['url']?.toString(),
    ]);

    // If no direct URL, construct from muxPlaybackId
    if ((videoUrl == null || videoUrl.isEmpty) && playbackId.isNotEmpty) {
      videoUrl = 'https://stream.mux.com/$playbackId.m3u8';
    }

    final thumbnailUrl =
        _firstNonEmpty([
          source['thumbnailUrl']?.toString(),
          source['thumbnail']?.toString(),
          source['image']?.toString(),
          source['poster']?.toString(),
        ]) ??
        (playbackId.isNotEmpty
            ? 'https://image.mux.com/$playbackId/thumbnail.jpg?time=1'
            : '');

    // Parse audio tracks
    final rawTracks = source['audioTracks'];
    final audioTracks = <AudioTrackModel>[];
    if (rawTracks is List) {
      for (final track in rawTracks) {
        if (track is Map<String, dynamic>) {
          audioTracks.add(AudioTrackModel.fromJson(track));
        }
      }
    }

    return VideoItem(
      id: source['_id']?.toString() ?? source['id']?.toString() ?? '',
      title: source['title']?.toString() ?? 'Untitled',
      thumbnail: _normalizeUrl(thumbnailUrl),
      videoUrl: videoUrl,
      muxPlaybackId: playbackId.isNotEmpty ? playbackId : null,
      description: source['description']?.toString(),
      rating: source['rating'] is num
          ? (source['rating'] as num).toDouble()
          : null,
      duration: source['duration'] is num
          ? (source['duration'] as num).toInt()
          : null,
      language: source['language']?.toString(),
      accessDenied: source['accessDenied'] == true,
      audioTracks: audioTracks,
    );
  }

  static Map<String, dynamic> _resolveSource(Map<String, dynamic> json) {
    bool isLikelyVideoMap(Map<String, dynamic> map) {
      const probeKeys = [
        '_id',
        'id',
        'title',
        'thumbnailUrl',
        'thumbnail',
        'videoUrl',
        'muxPlaybackId',
      ];
      for (final key in probeKeys) {
        if (map.containsKey(key)) return true;
      }
      return false;
    }

    for (final key in ['video', 'videoData', 'item', 'data']) {
      final value = json[key];
      if (value is Map) {
        final candidate = Map<String, dynamic>.from(value);
        if (isLikelyVideoMap(candidate)) return candidate;
      }
    }
    return json;
  }

  static String _normalizeUrl(String url) {
    final value = url.trim();
    if (value.isEmpty) return value;
    if (value.startsWith('//')) return 'https:$value';
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;
    if (value.startsWith('/')) return '$_apiOrigin$value';
    return '$_apiOrigin/$value';
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }
}

class VideoListResponse {
  final List<VideoItem> videos;
  final int? totalCount;
  final int? currentPage;
  final int? totalPages;

  VideoListResponse({
    required this.videos,
    this.totalCount,
    this.currentPage,
    this.totalPages,
  });

  factory VideoListResponse.fromJson(Map<String, dynamic> json) {
    // Handle different response formats
    List<VideoItem> videos = [];
    String? categoryThumbnailFallback;

    // Check if response is directly a list
    if (json is List) {
      videos = (json as List)
          .map((v) => VideoItem.fromJson(v as Map<String, dynamic>))
          .toList();
      return VideoListResponse(videos: videos);
    }

    // Check direct 'data' array
    if (json['data'] is List) {
      videos = (json['data'] as List)
          .map((v) => VideoItem.fromJson(v as Map<String, dynamic>))
          .toList();
    }
    // Check nested 'data.docs' or 'data.videos' structure
    else if (json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap['category'] is Map<String, dynamic>) {
        final category = dataMap['category'] as Map<String, dynamic>;
        categoryThumbnailFallback =
            category['thumbnailUrl']?.toString() ??
            category['thumbnail']?.toString() ??
            category['image']?.toString();
      }

      if (dataMap['docs'] is List) {
        videos = (dataMap['docs'] as List)
            .map((v) => VideoItem.fromJson(v as Map<String, dynamic>))
            .toList();
      } else if (dataMap['videos'] is List) {
        final rawVideos = (dataMap['videos'] as List)
            .whereType<Map>()
            .map((v) => Map<String, dynamic>.from(v))
            .toList(growable: false);
        videos = _parseVideosWithCategoryFallback(
          rawVideos,
          categoryThumbnailFallback,
        );
      } else if (dataMap['items'] is List) {
        videos = (dataMap['items'] as List)
            .map((v) => VideoItem.fromJson(v as Map<String, dynamic>))
            .toList();
      } else if (dataMap['results'] is List) {
        videos = (dataMap['results'] as List)
            .map((v) => VideoItem.fromJson(v as Map<String, dynamic>))
            .toList();
      }
    }
    // Check 'videos' array at root
    else if (json['videos'] is List) {
      videos = (json['videos'] as List)
          .map((v) => VideoItem.fromJson(v as Map<String, dynamic>))
          .toList();
    }
    // Check other common array keys
    else if (json['items'] is List) {
      videos = (json['items'] as List)
          .map((v) => VideoItem.fromJson(v as Map<String, dynamic>))
          .toList();
    } else if (json['results'] is List) {
      videos = (json['results'] as List)
          .map((v) => VideoItem.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    final categoryThumb = categoryThumbnailFallback?.trim();
    if (categoryThumb != null && categoryThumb.isNotEmpty) {
      final normalizedCategoryThumb = VideoItem._normalizeUrl(categoryThumb);
      videos = videos
          .map(
            (video) => video.thumbnail.trim().isEmpty
                ? video.copyWith(thumbnail: normalizedCategoryThumb)
                : video,
          )
          .toList(growable: false);
    }

    return VideoListResponse(
      videos: videos,
      totalCount: json['totalCount'] is num ? json['totalCount'] as int? : null,
      currentPage: json['page'] is num ? json['page'] as int? : null,
      totalPages: json['totalPages'] is num ? json['totalPages'] as int? : null,
    );
  }

  static List<VideoItem> _parseVideosWithCategoryFallback(
    List<Map<String, dynamic>> rawVideos,
    String? categoryThumbnailFallback,
  ) {
    final categoryThumb = categoryThumbnailFallback?.trim();
    final hasCategoryThumb = categoryThumb != null && categoryThumb.isNotEmpty;
    final normalizedCategoryThumb = hasCategoryThumb
        ? VideoItem._normalizeUrl(categoryThumb)
        : null;

    return rawVideos
        .map((raw) {
          final item = VideoItem.fromJson(raw);

          final hasExplicitThumb = [
            raw['thumbnailUrl']?.toString(),
            raw['thumbnail']?.toString(),
            raw['image']?.toString(),
            raw['poster']?.toString(),
          ].any((v) => v != null && v.trim().isNotEmpty);

          if (!hasExplicitThumb && hasCategoryThumb) {
            return item.copyWith(thumbnail: normalizedCategoryThumb);
          }
          return item;
        })
        .toList(growable: false);
  }
}
