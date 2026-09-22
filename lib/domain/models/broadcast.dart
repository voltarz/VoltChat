class Broadcast {
  final String id;
  final String senderId;
  final String listId;
  final String content;
  final DateTime sentAt;

  Broadcast({
    required this.id,
    required this.senderId,
    required this.listId,
    required this.content,
    required this.sentAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'listId': listId,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  factory Broadcast.fromJson(Map<String, dynamic> json) {
    return Broadcast(
      id: json['id'],
      senderId: json['senderId'],
      listId: json['listId'],
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt']),
    );
  }
}
