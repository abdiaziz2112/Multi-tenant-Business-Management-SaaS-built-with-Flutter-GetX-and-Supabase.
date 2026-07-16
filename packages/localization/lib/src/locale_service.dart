/// Purpose:
/// Switch and remember the user's language across app restarts.
library;

import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocaleService extends GetxService {
  LocaleService();

  static LocaleService get to => Get.find<LocaleService>();

  static const List<String> supported = [
    'en',
    'ar',
  ];

  final GetStorage _box = GetStorage();

  /// Current locale.
  /// Defaults to English.
  Locale get current {
    final code = _box.read<String>('locale') ?? 'en';
    return Locale(code);
  }

  bool get isRtl => current.languageCode == 'ar';

  Future<void> change(String code) async {
    if (!supported.contains(code)) {
      throw ArgumentError('Unsupported locale: $code');
    }

    await _box.write('locale', code);
    Get.updateLocale(Locale(code));
  }
}