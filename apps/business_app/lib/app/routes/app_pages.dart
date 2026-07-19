/// Purpose: Map route names -> screens -> bindings (dependency injection).
/// Responsibilities: Every screen's controller is created here, never in UI.
/// Dependencies: get, feature screens/controllers.
library;

import 'package:get/get.dart';

import '../../features/auth/presentation/controllers/business_status_controller.dart';
import '../../features/auth/presentation/controllers/login_controller.dart';
import '../../features/auth/presentation/controllers/otp_controller.dart';
import '../../features/auth/presentation/controllers/password_controller.dart';
import '../../features/auth/presentation/controllers/register_controller.dart';
import '../../features/auth/presentation/controllers/startup_controller.dart';
import '../../features/auth/presentation/controllers/unlock_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/password_screens.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/status_screens.dart';
import '../../features/auth/presentation/screens/unlock_screens.dart';
import '../../features/devices/presentation/controllers/device_management_controller.dart';
import '../../features/devices/presentation/screens/device_management_screen.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/setup/presentation/controllers/setup_wizard_controller.dart';
import '../../features/setup/presentation/screens/setup_wizard_screen.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),

      // IMPORTANT:
      // SplashScreen never calls Get.find<StartupController>(), so using
      // Get.lazyPut() would leave the controller unconstructed forever.
      // Create it eagerly so onReady() always executes.
      binding: BindingsBuilder(() {
        Get.put<StartupController>(StartupController());
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(LoginController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(RegisterController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const OtpScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => OtpController(mode: OtpMode.signup),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.otpChallenge,
      page: () => const OtpScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => OtpController(mode: OtpMode.deviceChallenge),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.pending,
      page: () => const PendingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(BusinessStatusController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.rejected,
      page: () => const RejectedScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(BusinessStatusController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.suspended,
      page: () => const SuspendedScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(BusinessStatusController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.setupWizard,
      page: () => const SetupWizardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(SetupWizardController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          PasswordController.new,
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PasswordController>()) {
          Get.lazyPut(
            PasswordController.new,
            fenix: true,
          );
        }
      }),
    ),
    GetPage(
      name: AppRoutes.pinSetup,
      page: () => const PinSetupScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(UnlockController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.unlock,
      page: () => const UnlockScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(UnlockController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.devices,
      page: () => const DeviceManagementScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(DeviceManagementController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(HomeController.new);
      }),
    ),
  ];
}
