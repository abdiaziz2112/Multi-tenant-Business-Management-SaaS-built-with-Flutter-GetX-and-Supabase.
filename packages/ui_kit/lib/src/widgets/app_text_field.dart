/// Purpose: THE text field — consistent decoration + translated validation.
/// Responsibilities: Wrap TextFormField; validators return KEYS, we .tr them here.
/// Dependencies: flutter, get. Usage: AppTextField(label: 'auth.email'.tr, validator: Validators.email)
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator; // returns a translation KEY or null
  final bool obscure;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      // Translate the key at DISPLAY time so messages switch language live.
      validator: validator == null ? null : (v) => validator!(v)?.tr,
    );
  }
}
