/// Purpose: Contract for the AUTH-007 device-trust RPCs.
/// Responsibilities: Pure interface; one method per deployed RPC + listing.
/// Dependencies: entities only.
/// Usage: injected into login/device-management controllers.
library;

import '../entities/trusted_device.dart';

abstract interface class DeviceRepository {
  Future<bool> isDeviceTrusted(String fingerprint);
  Future<String> trustDevice({
    required String fingerprint,
    required String name,
    required String platform,
  });
  Future<void> touchDevice(String fingerprint);
  Future<List<TrustedDevice>> listDevices();
  Future<void> revokeDevice(String deviceId);
  Future<int> revokeAllDevices();
  Future<int> revokeOtherDevices(String currentFingerprint);
}
