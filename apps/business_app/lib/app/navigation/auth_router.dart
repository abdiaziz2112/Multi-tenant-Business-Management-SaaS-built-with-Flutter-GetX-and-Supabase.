/// Purpose: The ONE place auth state becomes navigation. Controllers call
/// AuthRouter.resolveAndGo(); screens never decide routes (spec rule).
/// Responsibilities: Gather state -> AuthFlowResolver -> Get.offAllNamed.
/// Also renews device trust (touch_device) whenever a trusted device passes.
/// Dependencies: auth package, get, app routes.
/// Usage: await AuthRouter.resolveAndGo();
library;

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class AuthRouter {
  AuthRouter._();

  /// Test seam: unit tests replace navigation with a recorder.
  static Future<void> Function()? testHook;

  static const _routeFor = {
    AuthDestination.login: AppRoutes.login,
    AuthDestination.verifyEmail: AppRoutes.verifyEmail,
    AuthDestination.continueRegistration: AppRoutes.register,
    AuthDestination.pending: AppRoutes.pending,
    AuthDestination.rejected: AppRoutes.rejected,
    AuthDestination.suspended: AppRoutes.suspended,
    AuthDestination.setupWizard: AppRoutes.setupWizard,
    AuthDestination.otpChallenge: AppRoutes.otpChallenge,
    AuthDestination.pinSetup: AppRoutes.pinSetup,
    AuthDestination.unlock: AppRoutes.unlock,
    AuthDestination.dashboard: AppRoutes.home,
  };

  static Future<void> resolveAndGo() async {
    if (testHook != null) return testHook!();

    final auth = Get.find<AuthRepository>();
    final businesses = Get.find<BusinessRepository>();
    final devices = Get.find<DeviceRepository>();

    var destination = AuthDestination.login;
    try {
      final hasSession = auth.currentUserId != null;
      AuthBusiness? business;
      var trusted = false;
      var pin = false;
      var bio = false;

      if (hasSession && auth.isEmailVerified) {
        business = await businesses.fetchOwnBusiness();
        if (business != null &&
            business.status == BusinessStatus.approved &&
            business.setupCompleted) {
          final fp = await DeviceIdentityService.instance.fingerprint();
          trusted = await devices.isDeviceTrusted(fp);
          if (trusted) {
            await devices.touchDevice(fp); // sliding renewal (AUTH-007)
            pin = await PinService.instance.isSet;
            bio = await BiometricService.instance.canUse();
          }
        }
      }
      destination = AuthFlowResolver.resolve(
        hasSession: hasSession,
        emailVerified: auth.isEmailVerified,
        business: business,
        deviceTrusted: trusted,
        pinConfigured: pin,
        biometricAvailable: bio,
      );
    } on Failure catch (f) {
      // Suspension mid-session arrives as denied reads: fail to safe screens,
      // never to scary errors (graceful handling requirement).
      destination = f.messageKey == 'auth.err.not_approved'
          ? AuthDestination.suspended
          : AuthDestination.login;
    } catch (e, st) {
      // ANY unexpected startup error: developer sees the truth, the user
      // gets the login screen — never an eternal splash (CR-5 spirit).
      debugPrint('AuthRouter unexpected: $e\n$st');
      destination = AuthDestination.login;
    }
    await Get.offAllNamed<void>(_routeFor[destination]!);
  }
}
