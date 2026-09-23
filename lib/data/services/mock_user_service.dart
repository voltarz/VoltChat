import '../../domain/models/user.dart';
import '../../domain/repositories/user_repository.dart';

class MockUserService implements UserRepository {
  MockUserService._privateConstructor();
  static final MockUserService _instance = MockUserService._privateConstructor();
  factory MockUserService() => _instance;

  // Mock database of registered users mapped by normalized phone number
  final Map<String, User> _registeredUsers = {
    '1234567890': User(id: 'u1', username: 'alice', displayName: 'Alice Anderson'),
    '0987654321': User(id: 'u2', username: 'bob', displayName: 'Bob Brown'),
  };

  @override
  Future<User> getUserById(String id) async {
    return _registeredUsers.values.firstWhere(
      (user) => user.id == id,
      orElse: () => throw Exception('User not found'),
    );
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    final lowerQuery = query.toLowerCase();
    return _registeredUsers.values
        .where((user) =>
            user.displayName?.toLowerCase().contains(lowerQuery) == true ||
            user.username.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<void> updateUserProfile(User user) async {
    final entry = _registeredUsers.entries.firstWhere((e) => e.value.id == user.id, orElse: () => throw Exception('User not found'));
    _registeredUsers[entry.key] = user;
  }

  @override
  Future<User?> getUserByPhoneNumber(String phoneNumber) async {
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return _registeredUsers[normalizedPhone];
  }
}
