/// Purpose: Actions for the dashboard shell (navigation + sign-out live here,
/// never in the screen — the routing rule is absolute).
/// Dependencies: auth contracts, AuthRouter, routes.
/// Usage: bound to AppRoutes.home.
library;

import 'package:auth/auth.dart';
import 'package:get/get.dart';

import '../../../../app/navigation/auth_router.dart';
import '../../../../app/routes/app_routes.dart';

class HomeController extends GetxController {
  HomeController({AuthRepository? auth}) : _auth = auth ?? Get.find();
  final AuthRepository _auth;

  String get userEmail => _auth.currentUserEmail ?? '';

  void goDevices() => Get.toNamed<void>(AppRoutes.devices);

  Future<void> signOut() async {
    await _auth.signOut();
    await AuthRouter.resolveAndGo();
  }
}
