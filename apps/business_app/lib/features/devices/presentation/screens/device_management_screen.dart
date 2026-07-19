/// Purpose: Device registry UI (name, platform, trusted/expiry/last-seen,
/// current-device marker; revoke one / revoke all). Renders state only.
/// Dependencies: get, ui_kit, intl-free date text via localization keys.
library;

import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_kit/ui_kit.dart';

import '../controllers/device_management_controller.dart';

class DeviceManagementScreen extends GetView<DeviceManagementController> {
  const DeviceManagementScreen({super.key});

  String _d(DateTime? t) => t == null
      ? '—'
      : '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('devices.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'devices.revoke_all'.tr,
            onPressed: () => _confirmRevokeAll(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const LoadingView();
        }

        if (controller.errorKey.value != null) {
          return ErrorView(
            messageKey: controller.errorKey.value!,
            onRetry: controller.load,
          );
        }

        if (controller.items.isEmpty) {
          return const EmptyView(
            messageKey: 'devices.empty',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            padding: const EdgeInsetsDirectional.all(16),
            itemCount: controller.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = controller.items[i];
              final current = controller.isCurrent(d);

              return Card(
                child: ListTile(
                  leading: Icon(
                    current ? Icons.smartphone : Icons.devices_other_outlined,
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          d.name ?? 'devices.unnamed'.tr,
                        ),
                      ),
                      if (current)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          child: Chip(
                            label: Text('devices.current'.tr),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    '${d.platform ?? '—'} · '
                    '${d.isCurrentlyTrusted ? 'devices.trusted'.tr : 'devices.not_trusted'.tr}\n'
                    '${'devices.expires'.trParams({
                          'date': _d(d.expiresAt)
                        })} · '
                    '${'devices.last_seen'.trParams({
                          'date': _d(d.lastSeenAt)
                        })}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'devices.revoke'.tr,
                    onPressed: () => _confirmRevoke(context, d),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _confirmRevoke(BuildContext context, TrustedDevice d) {
    final current = controller.isCurrent(d);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('devices.revoke'.tr),
        content: Text(
          current
              ? 'devices.confirm_revoke_current'.tr
              : 'devices.confirm_revoke'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('common.cancel'.tr),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.revoke(d);
            },
            child: Text('devices.revoke'.tr),
          ),
        ],
      ),
    );
  }

  void _confirmRevokeAll(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('devices.revoke_all'.tr),
        content: Text('devices.confirm_revoke_all'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('common.cancel'.tr),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.revokeAll();
            },
            child: Text('devices.revoke_all'.tr),
          ),
        ],
      ),
    );
  }
}
