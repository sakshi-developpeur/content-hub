class AgoraJoinResult {
  final AgoraDetails agora;
  final StreamDetails stream;

  AgoraJoinResult({
    required this.agora,
    required this.stream,
  });

  factory AgoraJoinResult.fromJson(Map<String, dynamic> json) {
    return AgoraJoinResult(
      agora: AgoraDetails.fromJson(json['agora'] ?? {}),
      stream: StreamDetails.fromJson(json['stream'] ?? {}),
    );
  }
}

class AgoraDetails {
  final String token;
  final String channelName;
  final int uid;
  final String appId;
  final String expireAt;

  AgoraDetails({
    required this.token,
    required this.channelName,
    required this.uid,
    required this.appId,
    required this.expireAt,
  });

  factory AgoraDetails.fromJson(Map<String, dynamic> json) {
    return AgoraDetails(
      token: json['token'] ?? '',
      channelName: json['channelName'] ?? '',
      uid: json['uid'] ?? 0,
      appId: json['appId'] ?? '',
      expireAt: json['expireAt'] ?? '',
    );
  }
}

class StreamDetails {
  final String id;
  final String title;
  final String? hostName;
  final int viewerCount;
  final String? startedAt;

  StreamDetails({
    required this.id,
    required this.title,
    this.hostName,
    required this.viewerCount,
    this.startedAt,
  });

  factory StreamDetails.fromJson(Map<String, dynamic> json) {
    return StreamDetails(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      hostName: json['hostName'],
      viewerCount: json['viewerCount'] ?? 0,
      startedAt: json['startedAt'],
    );
  }
}
