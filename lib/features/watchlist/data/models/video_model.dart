class VideoModel {
  final String id;
  final String title;
  final String thumbnail;
  final String videoUrl;
  final int watchedPosition;
  final int totalDuration;

  const VideoModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.videoUrl,
    this.watchedPosition = 0,
    this.totalDuration = 0,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      watchedPosition: _readInt(json['watchedPosition']),
      totalDuration: _readInt(json['totalDuration']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'videoUrl': videoUrl,
      'watchedPosition': watchedPosition,
      'totalDuration': totalDuration,
    };
  }

  VideoModel copyWith({
    String? id,
    String? title,
    String? thumbnail,
    String? videoUrl,
    int? watchedPosition,
    int? totalDuration,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      videoUrl: videoUrl ?? this.videoUrl,
      watchedPosition: watchedPosition ?? this.watchedPosition,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}
