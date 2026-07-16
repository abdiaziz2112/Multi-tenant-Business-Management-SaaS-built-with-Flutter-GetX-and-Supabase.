/// Purpose: Portal placeholder proving build + Supabase reach. Replaced in M1
/// by Platform Owner login and the business approval queue.
/// Responsibilities: Render controller state only.
/// Dependencies: get, ui_kit, controller.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_kit/ui_kit.dart';

import '../controllers/foundation_controller.dart';

class FoundationScreen extends GetView<FoundationController> {
  const FoundationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ganacsi — Platform Owner Portal')),
      body: Center(
        child: Obx(() => switch (controller.ping.value) {
              PingStatus.loading => const LoadingView(),
              PingStatus.fail => ErrorView(
                  messageKey: 'foundation.supabase_fail',
                  onRetry: controller.check,
                ),
              PingStatus.ok => Text(
                  'Foundation OK. Plans in database: '
                  '${controller.planNames.join(' · ')}',
                ),
            }),
      ),
    );
  }
}
