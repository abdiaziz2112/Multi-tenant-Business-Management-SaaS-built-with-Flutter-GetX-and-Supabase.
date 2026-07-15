/// Purpose: Toggle and REMEMBER light/dark mode.
/// Responsibilities: Apply ThemeMode via GetX; persist in GetStorage.
/// Dependencies: get, get_storage. Usage: ThemeService.to.toggle()
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  static ThemeService get to => Get.find();
  final _box = GetStorage();

  ThemeMode get mode =>
      (_box.read<String>('theme_mode') == 'dark') ? ThemeMode.dark : ThemeMode.light;

  bool get isDark => mode == ThemeMode.dark;

  Future<void> toggle() async {
    await _box.write('theme_mode', isDark ? 'light' : 'dark');
    Get.changeThemeMode(mode);
  }
}
