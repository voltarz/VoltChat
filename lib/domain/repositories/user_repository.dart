import '../models/user.dart';

abstract class UserRepository {
  Future<User> getUserById(String id);
  Future<List<User>> searchUsers(String query);
  Future<void> updateUserProfile(User user);
  Future<User?> getUserByPhoneNumber(String phoneNumber);
}
