import 'package:flutter_test/flutter_test.dart';
import 'package:voltchat/data/services/local_media_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalMediaStorageService Path Resolution', () {
    test('getResolvedPath returns null if input is null or empty', () {
      final service = LocalMediaStorageService();
      expect(service.getResolvedPath(null), isNull);
      expect(service.getResolvedPath(''), isNull);
    });

    test('getResolvedPath returns absolutePath if init() has not been fully configured/called with directory', () {
      final service = LocalMediaStorageService();
      // Without calling init() which requires the disk, it should fallback to the given absolute path
      expect(service.getResolvedPath('/old/path/file.mp4'), '/old/path/file.mp4');
    });
  });
}
