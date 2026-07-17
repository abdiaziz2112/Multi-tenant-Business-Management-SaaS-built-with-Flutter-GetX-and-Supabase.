/// Purpose: Give THIS installation a stable identity for AUTH-007.
/// Responsibilities: Generate a random fingerprint ONCE, keep it in secure
/// storage, and expose a friendly device name + platform label.
/// Design decision: the fingerprint is INSTALL-scoped (random, not hardware
/// IDs) — privacy-safe, and a reinstall becoming "a new device" that needs
/// OTP again is the CORRECT security posture, not a bug.
/// Dependencies: flutter_secure_storage, device_info_plus, crypto.
/// Usage: final fp = await DeviceIdentityService.instance.fingerprint();
library;

import 'dart:io' show Platform;
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceIdentityService {
  DeviceIdentityService._();
  static final instance = DeviceIdentityService._();

  static const _key = 'hanti_device_fingerprint';
  final _storage = const FlutterSecureStorage();
  String? _cached;

  Future<String> fingerprint() async {
    if (_cached != null) return _cached!;
    var fp = await _storage.read(key: _key);
    if (fp == null) {
      final rnd = Random.secure();
      fp = List.generate(32, (_) => rnd.nextInt(16).toRadixString(16)).join();
      await _storage.write(key: _key, value: fp);
    }
    _cached = fp;
    return fp;
  }

  String get platformLabel {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    return 'other';
  }

  Future<String> deviceName() async {
    try {
      final info = DeviceInfoPlugin();
      if (kIsWeb) {
        final w = await info.webBrowserInfo;
        return '${w.browserName.name} browser';
      }
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        return '${a.manufacturer} ${a.model}';
      }
      if (Platform.isIOS) {
        final i = await info.iosInfo;
        return i.name;
      }
    } catch (_) {
      // Name is cosmetic; identity never depends on it.
    }
    return 'Device';
  }
}
