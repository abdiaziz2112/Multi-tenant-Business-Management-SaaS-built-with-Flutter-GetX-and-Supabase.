/// Purpose: Entry point of the Business App.
/// Responsibilities: Initialize storage + Supabase + global services, in order,
/// BEFORE the first frame; then hand off to App.
/// Dependencies: core, localization, ui_kit, get_storage.
/// Usage: flutter run --dart-define-from-file=env/dev.json
library;

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';

import 'app/app.dart';
import 'app/bindings/auth_binding.dart';

Future<void> main() async {
  // Required whenever main() awaits before runApp(): plugins need the engine.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await GetStorage.init(); // 1. local key-value store (theme, locale)
    await SupabaseService.init(); // 2. backend client (validates env first)

    // 3. App-lifetime services (permanent: true = never disposed).
    Get.put(ThemeService(), permanent: true);
    Get.put(LocaleService(), permanent: true);
    Get.put(SessionService(), permanent: true);
    AuthBinding().dependencies();

    runApp(const App());
  } catch (e, st) {
    // Developer gets the truth in the console; the user gets a friendly,
    // brand-consistent screen with no technical details (UX rule, CR-5).
    debugPrint('BOOTSTRAP FAILURE: $e\n$st');
    runApp(const BootstrapErrorApp());
  }
}
