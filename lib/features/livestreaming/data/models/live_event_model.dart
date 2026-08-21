class LiveEvent {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? thumbnailKey;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final String status;
  final String visibility;
  final String hostId;
  final String? hostName;
  final int viewerCount;
  final int peakViewerCount;
  final int totalViews;
  final List<String> tags;
  final String? reminder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LiveEvent({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.thumbnailKey,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.durationSeconds,
    required this.status,
    required this.visibility,
    required this.hostId,
    this.hostName,
    this.viewerCount = 0,
    this.peakViewerCount = 0,
    this.totalViews = 0,
    this.tags = const [],
    this.reminder,
    this.createdAt,
    this.updatedAt,
  });

  bool get isLive => status == 'live';
  // If it's upcoming, we might say it's "scheduled" and not yet started.
  bool get isUpcoming => status == 'scheduled';
  bool get isEnded => status == 'ended';
  bool get isCancelled => status == 'cancelled';

  factory LiveEvent.fromJson(Map<String, dynamic> json) {
    return LiveEvent(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      thumbnailKey: json['thumbnailKey'],
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      endedAt:
          json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      durationSeconds: json['durationSeconds'],
      status: json['status'] ?? 'scheduled',
      visibility: json['visibility'] ?? 'all',
      hostId: json['hostId'] ?? '',
      hostName: json['hostName'],
      viewerCount: json['viewerCount'] ?? 0,
      peakViewerCount: json['peakViewerCount'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      reminder: json['reminder'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}
