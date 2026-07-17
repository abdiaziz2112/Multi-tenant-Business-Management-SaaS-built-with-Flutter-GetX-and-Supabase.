/* /// Purpose: Map route names -> screens -> bindings (dependency injection).
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
import '../../features/home/presentation/screens/home_screen.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(StartupController.new)),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(LoginController.new)),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(RegisterController.new)),
    ),
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const OtpScreen(),
      binding: BindingsBuilder(
          () => Get.lazyPut(() => OtpController(mode: OtpMode.signup))),
    ),
    GetPage(
      name: AppRoutes.otpChallenge,
      page: () => const OtpScreen(),
      binding: BindingsBuilder(() =>
          Get.lazyPut(() => OtpController(mode: OtpMode.deviceChallenge))),
    ),
    GetPage(
      name: AppRoutes.pending,
      page: () => const PendingScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(BusinessStatusController.new)),
    ),
    GetPage(
      name: AppRoutes.rejected,
      page: () => const RejectedScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(BusinessStatusController.new)),
    ),
    GetPage(
      name: AppRoutes.suspended,
      page: () => const SuspendedScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(BusinessStatusController.new)),
    ),
    GetPage(
      name: AppRoutes.setupRequired,
      page: () => const SetupRequiredScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(BusinessStatusController.new)),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding:
          BindingsBuilder(() => Get.lazyPut(PasswordController.new, fenix: true)),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      // Reuse the SAME PasswordController from Forgot: the typed email must
      // survive the route change. Only create one if arriving here directly.
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PasswordController>()) {
          Get.lazyPut(PasswordController.new, fenix: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.pinSetup,
      page: () => const PinSetupScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(UnlockController.new)),
    ),
    GetPage(
      name: AppRoutes.unlock,
      page: () => const UnlockScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(UnlockController.new)),
    ),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
  ];
}
 */


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
import '../../features/home/presentation/screens/home_screen.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),

      // IMPORTANT:
      // The splash screen never calls Get.find<StartupController>(),
      // so using Get.lazyPut() means the controller is never created.
      // Register it eagerly so onReady() always runs.
      binding: BindingsBuilder(() {
        Get.put(StartupController());
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
      name: AppRoutes.setupRequired,
      page: () => const SetupRequiredScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(BusinessStatusController.new);
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
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
  ];
}