import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/repositories/secure_session_storage.dart';

class SecureStorageService implements SecureSessionStorage {
  final FlutterSecureStorage _secureStorage;
  static const String _sessionKey = 'auth_session';

  SecureStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> saveSession(AuthSession session) async {
    final sessionJson = jsonEncode(session.toJson());
    await _secureStorage.write(key: _sessionKey, value: sessionJson);
  }

  @override
  Future<AuthSession?> getSession() async {
    final sessionString = await _secureStorage.read(key: _sessionKey);
    if (sessionString == null) return null;

    try {
      final sessionJson = jsonDecode(sessionString) as Map<String, dynamic>;
      final session = AuthSession.fromJson(sessionJson);

      // Optional: Handle token expiration logic here if needed
      // if (!session.isValid) {
      //   await clearSession();
      //   return null;
      // }

      return session;
    } catch (e) {
      // If parsing fails, clear the corrupted session
      await clearSession();
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    await _secureStorage.delete(key: _sessionKey);
  }
}
