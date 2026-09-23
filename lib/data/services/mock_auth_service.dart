import '../../domain/models/user.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/secure_session_storage.dart';
import 'package:uuid/uuid.dart';

class MockAuthService implements AuthRepository {
  final SecureSessionStorage _secureStorage;
  User? _currentUser;
  final _uuid = const Uuid();

  MockAuthService(this._secureStorage);

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final session = await _secureStorage.getSession();
    if (session != null && session.isValid) {
      // In a real app, we might fetch the user profile from the server here
      // using the session.userId or accessToken.
      // For mock, we'll reconstruct a user from the stored ID.
      _currentUser = User(id: session.userId, username: 'MockUser_${session.userId}', displayName: 'Rehydrated User');
      return _currentUser;
    }
    return null;
  }

  @override
  Future<User> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    final userId = _uuid.v4();
    _currentUser = User(id: userId, username: username, displayName: 'Test User');

    final session = AuthSession(
      userId: userId,
      accessToken: 'mock_access_token_${_uuid.v4()}',
      refreshToken: 'mock_refresh_token_${_uuid.v4()}',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    await _secureStorage.saveSession(session);

    return _currentUser!;
  }

  @override
  Future<User> register(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    final userId = _uuid.v4();
    _currentUser = User(id: userId, username: username, displayName: 'New User');

    final session = AuthSession(
      userId: userId,
      accessToken: 'mock_access_token_${_uuid.v4()}',
      refreshToken: 'mock_refresh_token_${_uuid.v4()}',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    await _secureStorage.saveSession(session);

    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    await _secureStorage.clearSession();
  }

  @override
  Future<bool> hasValidSession() async {
    final session = await _secureStorage.getSession();
    return session != null && session.isValid;
  }

  @override
  Future<AuthSession?> getSession() async {
    return await _secureStorage.getSession();
  }
}
