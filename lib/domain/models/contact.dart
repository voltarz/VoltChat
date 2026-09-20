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
}
