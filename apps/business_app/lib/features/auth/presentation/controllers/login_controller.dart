/// Purpose: State + actions for the Login screen.
/// Responsibilities: Validate, sign in via repository, hand off to AuthRouter.
/// Dependencies: get, auth contracts, core Failure.
/// Usage: bound to the login route; screen renders busy/error state only.
library;

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/navigation/auth_router.dart';
import '../../../../app/routes/app_routes.dart';

class LoginController extends GetxController {
  LoginController({AuthRepository? auth}) : _auth = auth ?? Get.find();
  final AuthRepository _auth;

  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final busy = false.obs;
  final errorKey = RxnString();

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    busy.value = true;
    errorKey.value = null;
    try {
      await _auth.signIn(email: email.text.trim(), password: password.text);
      await AuthRouter.resolveAndGo();
    } on Failure catch (f) {
      errorKey.value = f.messageKey;
    } finally {
      busy.value = false;
    }
  }

  void goForgotPassword() => Get.toNamed<void>(AppRoutes.forgotPassword);
  void goRegister() => Get.offAllNamed<void>(AppRoutes.register);

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
