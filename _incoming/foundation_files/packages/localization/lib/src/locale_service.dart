/// Purpose: Switch and REMEMBER the user's language across app restarts.
/// Responsibilities: Apply locale to GetX; persist choice in GetStorage.
/// Dependencies: get, get_storage.
/// Usage: LocaleService.to.change('ar');  LocaleService.to.current
import 'dart:ui';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocaleService extends GetxService {
  static LocaleService get to => Get.find();
  static const supported = ['en', 'so', 'ar'];

  final _box = GetStorage();

  /// Saved language, else English. RTL for Arabic is automatic:
  /// Flutter flips layouts by LOCALE — we never write left/right code.
  Locale get current => Locale(_box.read<String>('locale') ?? 'en');

  bool get isRtl => current.languageCode == 'ar';

  Future<void> change(String code) async {
    assert(supported.contains(code), 'Unsupported locale: $code');
    await _box.write('locale', code);
    Get.updateLocale(Locale(code)); // GetX rebuilds the whole app's texts.
  }
}
