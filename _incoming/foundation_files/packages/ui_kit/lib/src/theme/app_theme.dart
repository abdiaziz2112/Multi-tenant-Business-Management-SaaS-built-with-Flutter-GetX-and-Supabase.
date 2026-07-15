/// Purpose: Build the light (default) and dark (optional) themes from one seed.
/// Responsibilities: Material 3 ColorScheme + consistent component styling.
/// Dependencies: flutter, AppColors. Usage: theme: AppTheme.light, darkTheme: AppTheme.dark
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// One private builder so light and dark can never drift apart in style.
  static ThemeData _build(Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Slightly generous tap targets: cashiers work fast, often one-handed.
      visualDensity: VisualDensity.comfortable,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        // Logical (start/end) padding, never left/right: flips correctly in RTL.
        contentPadding: EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);
}
