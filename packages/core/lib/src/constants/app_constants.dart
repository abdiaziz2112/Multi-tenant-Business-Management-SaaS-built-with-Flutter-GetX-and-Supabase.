/// Purpose: Cross-app constants with meaningful names (no magic numbers in code).
/// Responsibilities: Sizes, durations, storage keys used by more than one feature.
/// Dependencies: none.
/// Usage: AppDurations.snack, AppKeys.themeMode, ...
class AppDurations {
  AppDurations._();
  static const snack = Duration(seconds: 3);
  static const splashMin = Duration(milliseconds: 600);
}

class AppKeys {
  AppKeys._();
  // GetStorage keys — defined once so a typo can't silently create a new key.
  static const themeMode = 'theme_mode';
  static const locale = 'locale';
}
