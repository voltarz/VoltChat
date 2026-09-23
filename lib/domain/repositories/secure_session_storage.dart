import '../models/auth_session.dart';

abstract class SecureSessionStorage {
  Future<void> saveSession(AuthSession session);
  Future<AuthSession?> getSession();
  Future<void> clearSession();
}
