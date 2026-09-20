class Contact {
  final String id;
  final String displayName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isVoltChatUser;
  final String? voltChatUserId;

  Contact({
    required this.id,
    required this.displayName,
    this.phoneNumber,
    this.profileImageUrl,
    this.isVoltChatUser = false,
    this.voltChatUserId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'isVoltChatUser': isVoltChatUser,
      'voltChatUserId': voltChatUserId,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      displayName: json['displayName'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      isVoltChatUser: json['isVoltChatUser'] ?? false,
      voltChatUserId: json['voltChatUserId'],
    );
  }
}
