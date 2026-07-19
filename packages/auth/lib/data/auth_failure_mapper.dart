/// Purpose: Convert raw provider/database errors into localized Failure keys.
/// Responsibilities: The CR-5 wall — no provider names, no SQL, no stack
/// traces escape this file. Developer detail is preserved in Failure.cause.
/// Dependencies: core (Failure), supabase_flutter (recognizing error types).
/// Usage: throw AuthFailureMapper.map(e); inside every data-layer catch.
library;

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthFailureMapper {
  AuthFailureMapper._();

  static Failure map(Object e) {
    if (e is AuthException) {
      final m = e.message.toLowerCase();
      if (m.contains('invalid login credentials')) {
        return Failure('auth.err.invalid_credentials', e);
      }
      if (m.contains('already registered')) {
        return Failure('auth.err.email_in_use', e);
      }
      if (m.contains('otp') &&
          (m.contains('expired') || m.contains('invalid'))) {
        return Failure('auth.err.otp_invalid', e);
      }
      if (m.contains('rate limit') || m.contains('too many')) {
        return Failure('auth.err.too_many_attempts', e);
      }
      return Failure('auth.err.generic', e);
    }
    if (e is PostgrestException) {
      final m = e.message;
      // RPC raise-exception messages from 00012 -> per-case friendly keys.
      if (m.contains('already linked'))
        return Failure('auth.err.already_registered', e);
      if (m.contains('Resubmission limit'))
        return Failure('auth.err.resubmit_limit', e);
      if (m.contains('Only rejected'))
        return Failure('auth.err.not_rejected', e);
      if (m.contains('Phone required')) return Failure('setup.err.phone', e);
      if (m.contains('Business type required'))
        return Failure('setup.err.type', e);
      if (m.contains('Currency required'))
        return Failure('setup.err.currency', e);
      if (m.contains('Timezone required'))
        return Failure('setup.err.timezone', e);
      if (m.contains('Invalid language'))
        return Failure('setup.err.language', e);
      if (m.contains('Branch name required'))
        return Failure('setup.err.branch', e);
      if (m.contains('not approved'))
        return Failure('auth.err.not_approved', e);
      return Failure('errors.permission_or_data', e);
    }
    return Failure('errors.unexpected', e);
  }
}
