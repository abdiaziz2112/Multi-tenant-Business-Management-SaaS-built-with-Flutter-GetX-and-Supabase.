/// Purpose: Sign-in screen. Renders controller state; zero logic.
/// Dependencies: get, ui_kit, core validators, controller.
library;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_kit/ui_kit.dart';

import '../controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('auth.login.title'.tr,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('auth.login.subtitle'.tr),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'auth.email'.tr,
                      controller: controller.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'auth.password'.tr,
                      controller: controller.password,
                      obscure: true,
                      validator: Validators.requiredField,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => controller.errorKey.value == null
                        ? const SizedBox.shrink()
                        : Text(controller.errorKey.value!.tr,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                    const SizedBox(height: 16),
                    Obx(() => AppButton(
                          label: 'auth.login.button'.tr,
                          busy: controller.busy.value,
                          onPressed: controller.submit,
                        )),
                    TextButton(
                      onPressed: controller.goForgotPassword,
                      child: Text('auth.login.forgot'.tr),
                    ),
                    TextButton(
                      onPressed: controller.goRegister,
                      child: Text('auth.login.register'.tr),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
