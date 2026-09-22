class Conversation {
  final String id;
  final String participantId;
  final String? broadcastOriginId;
  final DateTime lastUpdatedAt;

  Conversation({
    required this.id,
    required this.participantId,
    this.broadcastOriginId,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'broadcastOriginId': broadcastOriginId,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      participantId: json['participantId'],
      broadcastOriginId: json['broadcastOriginId'],
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
    );
  }
}
