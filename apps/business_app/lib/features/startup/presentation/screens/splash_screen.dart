/// Purpose: First screen shown while the app starts.
/// Responsibilities: Display the brand briefly, then hand off to the
/// authentication flow.
/// Dependencies: Flutter, GetX, Core, AppRoutes.
library;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    debugPrint('=== SplashScreen.initState ===');
    debugPrint('Splash delay: ${AppDurations.splashMin}');

    Future.delayed(AppDurations.splashMin, () {
      debugPrint('=== Splash delay finished ===');

      try {
        debugPrint('Navigating to: ${AppRoutes.login}');
        Get.offAllNamed(AppRoutes.login);
        debugPrint('Navigation request sent.');
      } catch (e, st) {
        debugPrint('SPLASH NAVIGATION ERROR');
        debugPrint(e.toString());
        debugPrint(st.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('=== SplashScreen.build ===');

    return Scaffold(
      body: Center(
        child: Text(
          'app.name'.tr,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
