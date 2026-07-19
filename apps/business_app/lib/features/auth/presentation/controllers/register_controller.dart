/// Purpose: State + actions for business registration (FR-A1: six fields).
/// Responsibilities: signUp (owner identity) THEN register_business (atomic
/// RPC) — matching the deployed contract order proven in Phase A test B1.
/// Dependencies: get, auth contracts, core validators/Failure.
/// Usage: bound to the register route.
library;

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/navigation/auth_router.dart';
import '../../../../app/routes/app_routes.dart';

class RegisterController extends GetxController {
  RegisterController({
    AuthRepository? auth,
    BusinessRepository? businesses,
  })  : _auth = auth ?? Get.find(),
        _businesses = businesses ?? Get.find();

  final AuthRepository _auth;
  final BusinessRepository _businesses;

  final formKey = GlobalKey<FormState>();
  final businessName = TextEditingController();
  final ownerName = TextEditingController();
  final businessEmail = TextEditingController();
  final country = TextEditingController();
  final ownerEmail = TextEditingController();
  final password = TextEditingController();

  final sameEmail = true.obs;
  final busy = false.obs;
  final errorKey = RxnString();

  String get _loginEmail =>
      (sameEmail.value ? businessEmail.text : ownerEmail.text).trim();

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    await submitForTest();
  }

  /// Same flow without Form validation — unit tests validate inputs upstream.
  @visibleForTesting
  Future<void> submitForTest() async {
    busy.value = true;
    errorKey.value = null;

    try {
      await _auth.signUp(
        email: _loginEmail,
        password: password.text,
      );

      await _businesses.registerBusiness(
        businessName: businessName.text.trim(),
        businessEmail: businessEmail.text.trim(),
        country: country.text.trim(),
        ownerName: ownerName.text.trim(),
      );

      // Unverified session -> resolver lands on verifyEmail
      // (single decision point).
      await AuthRouter.resolveAndGo();
    } on Failure catch (f) {
      errorKey.value = f.messageKey;
    } finally {
      busy.value = false;
    }
  }

  void goLogin() => Get.offAllNamed<void>(AppRoutes.login);

  @override
  void onClose() {
    for (final controller in [
      businessName,
      ownerName,
      businessEmail,
      country,
      ownerEmail,
      password,
    ]) {
      controller.dispose();
    }

    super.onClose();
  }
}
