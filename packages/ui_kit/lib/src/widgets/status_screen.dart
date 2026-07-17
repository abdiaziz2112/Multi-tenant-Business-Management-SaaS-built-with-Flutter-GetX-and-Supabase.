/// Purpose: One consistent scaffold for auth status states (Pending, Rejected,
/// Suspended, Setup-required): icon + title + body + actions.
/// Responsibilities: Layout only; all content and actions are passed in.
/// Dependencies: flutter.
/// Usage: StatusScreen(icon: ..., title: ..., body: ..., actions: [...])
library;

import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String body;
  final List<Widget> actions;
  final Widget? extra; // optional slot (e.g. resubmission form)

  const StatusScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.iconColor,
    this.actions = const [],
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 56, color: iconColor),
                const SizedBox(height: 16),
                Text(title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(body,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge),
                if (extra != null) ...[const SizedBox(height: 24), extra!],
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  ...actions.map((a) => Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 8),
                        child: SizedBox(width: double.infinity, child: a),
                      )),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
