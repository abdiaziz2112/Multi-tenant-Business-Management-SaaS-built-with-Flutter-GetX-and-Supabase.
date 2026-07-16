/// Purpose: First screen; shows the brand while startup decisions happen.
/// Responsibilities: Wait a beat, then route onward. In M1 this becomes:
/// logged-in? -> dashboard : login. For now it goes to the foundation check.
/// Dependencies: get, core, app routes.
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
      // offAllNamed: replace the stack — you can't "back" into a splash.
      Get.offAllNamed(AppRoutes.foundation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('app.name'.tr,
            style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
