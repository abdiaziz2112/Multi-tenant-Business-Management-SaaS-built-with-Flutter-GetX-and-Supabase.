/// Purpose: Contract for identity operations (sign up/in/out, OTP, password).
/// Responsibilities: Pure interface — no provider types leak through it.
/// Dependencies: none (pure Dart). Implementations live in data/.
/// Usage: injected into controllers; swap with fakes in tests.
abstract interface class AuthRepository {
  Future<String> signUp({required String email, required String password});
  Future<void> signIn({required String email, required String password});
  Future<void> sendEmailOtp(String email);
  Future<void> verifySignupOtp({required String email, required String code});
  Future<void> verifyLoginOtp({required String email, required String code});
  Future<void> sendPasswordResetOtp(String email);
  Future<void> verifyRecoveryOtp({required String email, required String code});
  Future<void> updatePassword(String newPassword);
  Future<void> signOut();
  String? get currentUserId;
  String? get currentUserEmail;
  bool get isEmailVerified;
}
