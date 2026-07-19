/// Purpose: In-memory fakes of the auth contracts for controller tests.
/// Responsibilities: Record calls; return scripted results; no IO.
library;

import 'package:auth/auth.dart';

class FakeAuthRepository implements AuthRepository {
  final calls = <String>[];
  bool verified = true;
  String? userId = 'u1';
  String? email = 'owner@x.so';
  Object? throwOnSignIn;

  @override
  Future<String> signUp(
      {required String email, required String password}) async {
    calls.add('signUp:$email');
    return 'u1';
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    calls.add('signIn:$email');
    if (throwOnSignIn != null) throw throwOnSignIn!;
  }

  @override
  Future<void> sendEmailOtp(String email) async => calls.add('sendOtp:$email');
  @override
  Future<void> resendSignupOtp(String email) async =>
      calls.add('resendSignup:$email');
  @override
  Future<void> verifySignupOtp(
          {required String email, required String code}) async =>
      calls.add('verifySignup:$code');
  @override
  Future<void> verifyLoginOtp(
          {required String email, required String code}) async =>
      calls.add('verifyLogin:$code');
  @override
  Future<void> sendPasswordResetOtp(String email) async =>
      calls.add('sendReset:$email');
  @override
  Future<void> verifyRecoveryOtp(
          {required String email, required String code}) async =>
      calls.add('verifyRecovery:$code');
  @override
  Future<void> updatePassword(String newPassword) async =>
      calls.add('updatePassword');
  @override
  Future<void> signOut() async => calls.add('signOut');
  @override
  String? get currentUserId => userId;
  @override
  String? get currentUserEmail => email;
  @override
  bool get isEmailVerified => verified;
}

class FakeBusinessRepository implements BusinessRepository {
  final calls = <String>[];
  AuthBusiness? business;
  SetupData? lastSetup;

  @override
  Future<String> registerBusiness({
    required String businessName,
    required String businessEmail,
    required String country,
    required String ownerName,
  }) async {
    calls.add('register:$businessName');
    return 'b1';
  }

  @override
  Future<void> resubmitBusiness({
    required String businessName,
    required String businessEmail,
    required String country,
    required String ownerName,
  }) async =>
      calls.add('resubmit:$businessName');

  @override
  Future<AuthBusiness?> fetchOwnBusiness() async {
    calls.add('fetchOwn');
    return business;
  }

  @override
  Future<void> completeSetup(SetupData data) async {
    calls.add('completeSetup');
    lastSetup = data;
  }
}

class FakeDeviceRepository implements DeviceRepository {
  final calls = <String>[];
  bool trusted = false;
  List<TrustedDevice> devices = [];

  @override
  Future<bool> isDeviceTrusted(String fingerprint) async {
    calls.add('isTrusted:$fingerprint');
    return trusted;
  }

  @override
  Future<String> trustDevice({
    required String fingerprint,
    required String name,
    required String platform,
  }) async {
    calls.add('trust:$fingerprint');
    trusted = true;
    return 'd1';
  }

  @override
  Future<void> touchDevice(String fingerprint) async =>
      calls.add('touch:$fingerprint');
  @override
  Future<List<TrustedDevice>> listDevices() async {
    calls.add('list');
    return devices;
  }

  @override
  Future<void> revokeDevice(String deviceId) async =>
      calls.add('revokeOne:$deviceId');
  @override
  Future<int> revokeAllDevices() async {
    calls.add('revokeAll');
    return devices.length;
  }

  @override
  Future<int> revokeOtherDevices(String currentFingerprint) async {
    calls.add('revokeOthers:$currentFingerprint');
    return 1;
  }
}
