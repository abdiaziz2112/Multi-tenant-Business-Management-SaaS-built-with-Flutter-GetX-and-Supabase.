/// Purpose: Every route NAME in one file — no magic strings scattered in code.
/// Responsibilities: Constants only.
/// Usage: Get.offAllNamed(AppRoutes.login)
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const otpChallenge = '/otp-challenge';
  static const pending = '/pending';
  static const rejected = '/rejected';
  static const suspended = '/suspended';
  static const setupRequired = '/setup-required';
  static const pinSetup = '/pin-setup';
  static const unlock = '/unlock';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const home = '/home';
}
