/// Purpose: Every route NAME in one file — no magic strings scattered in code.
/// Responsibilities: Constants only.
/// Usage: Get.offAllNamed(AppRoutes.foundation)
abstract class AppRoutes {
  static const splash = '/';
  static const foundation = '/foundation'; // temporary home; replaced by auth in M1
}
