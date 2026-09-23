class LinkedDevice {
  final String id;
  final String name;
  final String platform;
  final DateTime lastActive;
  final bool isCurrentDevice;

  const LinkedDevice({
    required this.id,
    required this.name,
    required this.platform,
    required this.lastActive,
    this.isCurrentDevice = false,
  });

  LinkedDevice copyWith({
    String? id,
    String? name,
    String? platform,
    DateTime? lastActive,
    bool? isCurrentDevice,
  }) {
    return LinkedDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      lastActive: lastActive ?? this.lastActive,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
    );
  }
}
