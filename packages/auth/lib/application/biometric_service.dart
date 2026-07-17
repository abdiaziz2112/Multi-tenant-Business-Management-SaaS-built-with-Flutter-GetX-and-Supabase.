/// Purpose: Biometric unlock (fingerprint / Face ID) for trusted devices.
/// Responsibilities: Thin wrapper over the platform biometric prompt with a
/// capability check; localized reason text is passed IN (no strings here).
/// Dependencies: local_auth.
/// Usage: if (await BiometricService.instance.canUse()) { ...authenticate }
library;

import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService._();
  static final instance = BiometricService._();

  final _auth = LocalAuthentication();

  Future<bool> canUse() async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Returns true on success; false on failure/cancel. Never throws to UI.
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false, // device PIN/pattern allowed (AUTH-007)
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
