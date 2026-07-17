/// Purpose: The four screen states every feature must show (project rule):
/// loading / error / empty / (success = the feature's own content).
/// Responsibilities: One consistent look for each; errors always offer a retry.
/// Dependencies: flutter, get. Usage: LoadingView(), ErrorView(onRetry: ...), EmptyView(...)
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class ErrorView extends StatelessWidget {
  final String messageKey;
  final VoidCallback? onRetry;
  const ErrorView({super.key, this.messageKey = 'errors.unexpected', this.onRetry});

  @override
  Widget build(BuildContext context) {
    // An error explains what to do next — never just a sad message.
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline, size: 40, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 12),
        Text(messageKey.tr, textAlign: TextAlign.center),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: Text('common.retry'.tr)),
        ],
      ]),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String messageKey;
  final Widget? action; // an empty screen is an invitation to act
  const EmptyView({super.key, this.messageKey = 'errors.empty', this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.inbox_outlined, size: 40),
        const SizedBox(height: 12),
        Text(messageKey.tr),
        if (action != null) ...[const SizedBox(height: 12), action!],
      ]),
    );
  }
}
