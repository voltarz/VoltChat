import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthService implements AuthRepository {
  User? _currentUser;

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(seconds: 1));
    return _currentUser;
  }

  @override
  Future<User> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(id: '1', username: username, displayName: 'Test User');
    return _currentUser!;
  }

  @override
  Future<User> register(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(id: '1', username: username, displayName: 'New User');
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = null;
  }
}
