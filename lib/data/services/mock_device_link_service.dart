import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../domain/models/linked_device.dart';
import '../../domain/models/device_pairing_challenge.dart';
import '../../domain/repositories/device_link_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MockDeviceLinkService implements DeviceLinkRepository {
  final _uuid = const Uuid();
  final List<LinkedDevice> _devices = [];
  final Map<String, DevicePairingChallenge> _challenges = {};

  MockDeviceLinkService() {
    // Add current device for mock demonstration
    _devices.add(
      LinkedDevice(
        id: 'mock-current-device-id',
        name: _getDeviceName(),
        platform: _getPlatformName(),
        lastActive: DateTime.now(),
        isCurrentDevice: true,
      ),
    );
  }

  String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  String _getDeviceName() {
    if (kIsWeb) return 'Web Browser';
    if (Platform.isAndroid) return 'Android Device';
    if (Platform.isIOS) return 'iOS Device';
    if (Platform.isWindows) return 'Windows PC';
    if (Platform.isMacOS) return 'Mac';
    return 'Device';
  }

  @override
  Future<List<LinkedDevice>> getLinkedDevices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_devices);
  }

  @override
  Future<void> removeLinkedDevice(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _devices.removeWhere((d) => d.id == id);
  }

  @override
  Future<DevicePairingChallenge> createPairingChallenge() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final challenge = DevicePairingChallenge(
      id: _uuid.v4(),
      // 5 minutes expiry
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
    _challenges[challenge.id] = challenge;
    return challenge;
  }

  @override
  Future<bool> validateAndPairDevice(String challengeId, String deviceName, String platform) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final challenge = _challenges[challengeId];
    if (challenge == null) {
      return false;
    }

    if (!challenge.isValid) {
      return false;
    }

    // Invalidate challenge (use it)
    _challenges[challengeId] = challenge.copyWith(isUsed: true);

    // Pair device
    _devices.add(
      LinkedDevice(
        id: _uuid.v4(),
        name: deviceName,
        platform: platform,
        lastActive: DateTime.now(),
      ),
    );

    return true;
  }

  @override
  Future<void> invalidateChallenge(String challengeId) async {
    final challenge = _challenges[challengeId];
    if (challenge != null) {
      _challenges[challengeId] = challenge.copyWith(isUsed: true);
    }
  }
}
