class Contact {
  final String id;
  final String displayName;
  final String? phoneNumber;
  final String? profileImageUrl;

  Contact({
    required this.id,
    required this.displayName,
    this.phoneNumber,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      displayName: json['displayName'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}
