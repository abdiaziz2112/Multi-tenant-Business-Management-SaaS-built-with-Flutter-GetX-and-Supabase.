/// Purpose: One vocabulary for "something went wrong", shared by all layers.
/// Responsibilities: Convert raw exceptions into user-presentable Failures.
/// Dependencies: supabase_flutter (to recognize its exception types).
/// Usage: try {...} on Exception catch (e) { throw Failure.from(e); }
import 'package:supabase_flutter/supabase_flutter.dart';

class Failure implements Exception {
  final String messageKey; // translation key, safe to show after .tr
  final Object? cause; // original exception, for logs only — never shown
  const Failure(this.messageKey, [this.cause]);

  /// Maps low-level exceptions to translation keys. Grows with features.
  factory Failure.from(Object e) {
    if (e is AuthException) return Failure('errors.auth', e);
    if (e is PostgrestException) {
      // RLS denials arrive as Postgrest errors; never leak SQL to users.
      return Failure('errors.permission_or_data', e);
    }
    return Failure('errors.unexpected', e);
  }

  @override
  String toString() => 'Failure($messageKey, cause: $cause)';
}
