/// Purpose: Forgot-password and Reset-password screens.
/// Dependencies: get, ui_kit, core validators, PasswordController.
library;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_kit/ui_kit.dart';

import '../controllers/password_controller.dart';

class ForgotPasswordScreen extends GetView<PasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('auth.forgot.title'.tr)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: controller.forgotKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('auth.forgot.body'.tr),
                      const SizedBox(height: 16),
                      AppTextField(
                          label: 'auth.email'.tr,
                          controller: controller.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email),
                      const SizedBox(height: 8),
                      Obx(() => controller.errorKey.value == null
                          ? const SizedBox.shrink()
                          : Text(controller.errorKey.value!.tr,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.error))),
                      const SizedBox(height: 16),
                      Obx(() => AppButton(
                            label: 'auth.forgot.button'.tr,
                            busy: controller.busy.value,
                            onPressed: controller.sendCode,
                          )),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends GetView<PasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('auth.reset.title'.tr)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: controller.resetKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                          label: 'auth.reset.code'.tr,
                          controller: controller.code,
                          keyboardType: TextInputType.number,
                          validator: Validators.requiredField),
                      const SizedBox(height: 12),
                      AppTextField(
                          label: 'auth.reset.new_password'.tr,
                          controller: controller.newPassword,
                          obscure: true,
                          validator: Validators.password),
                      const SizedBox(height: 8),
                      Obx(() => controller.errorKey.value == null
                          ? const SizedBox.shrink()
                          : Text(controller.errorKey.value!.tr,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.error))),
                      const SizedBox(height: 16),
                      Obx(() => AppButton(
                            label: 'auth.reset.button'.tr,
                            busy: controller.busy.value,
                            onPressed: controller.changePassword,
                          )),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
