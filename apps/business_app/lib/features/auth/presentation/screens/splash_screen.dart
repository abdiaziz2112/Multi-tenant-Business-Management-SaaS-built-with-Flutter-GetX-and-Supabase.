/// Purpose: Brand splash while StartupController resolves the auth state.
/// Responsibilities: Render only.
/// Dependencies: get, controller via binding.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/startup_controller.dart';

class SplashScreen extends GetView<StartupController> {
  const SplashScreen({super.key});

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
