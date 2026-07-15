/// Purpose: Input validation shared by both apps (single source of truth).
/// Responsibilities: Email + strong-password rules matching docs/SECURITY.md.
/// Dependencies: none.
/// Usage: Validators.password(value) -> null when valid, message key when not.
class Validators {
  Validators._();

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? v) =>
      (v == null || !_email.hasMatch(v.trim())) ? 'validation.email' : null;

  /// Policy (approved): >=8 chars, upper, lower, digit, special.
  /// The SAME policy is enforced server-side; this copy is instant feedback.
  static String? password(String? v) {
    final s = v ?? '';
    if (s.length < 8) return 'validation.password_length';
    if (!s.contains(RegExp(r'[A-Z]'))) return 'validation.password_upper';
    if (!s.contains(RegExp(r'[a-z]'))) return 'validation.password_lower';
    if (!s.contains(RegExp(r'[0-9]'))) return 'validation.password_digit';
    if (!s.contains(RegExp(r'[^A-Za-z0-9]'))) return 'validation.password_special';
    return null;
  }

  static String? requiredField(String? v) =>
      (v == null || v.trim().isEmpty) ? 'validation.required' : null;
}
