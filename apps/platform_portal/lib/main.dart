/// Purpose: Entry point of the Platform Owner Portal (Flutter Web).
/// Responsibilities: Same startup order as the business app — same core
/// package, zero duplicated infrastructure code.
/// Dependencies: core, ui_kit, get_storage.
/// Usage: flutter run -d chrome --dart-define-from-file=env/dev.json
library;

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ui_kit/ui_kit.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await GetStorage.init();
    await SupabaseService.init();
    Get.put(ThemeService(), permanent: true);
    Get.put(SessionService(), permanent: true);
    runApp(const PortalApp());
  } catch (e, st) {
    debugPrint('BOOTSTRAP FAILURE: $e\n$st');
    runApp(const BootstrapErrorApp());
  }
}
