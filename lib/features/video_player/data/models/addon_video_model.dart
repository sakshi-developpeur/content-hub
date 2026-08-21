class AddonVideoModel {
  const AddonVideoModel({
    required this.id,
    required this.contentId,
    required this.title,
    required this.description,
    required this.hlsManifest,
    required this.thumbnailUrl,
    required this.duration,
    required this.muxPlaybackId,
    required this.isActive,
  });

  final String id;
  final String contentId;
  final String title;
  final String description;
  final String hlsManifest;
  final String thumbnailUrl;
  final int duration;
  final String muxPlaybackId;
  final bool isActive;

  factory AddonVideoModel.fromJson(Map<String, dynamic> json) {
    final muxId = json['muxPlaybackId']?.toString() ?? '';
    final rawThumbnail = json['thumbnailUrl']?.toString() ?? '';

    return AddonVideoModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      contentId: json['contentId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Recommended Video',
      description: json['description']?.toString() ?? '',
      hlsManifest: json['hlsManifest']?.toString() ?? '',
      thumbnailUrl: _resolveThumbnail(rawThumbnail, muxId),
      duration: _parseDuration(json['duration']),
      muxPlaybackId: muxId,
      isActive: json['isActive'] == true,
    );
  }

  static int _parseDuration(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed.round();
      }
    }
    return 0;
  }

  static String _resolveThumbnail(String thumbnailUrl, String muxPlaybackId) {
    final candidate = thumbnailUrl.trim();
    if (candidate.isNotEmpty) {
      return candidate;
    }

    final muxId = muxPlaybackId.trim();
    if (muxId.isEmpty) {
      return '';
    }

    return 'https://image.mux.com/$muxId/thumbnail.jpg';
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'contentId': contentId,
      'title': title,
      'description': description,
      'hlsManifest': hlsManifest,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'muxPlaybackId': muxPlaybackId,
      'isActive': isActive,
    };
  }
}
