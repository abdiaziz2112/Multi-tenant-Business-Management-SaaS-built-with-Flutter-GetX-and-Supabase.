/// Purpose: Splash-time decision: hand everything to the AuthRouter.
/// Responsibilities: Trigger resolveAndGo once the frame settles. No logic.
/// Dependencies: get, AuthRouter.
/// Usage: bound to the splash route.
library;

import 'package:core/core.dart';
import 'package:get/get.dart';

import '../../../../app/navigation/auth_router.dart';

class StartupController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    Future<void>.delayed(AppDurations.splashMin, AuthRouter.resolveAndGo);
  }
}
