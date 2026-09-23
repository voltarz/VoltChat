class DevicePairingChallenge {
  final String id;
  final DateTime expiresAt;
  final bool isUsed;

  const DevicePairingChallenge({
    required this.id,
    required this.expiresAt,
    this.isUsed = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && !isUsed;

  DevicePairingChallenge copyWith({
    String? id,
    DateTime? expiresAt,
    bool? isUsed,
  }) {
    return DevicePairingChallenge(
      id: id ?? this.id,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
    );
  }
}
