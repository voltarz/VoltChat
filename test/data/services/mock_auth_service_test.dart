import 'package:flutter_test/flutter_test.dart';
import 'package:voltchat/data/services/mock_auth_service.dart';
import 'package:voltchat/domain/models/auth_session.dart';
import 'package:voltchat/domain/repositories/secure_session_storage.dart';

class MockSecureStorage implements SecureSessionStorage {
  AuthSession? _session;

  @override
  Future<void> clearSession() async {
    _session = null;
  }

  @override
  Future<AuthSession?> getSession() async {
    return _session;
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    _session = session;
  }
}

void main() {
  group('MockAuthService Tests', () {
    late MockAuthService authService;
    late MockSecureStorage mockStorage;

    setUp(() {
      mockStorage = MockSecureStorage();
      authService = MockAuthService(mockStorage);
    });

    test('login should save session and set current user', () async {
      final user = await authService.login('testuser', 'password');
      expect(user.username, 'testuser');

      final session = await mockStorage.getSession();
      expect(session, isNotNull);
      expect(session?.userId, user.id);

      final currentUser = await authService.getCurrentUser();
      expect(currentUser?.id, user.id);
    });

    test('logout should clear session and current user', () async {
      await authService.login('testuser', 'password');
      await authService.logout();

      final session = await mockStorage.getSession();
      expect(session, isNull);

      final currentUser = await authService.getCurrentUser();
      expect(currentUser, isNull);
    });

    test('hasValidSession should return true if valid session exists', () async {
      final session = AuthSession(
        userId: '1',
        accessToken: 'token',
        refreshToken: 'refresh',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
      await mockStorage.saveSession(session);

      expect(await authService.hasValidSession(), isTrue);
    });

    test('hasValidSession should return false if session is expired', () async {
      final session = AuthSession(
        userId: '1',
        accessToken: 'token',
        refreshToken: 'refresh',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      await mockStorage.saveSession(session);

      expect(await authService.hasValidSession(), isFalse);
    });

    test('getCurrentUser should rehydrate user from valid session', () async {
      final session = AuthSession(
        userId: 'user_123',
        accessToken: 'token',
        refreshToken: 'refresh',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
      await mockStorage.saveSession(session);

      final user = await authService.getCurrentUser();
      expect(user, isNotNull);
      expect(user?.id, 'user_123');
    });
  });
}
