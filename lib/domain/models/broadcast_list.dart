class BroadcastList {
  final String id;
  final String name;
  final List<String> recipientIds;
  final DateTime createdAt;

  BroadcastList({
    required this.id,
    required this.name,
    required this.recipientIds,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'recipientIds': recipientIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BroadcastList.fromJson(Map<String, dynamic> json) {
    return BroadcastList(
      id: json['id'],
      name: json['name'],
      recipientIds: List<String>.from(json['recipientIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
