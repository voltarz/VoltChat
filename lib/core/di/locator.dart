import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/secure_session_storage.dart';
import '../../data/services/secure_storage_service.dart';
import '../../data/services/mock_auth_service.dart';

class Locator {
  static final Locator _instance = Locator._internal();

  factory Locator() {
    return _instance;
  }

  Locator._internal();

  late SecureSessionStorage secureStorage;
  late AuthRepository authRepository;

  void setup() {
    secureStorage = SecureStorageService();
    authRepository = MockAuthService(secureStorage);
  }
}

final locator = Locator();
