/// Purpose: AuthRepository implementation over the auth provider.
/// Responsibilities: The ONLY file that calls provider auth APIs. OTP-only
/// per AUTH-007 — no links anywhere. All errors pass the failure mapper.
/// Dependencies: core (SupabaseService), supabase_flutter, mapper, contract.
/// Usage: Get.put<AuthRepository>(ProviderAuthRepository()) in app bindings.
library;

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/auth_repository.dart';
import '../auth_failure_mapper.dart';

class ProviderAuthRepository implements AuthRepository {
  GoTrueClient get _auth => SupabaseService.client.auth;

  @override
  Future<String> signUp({required String email, required String password}) async {
    try {
      final res = await _auth.signUp(email: email, password: password);
      return res.user!.id;
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<void> sendEmailOtp(String email) async {
    try {
      // shouldCreateUser:false — this is a login/challenge OTP, never a signup.
      await _auth.signInWithOtp(email: email, shouldCreateUser: false);
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<void> verifySignupOtp({required String email, required String code}) =>
      _verify(email: email, code: code, type: OtpType.signup);

  @override
  Future<void> resendSignupOtp(String email) async {
    try {
      await _auth.resend(type: OtpType.signup, email: email);
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<void> verifyLoginOtp({required String email, required String code}) =>
      _verify(email: email, code: code, type: OtpType.email);

  @override
  Future<void> sendPasswordResetOtp(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<void> verifyRecoveryOtp({required String email, required String code}) =>
      _verify(email: email, code: code, type: OtpType.recovery);

  Future<void> _verify({
    required String email,
    required String code,
    required OtpType type,
  }) async {
    try {
      await _auth.verifyOTP(email: email, token: code, type: type);
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  String? get currentUserId => _auth.currentUser?.id;

  @override
  String? get currentUserEmail => _auth.currentUser?.email;

  @override
  bool get isEmailVerified => _auth.currentUser?.emailConfirmedAt != null;
}
