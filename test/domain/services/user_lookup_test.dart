import 'package:flutter_test/flutter_test.dart';
import 'package:voltchat/data/services/mock_user_service.dart';

void main() {
  group('MockUserService Phone Number Lookup', () {
    test('getUserByPhoneNumber normalizes and finds registered user', () async {
      final service = MockUserService();

      // The internal map has '1234567890' -> Alice

      // Test direct match
      var user = await service.getUserByPhoneNumber('1234567890');
      expect(user, isNotNull);
      expect(user!.username, 'alice');

      // Test with country code and formatting
      user = await service.getUserByPhoneNumber('+1 (234) 567-890');
      expect(user, isNotNull);
      expect(user!.username, 'alice');

      // Test with dashes
      user = await service.getUserByPhoneNumber('123-456-7890');
      expect(user, isNotNull);
      expect(user!.username, 'alice');
    });

    test('getUserByPhoneNumber returns null for unregistered phone number', () async {
      final service = MockUserService();

      final user = await service.getUserByPhoneNumber('+1 (999) 888-7777');
      expect(user, isNull);
    });
  });
}
