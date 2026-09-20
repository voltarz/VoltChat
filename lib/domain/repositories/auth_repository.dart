import '../models/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> login(String username, String password);
  Future<User> register(String username, String password);
  Future<void> logout();
}
