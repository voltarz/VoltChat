import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/secure_session_storage.dart';
import '../../domain/repositories/device_link_repository.dart';
import '../../data/services/secure_storage_service.dart';
import '../../data/services/mock_auth_service.dart';
import '../../data/services/mock_device_link_service.dart';

class Locator {
  static final Locator _instance = Locator._internal();

  factory Locator() {
    return _instance;
  }

  Locator._internal();

  late SecureSessionStorage secureStorage;
  late AuthRepository authRepository;
  late DeviceLinkRepository deviceLinkRepository;

  void setup() {
    secureStorage = SecureStorageService();
    authRepository = MockAuthService(secureStorage);
    deviceLinkRepository = MockDeviceLinkService();
  }
}

final locator = Locator();
