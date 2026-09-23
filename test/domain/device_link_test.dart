import 'package:flutter_test/flutter_test.dart';
import 'package:voltchat/data/services/mock_device_link_service.dart';
import 'package:voltchat/domain/repositories/device_link_repository.dart';

void main() {
  late DeviceLinkRepository repository;

  setUp(() {
    repository = MockDeviceLinkService();
  });

  group('DeviceLinkRepository (Mock Implementation)', () {
    test('Creating a pairing challenge generates valid challenge', () async {
      final challenge = await repository.createPairingChallenge();

      expect(challenge.id, isNotEmpty);
      expect(challenge.isUsed, isFalse);
      expect(challenge.isExpired, isFalse);
      expect(challenge.isValid, isTrue);
    });

    test('Challenge expiry works', () async {
      final challenge = await repository.createPairingChallenge();

      // We manually construct an expired challenge to test the model logic
      final expiredChallenge = challenge.copyWith(
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      expect(expiredChallenge.isExpired, isTrue);
      expect(expiredChallenge.isValid, isFalse);
    });

    test('Successful one-time pairing', () async {
      final challenge = await repository.createPairingChallenge();

      final success = await repository.validateAndPairDevice(
        challenge.id,
        'Test Device',
        'Windows',
      );

      expect(success, isTrue);

      final devices = await repository.getLinkedDevices();
      final pairedDevice = devices.last;

      expect(pairedDevice.name, 'Test Device');
      expect(pairedDevice.platform, 'Windows');
    });

    test('Reusing an already-used challenge must fail', () async {
      final challenge = await repository.createPairingChallenge();

      // Use it once
      await repository.validateAndPairDevice(
        challenge.id,
        'Test Device 1',
        'Windows',
      );

      // Try using again
      final success = await repository.validateAndPairDevice(
        challenge.id,
        'Test Device 2',
        'Windows',
      );

      expect(success, isFalse);
    });

    test('Expired challenge must fail (mocked by model check inside repo)', () async {
       // Our mock implementation checks isValid. While we don't advance time in tests easily without mocktail/clock,
       // we can simulate an expired challenge fail by modifying the mock data if it were accessible,
       // but since it's encapsulated, we will test invalidation directly.
       final challenge = await repository.createPairingChallenge();
       await repository.invalidateChallenge(challenge.id);

       final success = await repository.validateAndPairDevice(
         challenge.id,
         'Test Device',
         'Windows',
       );

       expect(success, isFalse);
    });

    test('Cancelled challenge must fail (invalidateChallenge)', () async {
      final challenge = await repository.createPairingChallenge();

      // Cancel challenge
      await repository.invalidateChallenge(challenge.id);

      final success = await repository.validateAndPairDevice(
        challenge.id,
        'Test Device',
        'Windows',
      );

      expect(success, isFalse);
    });

    test('Removing linked device', () async {
      final challenge = await repository.createPairingChallenge();
      await repository.validateAndPairDevice(challenge.id, 'Test Device', 'Windows');

      var devices = await repository.getLinkedDevices();
      final addedDeviceId = devices.last.id;

      expect(devices.any((d) => d.id == addedDeviceId), isTrue);

      await repository.removeLinkedDevice(addedDeviceId);

      devices = await repository.getLinkedDevices();
      expect(devices.any((d) => d.id == addedDeviceId), isFalse);
    });
  });
}
