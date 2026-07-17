/// Purpose: App-lifetime dependency injection for authentication.
/// Responsibilities: Bind the shared-package CONTRACTS to their provider
/// implementations exactly once. Controllers depend on contracts only.
/// Dependencies: get, auth package.
/// Usage: initialBinding: AuthBinding() in GetMaterialApp.
library;

import 'package:auth/auth.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthRepository>(ProviderAuthRepository(), permanent: true);
    Get.put<BusinessRepository>(ProviderBusinessRepository(), permanent: true);
    Get.put<DeviceRepository>(ProviderDeviceRepository(), permanent: true);
  }
}
