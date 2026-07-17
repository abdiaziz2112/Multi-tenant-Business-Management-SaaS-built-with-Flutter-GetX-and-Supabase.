/// Purpose: Trusted-device gate: biometric first, PIN fallback (AUTH-007).
/// Responsibilities: Attempt biometrics on arrival; verify PIN via PinService;
/// route home on success; sign-out escape hatch.
/// Dependencies: get, auth package services.
/// Usage: bound to unlock + pin-setup routes.
library;

import 'package:auth/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/navigation/auth_router.dart';
import '../../../../app/routes/app_routes.dart';

class UnlockController extends GetxController {
  UnlockController({AuthRepository? auth}) : _auth = auth ?? Get.find();
  final AuthRepository _auth;

  final pin = TextEditingController();
  final errorKey = RxnString();
  final biometricAvailable = false.obs;

  @override
  void onReady() {
    super.onReady();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    biometricAvailable.value = await BiometricService.instance.canUse();
    if (biometricAvailable.value) {
      final ok = await BiometricService.instance
          .authenticate(localizedReason: 'auth.unlock.reason'.tr);
      if (ok) await Get.offAllNamed<void>(AppRoutes.home);
    }
  }

  Future<void> retryBiometric() => _tryBiometric();

  Future<void> submitPin() async {
    errorKey.value = null;
    if (await PinService.instance.verify(pin.text)) {
      await Get.offAllNamed<void>(AppRoutes.home);
    } else {
      errorKey.value = 'auth.unlock.wrong_pin';
      pin.clear();
    }
  }

  // --- PIN setup (first trusted login without any unlock method) ---
  final setupKey = GlobalKey<FormState>();
  final newPin = TextEditingController();
  final confirmPin = TextEditingController();
  final busy = false.obs;

  Future<void> savePin() async {
    if (!(setupKey.currentState?.validate() ?? false)) return;
    if (newPin.text != confirmPin.text) {
      errorKey.value = 'auth.pin_setup.mismatch';
      return;
    }
    busy.value = true;
    await PinService.instance.setPin(newPin.text);
    busy.value = false;
    await Get.offAllNamed<void>(AppRoutes.home);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await AuthRouter.resolveAndGo();
  }

  @override
  void onClose() {
    for (final c in [pin, newPin, confirmPin]) {
      c.dispose();
    }
    super.onClose();
  }
}
