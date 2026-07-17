/// Purpose: One shared evaluation of "where does this user go now?" —
/// gathers session, business and device-trust state, then asks the resolver.
/// Responsibilities: Orchestration only; fires touch_device (sliding trust
/// renewal) when the device is trusted. No navigation — apps map destinations
/// to their own routes.
/// Dependencies: domain contracts + resolver (no provider types).
/// Usage: final d = await AuthBootstrap.evaluate(auth: ..., business: ...,
/// devices: ..., fingerprint: fp, pinConfigured: p, biometricAvailable: b);
library;

import '../domain/entities/auth_route.dart';
import '../domain/entities/business_status.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/business_repository.dart';
import '../domain/repositories/device_repository.dart';
import 'auth_flow_resolver.dart';

class AuthBootstrap {
  AuthBootstrap._();

  static Future<AuthDestination> evaluate({
    required AuthRepository auth,
    required BusinessRepository business,
    required DeviceRepository devices,
    required String fingerprint,
    required bool pinConfigured,
    required bool biometricAvailable,
  }) async {
    final hasSession = auth.currentUserId != null;
    final verified = hasSession && auth.isEmailVerified;
    final biz = (hasSession && verified) ? await business.fetchOwnBusiness() : null;

    var trusted = false;
    final gateRelevant = biz != null &&
        biz.status == BusinessStatus.approved &&
        biz.setupCompleted;
    if (gateRelevant) {
      trusted = await devices.isDeviceTrusted(fingerprint);
      if (trusted) {
        // Sliding renewal: active trusted devices never surprise-OTP.
        await devices.touchDevice(fingerprint);
      }
    }

    return AuthFlowResolver.resolve(
      hasSession: hasSession,
      emailVerified: verified,
      business: biz,
      deviceTrusted: trusted,
      pinConfigured: pinConfigured,
      biometricAvailable: biometricAvailable,
    );
  }
}
