class BannerItem {
  final String id;
  final String title;
  final String thumbnail;
  final String? videoUrl;
  final String? description;
  final String? duration;
  final String? genre;

  const BannerItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.videoUrl,
    this.description,
    this.duration,
    this.genre,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    final playbackId = json['muxPlaybackId']?.toString();
    final category = json['category'];

    return BannerItem(
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
      genre:
          json['genre']?.toString() ??
          (category is Map<String, dynamic>
              ? category['name']?.toString()
              : json['category']?.toString()),
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
