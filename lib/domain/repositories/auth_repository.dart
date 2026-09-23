import '../models/user.dart';
import '../models/auth_session.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> login(String username, String password);
  Future<User> register(String username, String password);
  Future<void> logout();
  Future<bool> hasValidSession();
  Future<AuthSession?> getSession();
}
