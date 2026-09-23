import '../models/linked_device.dart';
import '../models/device_pairing_challenge.dart';

abstract class DeviceLinkRepository {
  Future<List<LinkedDevice>> getLinkedDevices();
  Future<void> removeLinkedDevice(String id);
  Future<DevicePairingChallenge> createPairingChallenge();
  Future<bool> validateAndPairDevice(String challengeId, String deviceName, String platform);
  Future<void> invalidateChallenge(String challengeId);
}
