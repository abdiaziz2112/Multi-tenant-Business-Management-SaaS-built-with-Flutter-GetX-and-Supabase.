/// Purpose: Forgot + Reset password flows (recovery OTP, AUTH-007: codes only).
/// Responsibilities: Send recovery code; verify; set new password; then
/// AUTOMATICALLY revoke_other_devices(current) per FR-A18 — the deployed
/// password-change contract.
/// Dependencies: get, auth contracts.
/// Usage: bound to forgot/reset routes; email carried between them.
library;

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/navigation/auth_router.dart';
import '../../../../app/routes/app_routes.dart';

class PasswordController extends GetxController {
  PasswordController({
    AuthRepository? auth,
    DeviceRepository? devices,
    Future<String> Function()? getFingerprint,
  })  : _auth = auth ?? Get.find(),
        _devices = devices ?? Get.find(),
        _getFingerprint =
            getFingerprint ?? DeviceIdentityService.instance.fingerprint;

  final Future<String> Function() _getFingerprint;
  final AuthRepository _auth;
  final DeviceRepository _devices;

  final forgotKey = GlobalKey<FormState>();
  final resetKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final code = TextEditingController();
  final newPassword = TextEditingController();
  final busy = false.obs;
  final errorKey = RxnString();

  Future<void> sendCode() async {
    if (!(forgotKey.currentState?.validate() ?? false)) return;

    busy.value = true;
    errorKey.value = null;

    try {
      await _auth.sendPasswordResetOtp(email.text.trim());
      await Get.toNamed<void>(AppRoutes.resetPassword);
    } on Failure catch (f) {
      errorKey.value = f.messageKey;
    } finally {
      busy.value = false;
    }
  }

  Future<void> changePassword() async {
    if (!(resetKey.currentState?.validate() ?? false)) return;
    await changePasswordForTest();
  }

  /// Same flow without Form validation — unit tests validate inputs upstream.
  @visibleForTesting
  Future<void> changePasswordForTest() async {
    busy.value = true;
    errorKey.value = null;

    try {
      await _auth.verifyRecoveryOtp(
        email: email.text.trim(),
        code: code.text.trim(),
      );

      await _auth.updatePassword(newPassword.text);

      // FR-A18: current device survives, every other trusted device dies.
      final fp = await _getFingerprint();
      await _devices.revokeOtherDevices(fp);

      if (Get.context != null) {
        Get.snackbar(
          'auth.reset.title'.tr,
          'auth.reset.devices_revoked'.tr,
        );
      }

      await AuthRouter.resolveAndGo();
    } on Failure catch (f) {
      errorKey.value = f.messageKey;
    } finally {
      busy.value = false;
    }
  }

  @override
  void onClose() {
    for (final controller in [email, code, newPassword]) {
      controller.dispose();
    }

    super.onClose();
  }
}
