/// Purpose: THE button of the app — one look, one loading behavior, everywhere.
/// Responsibilities: Filled button with built-in busy state (spinner + disabled).
/// Dependencies: flutter. Usage: AppButton(label: 'common.save'.tr, onPressed: ..., busy: c.saving.value)
library;

import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy; // while true: disabled + spinner. Prevents double-taps (double sales!).

  const AppButton({super.key, required this.label, this.onPressed, this.busy = false});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(
              height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(label),
    );
  }
}
