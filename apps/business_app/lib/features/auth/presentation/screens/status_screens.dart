/// Purpose: Pending / Rejected / Suspended / Setup-required screens, all built
/// on the shared StatusScreen scaffold. Render controller state only.
/// Dependencies: get, ui_kit, core validators, BusinessStatusController.
library;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_kit/ui_kit.dart';

import '../controllers/business_status_controller.dart';

class PendingScreen extends GetView<BusinessStatusController> {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusScreen(
      icon: Icons.hourglass_top_rounded,
      iconColor: AppColors.warning,
      title: 'auth.pending.title'.tr,
      body: 'auth.pending.body'.tr,
      actions: [
        OutlinedButton(
            onPressed: controller.refreshStatus,
            child: Text('auth.pending.refresh'.tr)),
        TextButton(
            onPressed: controller.signOut, child: Text('auth.signout'.tr)),
      ],
    );
  }
}

class RejectedScreen extends GetView<BusinessStatusController> {
  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final b = controller.business.value;
      final canResubmit = b?.canResubmit ?? false;
      return StatusScreen(
        icon: Icons.cancel_outlined,
        iconColor: AppColors.danger,
        title: 'auth.rejected.title'.tr,
        body: b?.rejectionReason == null
            ? 'auth.rejected.edit_hint'.tr
            : 'auth.rejected.reason'
                .trParams({'reason': b!.rejectionReason!}),
        extra: !canResubmit
            ? Text('auth.rejected.limit'.tr, textAlign: TextAlign.center)
            : Form(
                key: controller.formKey,
                child: Column(children: [
                  Text('auth.rejected.edit_hint'.tr),
                  const SizedBox(height: 12),
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
                      validator: Validators.email),
                  const SizedBox(height: 12),
                  AppTextField(
                      label: 'auth.register.country'.tr,
                      controller: controller.country,
                      validator: Validators.requiredField),
                  Obx(() => controller.errorKey.value == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsetsDirectional.only(top: 8),
                          child: Text(controller.errorKey.value!.tr,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.error)),
                        )),
                ]),
              ),
        actions: [
          if (canResubmit)
            Obx(() => AppButton(
                  label: 'auth.rejected.resubmit'.tr,
                  busy: controller.busy.value,
                  onPressed: controller.resubmit,
                )),
          TextButton(
              onPressed: controller.signOut, child: Text('auth.signout'.tr)),
        ],
      );
    });
  }
}

class SuspendedScreen extends GetView<BusinessStatusController> {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusScreen(
      icon: Icons.block_outlined,
      iconColor: AppColors.danger,
      title: 'auth.suspended.title'.tr,
      body: 'auth.suspended.body'.tr,
      actions: [
        TextButton(
            onPressed: controller.signOut, child: Text('auth.signout'.tr)),
      ],
    );
  }
}

class SetupRequiredScreen extends GetView<BusinessStatusController> {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusScreen(
      icon: Icons.settings_suggest_outlined,
      title: 'auth.setup_required.title'.tr,
      body: 'auth.setup_required.body'.tr,
      actions: [
        TextButton(
            onPressed: controller.signOut, child: Text('auth.signout'.tr)),
      ],
    );
  }
}
