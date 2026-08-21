/// Represents an audio track from the video API response.
///
/// Each video can have zero or more alternate audio tracks (e.g. Hindi, English)
/// that are delivered via HLS and can be switched at runtime.
class AudioTrackModel {
  final String muxTrackId;
  final String languageCode;
  final String name;
  final String url;
  final String s3Key;
  final String status;
  final String? error;
  final String? addedAt;
  final String? id;

  const AudioTrackModel({
    required this.muxTrackId,
    required this.languageCode,
    required this.name,
    required this.url,
    this.s3Key = '',
    this.status = '',
    this.error,
    this.addedAt,
    this.id,
  });

  factory AudioTrackModel.fromJson(Map<String, dynamic> json) {
    return AudioTrackModel(
      muxTrackId: json['muxTrackId']?.toString() ?? '',
      languageCode: json['languageCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      s3Key: json['s3Key']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      error: json['error']?.toString(),
      addedAt: json['addedAt']?.toString(),
      id: json['_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'muxTrackId': muxTrackId,
      'languageCode': languageCode,
      'name': name,
      'url': url,
      's3Key': s3Key,
      'status': status,
      'error': error,
      'addedAt': addedAt,
      '_id': id,
    };
  }

  /// User-friendly display name for this track.
  String get displayName =>
      name.isNotEmpty ? name : languageCode.toUpperCase();
}
