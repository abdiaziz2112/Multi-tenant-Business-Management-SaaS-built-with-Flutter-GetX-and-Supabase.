/// Purpose: Business registration (FR-A1 six fields; 4 feel-like via toggle).
/// Dependencies: get, ui_kit, core validators, controller.
library;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_kit/ui_kit.dart';

import '../controllers/register_controller.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('auth.register.title'.tr)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                        label: 'auth.register.business_name'.tr,
                        controller: controller.businessName,
                        validator: Validators.requiredField),
                    const SizedBox(height: 12),
                    AppTextField(
                        label: 'auth.register.owner_name'.tr,
                        controller: controller.ownerName,
                        validator: Validators.requiredField),
                    const SizedBox(height: 12),
                    AppTextField(
                        label: 'auth.register.business_email'.tr,
                        controller: controller.businessEmail,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email),
                    const SizedBox(height: 12),
                    AppTextField(
                        label: 'auth.register.country'.tr,
                        controller: controller.country,
                        validator: Validators.requiredField),
                    const SizedBox(height: 12),
                    Obx(() => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('auth.register.same_email'.tr),
                          value: controller.sameEmail.value,
                          onChanged: (v) => controller.sameEmail.value = v,
                        )),
                    Obx(() => controller.sameEmail.value
                        ? const SizedBox.shrink()
                        : Padding(
                            padding:
                                const EdgeInsetsDirectional.only(bottom: 12),
                            child: AppTextField(
                                label: 'auth.register.owner_email'.tr,
                                controller: controller.ownerEmail,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.email),
                          )),
                    AppTextField(
                        label: 'auth.password'.tr,
                        controller: controller.password,
                        obscure: true,
                        validator: Validators.password),
                    const SizedBox(height: 8),
                    Obx(() => controller.errorKey.value == null
                        ? const SizedBox.shrink()
                        : Text(controller.errorKey.value!.tr,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                    const SizedBox(height: 16),
                    Obx(() => AppButton(
                          label: 'auth.register.button'.tr,
                          busy: controller.busy.value,
                          onPressed: controller.submit,
                        )),
                    TextButton(
                      onPressed: controller.goLogin,
                      child: Text('auth.register.have_account'.tr),
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
