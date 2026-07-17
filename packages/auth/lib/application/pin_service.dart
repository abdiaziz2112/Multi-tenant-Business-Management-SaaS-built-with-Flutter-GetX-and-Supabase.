/// Purpose: Local PIN unlock for trusted devices (AUTH-007 fallback when
/// biometrics are unavailable or declined).
/// Responsibilities: Store ONLY a salted SHA-256 hash in secure storage —
/// never the PIN itself; verify with constant-time comparison.
/// Security note: this gates the APP on an already-trusted device; it is not
/// an account credential and never leaves the device.
/// Dependencies: flutter_secure_storage, crypto.
/// Usage: await PinService.instance.setPin('1234'); .verify('1234')
library;

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  PinService._();
  static final instance = PinService._();

  static const _hashKey = 'hanti_pin_hash';
  static const _saltKey = 'hanti_pin_salt';
  final _storage = const FlutterSecureStorage();

  String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  Future<bool> get isSet async => (await _storage.read(key: _hashKey)) != null;

  Future<void> setPin(String pin) async {
    final rnd = Random.secure();
    final salt = List.generate(16, (_) => rnd.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    await _storage.write(key: _saltKey, value: salt);
    await _storage.write(key: _hashKey, value: _hash(pin, salt));
  }

  Future<bool> verify(String pin) async {
    final salt = await _storage.read(key: _saltKey);
    final stored = await _storage.read(key: _hashKey);
    if (salt == null || stored == null) return false;
    final candidate = _hash(pin, salt);
    // Constant-time compare: never leak match position through timing.
    if (candidate.length != stored.length) return false;
    var diff = 0;
    for (var i = 0; i < stored.length; i++) {
      diff |= candidate.codeUnitAt(i) ^ stored.codeUnitAt(i);
    }
    return diff == 0;
  }

  Future<void> clear() async {
    await _storage.delete(key: _hashKey);
    await _storage.delete(key: _saltKey);
  }
}
