import 'package:estoriz/features/home/data/models/audio_track_model.dart';

class VideoItem {
  final String id;
  final String title;
  final String thumbnail;
  final String? videoUrl;
  final String? description;
  final String? duration;
  final String? category;
  final double? rating;
  final String? year;
  final String? language;
  final bool accessDenied;
  final List<AudioTrackModel> audioTracks;

  const VideoItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.videoUrl,
    this.description,
    this.duration,
    this.category,
    this.rating,
    this.year,
    this.language,
    this.accessDenied = false,
    this.audioTracks = const [],
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    final playbackId = json['muxPlaybackId']?.toString();
    final category = json['category'];

    // Parse audio tracks
    final rawTracks = json['audioTracks'];
    final audioTracks = <AudioTrackModel>[];
    if (rawTracks is List) {
      for (final track in rawTracks) {
        if (track is Map<String, dynamic>) {
          audioTracks.add(AudioTrackModel.fromJson(track));
        }
      }
    }

    return VideoItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      thumbnail:
          json['thumbnail']?.toString() ??
          json['thumbnailUrl']?.toString() ??
          (playbackId != null && playbackId.isNotEmpty
              ? 'https://image.mux.com/$playbackId/thumbnail.jpg?time=1'
              : null) ??
          json['image']?.toString() ??
          '',
      videoUrl:
          json['videoUrl']?.toString() ??
          json['video_url']?.toString() ??
          json['hlsManifest']?.toString() ??
          (playbackId != null && playbackId.isNotEmpty
              ? 'https://stream.mux.com/$playbackId.m3u8'
              : null) ??
          json['url']?.toString(),
      description: json['description']?.toString(),
      duration: _formatDuration(json['duration']),
      category:
          (category is Map<String, dynamic>
              ? category['name']?.toString()
              : json['category']?.toString()) ??
          json['categoryName']?.toString(),
      rating: (json['rating'] as num?)?.toDouble(),
      year: json['year']?.toString() ?? json['releaseYear']?.toString(),
      language: json['language']?.toString(),
      accessDenied: json['accessDenied'] == true,
      audioTracks: audioTracks,
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
}
