/// Purpose: The color vocabulary of Ganacsi. Nothing hardcodes a hex outside this file.
/// Responsibilities: Brand seed + semantic colors (success/warning/danger/credit).
/// Dependencies: flutter. Usage: AppColors.seed, AppColors.success ...
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Deep teal: trustworthy for a money app, distinct from the default
  /// Material purple, and prints well on thermal receipts in dark grey.
  /// Businesses can override with their own brand_color later (Settings).
  static const seed = Color(0xFF00695C);

  // Semantic colors — named by MEANING so a "success" stays green everywhere.
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF9A825);
  static const danger = Color(0xFFC62828);

  /// Credit/deyn amounts get their own color so outstanding balances are
  /// recognizable at a glance in POS, CRM and reports.
  static const credit = Color(0xFF6A1B9A);
}
