class User {
  final String id;
  final String username;
  final String? displayName;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.username,
    this.displayName,
    this.profileImageUrl,
  });
}
