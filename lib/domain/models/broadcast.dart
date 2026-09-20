class Broadcast {
  final String id;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final List<String> recipientIds;

  Broadcast({
    required this.id,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.recipientIds,
  });
}
