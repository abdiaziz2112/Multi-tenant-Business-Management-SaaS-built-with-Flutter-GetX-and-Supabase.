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

    Future.delayed(AppDurations.splashMin, () {
      // Replace the splash screen with the authentication entry point.
      Get.offAllNamed(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
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