/// Purpose: One controller for both OTP screens (signup verify + new-device
/// challenge) — same UI, different verify/resend/after behavior per mode.
/// Responsibilities: Send/resend with 60s cooldown; verify; on the device
/// challenge, trust_device() after success (AUTH-007), then continue.
/// Dependencies: get, auth contracts.
/// Usage: OtpController(mode: OtpMode.signup / OtpMode.deviceChallenge)
library;

import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:get/get.dart';

import '../../../../app/navigation/auth_router.dart';

enum OtpMode { signup, deviceChallenge }

class OtpController extends GetxController {
  OtpController({
    required this.mode,
    AuthRepository? auth,
    DeviceRepository? devices,
    Future<String> Function()? getFingerprint,
    Future<String> Function()? getDeviceName,
    String? platformLabel,
  })  : _auth = auth ?? Get.find(),
        _devices = devices ?? Get.find(),
        _getFingerprint =
            getFingerprint ?? DeviceIdentityService.instance.fingerprint,
        _getDeviceName =
            getDeviceName ?? DeviceIdentityService.instance.deviceName,
        _platformLabel =
            platformLabel ?? DeviceIdentityService.instance.platformLabel;

  final Future<String> Function() _getFingerprint;
  final Future<String> Function() _getDeviceName;
  final String _platformLabel;

  final OtpMode mode;
  final AuthRepository _auth;
  final DeviceRepository _devices;

  final busy = false.obs;
  final errorKey = RxnString();
  final cooldown = 0.obs;
  Timer? _timer;

  String get email => _auth.currentUserEmail ?? '';

  @override
  void onInit() {
    super.onInit();
    if (mode == OtpMode.deviceChallenge) {
      // Challenge OTPs are app-initiated; signup OTP was sent by signUp().
      resend();
    } else {
      _startCooldown();
    }
  }

  Future<void> verify(String code) async {
    busy.value = true;
    errorKey.value = null;
    try {
      if (mode == OtpMode.signup) {
        await _auth.verifySignupOtp(email: email, code: code);
      } else {
        await _auth.verifyLoginOtp(email: email, code: code);
        final fp = await _getFingerprint();
        await _devices.trustDevice(
          fingerprint: fp,
          name: await _getDeviceName(),
          platform: _platformLabel,
        );
      }
      await AuthRouter.resolveAndGo();
    } on Failure catch (f) {
      errorKey.value = f.messageKey;
    } finally {
      busy.value = false;
    }
  }

  Future<void> resend() async {
    if (cooldown.value > 0) return;
    errorKey.value = null;
    try {
      if (mode == OtpMode.signup) {
        await _auth.resendSignupOtp(email);
      } else {
        await _auth.sendEmailOtp(email);
      }
      _startCooldown();
    } on Failure catch (f) {
      errorKey.value = f.messageKey;
    }
  }

  void _startCooldown() {
    cooldown.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (cooldown.value <= 1) {
        cooldown.value = 0;
        t.cancel();
      } else {
        cooldown.value--;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
