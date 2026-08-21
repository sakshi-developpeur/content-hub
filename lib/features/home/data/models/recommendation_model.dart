import 'package:estoriz/features/home/data/models/video_model.dart';

class RecommendationItem {
  final String id;
  final String title;
  final String thumbnail;
  final String? videoUrl;
  final String? description;
  final String? duration;
  final String? category;
  final double? score;
  final String? reason;

  const RecommendationItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.videoUrl,
    this.description,
    this.duration,
    this.category,
    this.score,
    this.reason,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    final source = json['video'] is Map
        ? Map<String, dynamic>.from(json['video'] as Map)
        : (json['videoData'] is Map
              ? Map<String, dynamic>.from(json['videoData'] as Map)
              : json);

    final playbackId = source['muxPlaybackId']?.toString();
    final categoryValue = source['category'];

    return RecommendationItem(
      id: source['_id']?.toString() ?? source['id']?.toString() ?? '',
      title: source['title']?.toString() ?? '',
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
      duration: _formatDuration(source['duration']),
      category:
          (categoryValue is Map
              ? Map<String, dynamic>.from(categoryValue)['name']?.toString()
              : source['category']?.toString()) ??
          source['categoryName']?.toString(),
      score: _toDouble(json['score'] ?? json['relevanceScore']),
      reason: json['reason']?.toString() ?? json['explanation']?.toString(),
    );
  }

  factory RecommendationItem.fromVideo(VideoItem video) {
    return RecommendationItem(
      id: video.id,
      title: video.title,
      thumbnail: video.thumbnail,
      videoUrl: video.videoUrl,
      description: video.description,
      duration: video.duration,
      category: video.category,
    );
  }

  static String? _formatDuration(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      final minutes = (value / 60).round();
      return '$minutes min';
    }
    final parsed = num.tryParse(value.toString());
    if (parsed != null) {
      final minutes = (parsed / 60).round();
      return '$minutes min';
    }
    return value.toString();
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

