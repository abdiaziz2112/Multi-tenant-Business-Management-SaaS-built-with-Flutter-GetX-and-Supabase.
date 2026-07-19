/// Purpose: Unlock (biometric/PIN) and first-time PIN-setup screens.
/// Dependencies: get, ui_kit, UnlockController.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ui_kit/ui_kit.dart';

import '../controllers/unlock_controller.dart';

class UnlockScreen extends GetView<UnlockController> {
  const UnlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(children: [
                const Icon(Icons.lock_outline_rounded, size: 48),
                const SizedBox(height: 12),
                Text('auth.unlock.title'.tr,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                TextField(
                  controller: controller.pin,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      labelText: 'auth.unlock.pin'.tr, counterText: ''),
                  onSubmitted: (_) => controller.submitPin(),
                ),
                Obx(() => controller.errorKey.value == null
                    ? const SizedBox.shrink()
                    : Text(controller.errorKey.value!.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                      label: 'auth.unlock.title'.tr,
                      onPressed: controller.submitPin),
                ),
                Obx(() => controller.biometricAvailable.value
                    ? TextButton.icon(
                        onPressed: controller.retryBiometric,
                        icon: const Icon(Icons.fingerprint),
                        label: Text('auth.unlock.biometric'.tr))
                    : const SizedBox.shrink()),
                TextButton(
                    onPressed: controller.signOut,
                    child: Text('auth.signout'.tr)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class PinSetupScreen extends GetView<UnlockController> {
  const PinSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String? pinValidator(String? v) =>
        (v == null || v.length < 4 || v.length > 6)
            ? 'auth.pin_setup.pin'
            : null;
    return Scaffold(
      appBar: AppBar(title: Text('auth.pin_setup.title'.tr)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Form(
                key: controller.setupKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('auth.pin_setup.body'.tr),
                      const SizedBox(height: 16),
                      AppTextField(
                          label: 'auth.pin_setup.pin'.tr,
                          controller: controller.newPin,
                          obscure: true,
                          keyboardType: TextInputType.number,
                          validator: pinValidator),
                      const SizedBox(height: 12),
                      AppTextField(
                          label: 'auth.pin_setup.confirm'.tr,
                          controller: controller.confirmPin,
                          obscure: true,
                          keyboardType: TextInputType.number,
                          validator: pinValidator),
                      const SizedBox(height: 8),
                      Obx(() => controller.errorKey.value == null
                          ? const SizedBox.shrink()
                          : Text(controller.errorKey.value!.tr,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error))),
                      const SizedBox(height: 16),
                      Obx(() => AppButton(
                            label: 'auth.pin_setup.button'.tr,
                            busy: controller.busy.value,
                            onPressed: controller.savePin,
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
