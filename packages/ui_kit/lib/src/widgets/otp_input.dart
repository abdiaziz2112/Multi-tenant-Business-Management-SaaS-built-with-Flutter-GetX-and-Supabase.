/// Purpose: 6-digit OTP entry field (AUTH-007: codes, never links).
/// Responsibilities: Numeric, spaced, auto-submit on 6th digit.
/// Dependencies: flutter.
/// Usage: OtpInput(onCompleted: controller.verify)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatelessWidget {
  final void Function(String code) onCompleted;
  final TextEditingController? controller;

  const OtpInput({super.key, required this.onCompleted, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      style: Theme.of(context)
          .textTheme
          .headlineMedium
          ?.copyWith(letterSpacing: 12),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(counterText: ''),
      onChanged: (v) {
        if (v.length == 6) onCompleted(v);
      },
    );
  }
}
