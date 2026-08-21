class SupportTicketModel {
  final String id;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SupportTicketReply> replies;

  const SupportTicketModel({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    required this.replies,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    final rawReplies = json['replies'] is List
        ? json['replies'] as List
        : const <dynamic>[];

    return SupportTicketModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? 'No Subject',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      priority: json['priority']?.toString() ?? 'low',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      replies: rawReplies
          .whereType<Map>()
          .map((e) => SupportTicketReply.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
    );
  }
}

class SupportTicketReply {
  final String id;
  final String sender;
  final String message;
  final DateTime createdAt;

  const SupportTicketReply({
    required this.id,
    required this.sender,
    required this.message,
    required this.createdAt,
  });

  factory SupportTicketReply.fromJson(Map<String, dynamic> json) {
    return SupportTicketReply(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
