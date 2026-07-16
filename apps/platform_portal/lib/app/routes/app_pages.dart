/// Purpose: Route table of the portal (names -> screens -> bindings).
library;

import 'package:get/get.dart';

import '../../features/startup/presentation/controllers/foundation_controller.dart';
import '../../features/startup/presentation/screens/foundation_screen.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.foundation,
      page: () => const FoundationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => FoundationController());
      }),
    ),
  ];
}
