/// Purpose: Dashboard shell after full authentication (real modules: later
/// milestones). Proves the complete auth pipeline end-to-end.
/// Dependencies: get, HomeController.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('home.title'.tr), actions: [
        IconButton(
          icon: const Icon(Icons.devices_outlined),
          tooltip: 'devices.title'.tr,
          onPressed: controller.goDevices,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'auth.signout'.tr,
          onPressed: controller.signOut,
        ),
      ]),
      body: Center(
        child: Text('home.welcome'.trParams({'name': controller.userEmail})),
      ),
    );
  }
}
