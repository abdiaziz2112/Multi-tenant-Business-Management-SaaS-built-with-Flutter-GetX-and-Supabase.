/// Purpose: Dashboard shell after full authentication (real modules: later
/// milestones). Proves the complete auth pipeline end-to-end.
/// Dependencies: get, auth contracts.
library;

import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/navigation/auth_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthRepository>();
    return Scaffold(
      appBar: AppBar(title: Text('home.title'.tr), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'auth.signout'.tr,
          onPressed: () async {
            await auth.signOut();
            await AuthRouter.resolveAndGo();
          },
        ),
      ]),
      body: Center(
        child: Text('home.welcome'
            .trParams({'name': auth.currentUserEmail ?? ''})),
      ),
    );
  }
}
