/// Purpose: One OTP screen for both modes (signup verify / device challenge).
/// Dependencies: get, ui_kit, controller.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_kit/ui_kit.dart';

import '../controllers/otp_controller.dart';

class OtpScreen extends GetView<OtpController> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signup = controller.mode == OtpMode.signup;
    return Scaffold(
      appBar: AppBar(
          title: Text(signup ? 'auth.verify.title'.tr : 'auth.otp.title'.tr)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(children: [
                Text(
                  (signup ? 'auth.verify.body' : 'auth.otp.body')
                      .trParams({'email': controller.email}),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OtpInput(onCompleted: controller.verify),
                const SizedBox(height: 8),
                Obx(() => controller.busy.value
                    ? const LoadingView()
                    : const SizedBox.shrink()),
                Obx(() => controller.errorKey.value == null
                    ? const SizedBox.shrink()
                    : Text(controller.errorKey.value!.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
                const SizedBox(height: 16),
                Obx(() => TextButton(
                      onPressed: controller.cooldown.value == 0
                          ? controller.resend
                          : null,
                      child: Text(controller.cooldown.value == 0
                          ? 'auth.verify.resend'.tr
                          : 'auth.verify.resend_in'.trParams(
                              {'seconds': '${controller.cooldown.value}'})),
                    )),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
