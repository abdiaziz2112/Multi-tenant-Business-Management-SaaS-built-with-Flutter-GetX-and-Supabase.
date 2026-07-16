/// Purpose: Entry point of the Business App.
/// Responsibilities:
/// - Initialize Flutter bindings.
/// - Initialize local storage.
/// - Initialize Supabase.
/// - Register global GetX services.
/// - Launch the application.
///
/// Usage:
/// flutter run --dart-define-from-file=env/dev.json
library;

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage.
  await GetStorage.init();

  // Initialize Supabase (validates environment variables first).
  await SupabaseService.init();

  // Register global application services.
  Get.put(ThemeService(), permanent: true);
  Get.put(LocaleService(), permanent: true);
  Get.put(SessionService(), permanent: true);

  // Launch the application.
  runApp(const App());
}