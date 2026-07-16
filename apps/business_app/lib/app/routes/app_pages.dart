/// Purpose: Map route names -> screens -> bindings (dependency injection).
/// Responsibilities: A Binding creates a screen's controller when the screen
/// opens and disposes it when it closes — no leaks, no globals.
/// Dependencies: get, feature screens/controllers.
library;

import 'package:get/get.dart';

import '../../features/startup/presentation/controllers/foundation_controller.dart';
import '../../features/startup/presentation/screens/foundation_screen.dart';
import '../../features/startup/presentation/screens/splash_screen.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.foundation,
      page: () => const FoundationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => FoundationController());
      }),
    ),
  ];
}
