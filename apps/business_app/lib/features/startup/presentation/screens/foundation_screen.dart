/// Purpose: Temporary home proving theme + i18n + Supabase all work (this
/// milestone's acceptance test). Replaced by real auth screens in M1.
/// Responsibilities: RENDER controller state; forward taps. No logic here.
/// Dependencies: get, ui_kit, localization, controller.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';

import '../controllers/foundation_controller.dart';

class FoundationScreen extends GetView<FoundationController> {
  const FoundationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('foundation.title'.tr), actions: [
        // Dark-mode toggle — persisted by ThemeService.
        IconButton(
          icon: const Icon(Icons.brightness_6_outlined),
          tooltip: 'common.dark_mode'.tr,
          onPressed: ThemeService.to.toggle,
        ),
        // Language menu — persisted by LocaleService; Arabic flips to RTL live.
        PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          tooltip: 'common.language'.tr,
          onSelected: LocaleService.to.change,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'en', child: Text('English')),
            PopupMenuItem(value: 'so', child: Text('Soomaali')),
            PopupMenuItem(value: 'ar', child: Text('العربية')),
          ],
        ),
      ]),
      body: Padding(
        padding: const EdgeInsetsDirectional.all(24), // Directional = RTL-safe
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('foundation.subtitle'.tr,
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          // Obx rebuilds ONLY this widget when controller.ping changes.
          Obx(() => switch (controller.ping.value) {
                PingStatus.loading => const LoadingView(),
                PingStatus.ok => Row(children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text('foundation.server_ok'.tr),
                  ]),
                PingStatus.fail => ErrorView(
                    messageKey: 'foundation.server_fail',
                    onRetry: controller.retry,
                  ),
              }),
        ]),
      ),
    );
  }
}
