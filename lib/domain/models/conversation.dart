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
}
