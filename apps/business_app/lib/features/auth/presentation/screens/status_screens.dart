/// Purpose: Status screens shown during the business approval lifecycle.
/// Responsibilities: Present pending, rejected and suspended states.
/// Dependencies: Flutter, GetX, ui_kit.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_kit/ui_kit.dart';

//import '../../../../app/routes/app_routes.dart';
import '../controllers/business_status_controller.dart';

class PendingScreen extends GetView<BusinessStatusController> {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusScreen(
      icon: Icons.hourglass_top_rounded,
      iconColor: Colors.orange,
      title: 'auth.pending.title'.tr,
      body: 'auth.pending.body'.tr,
      actions: [
        OutlinedButton(
          onPressed: controller.refreshStatus,
          child: Text('auth.pending.refresh'.tr),
        ),
      ],
    );
  }
}

class RejectedScreen extends GetView<BusinessStatusController> {
  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusScreen(
      icon: Icons.cancel_outlined,
      iconColor: Colors.red,
      title: 'auth.rejected.title'.tr,
      body: 'auth.rejected.body'.tr,
      actions: [
        FilledButton(
          onPressed: controller.resubmit,
          child: Text('auth.rejected.resubmit'.tr),
        ),
      ],
    );
  }
}

class SuspendedScreen extends GetView<BusinessStatusController> {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusScreen(
      icon: Icons.block,
      iconColor: Colors.red,
      title: 'auth.suspended.title'.tr,
      body: 'auth.suspended.body'.tr,
      actions: [
        FilledButton(
          onPressed: controller.signOut,
          child: Text('common.signout'.tr),
        ),
      ],
    );
  }
}
