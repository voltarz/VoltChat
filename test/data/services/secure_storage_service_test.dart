import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voltchat/data/services/secure_storage_service.dart';
import 'package:voltchat/domain/models/auth_session.dart';

void main() {
  group('SecureStorageService Tests', () {
    late SecureStorageService secureStorageService;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      secureStorageService = SecureStorageService();
    });

    test('should save and retrieve session successfully', () async {
      final session = AuthSession(
        userId: 'test_user_1',
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await secureStorageService.saveSession(session);

      final retrievedSession = await secureStorageService.getSession();

      expect(retrievedSession, isNotNull);
      expect(retrievedSession?.userId, 'test_user_1');
      expect(retrievedSession?.accessToken, 'test_access_token');
    });

    test('should return null if no session exists', () async {
      final retrievedSession = await secureStorageService.getSession();
      expect(retrievedSession, isNull);
    });

    test('should clear session correctly', () async {
      final session = AuthSession(
        userId: 'test_user_2',
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await secureStorageService.saveSession(session);
      await secureStorageService.clearSession();

      final retrievedSession = await secureStorageService.getSession();
      expect(retrievedSession, isNull);
    });
  });
}
