/// Purpose:
/// Read environment variables passed using
/// --dart-define-from-file.
///
/// Responsibilities:
/// - Expose Supabase URL
/// - Expose Publishable Key
/// - Validate required values
///
/// Usage:
/// flutter run --dart-define-from-file=env/dev.json

class EnvConfig {
  EnvConfig._();

  static const String envName =
      String.fromEnvironment('ENV', defaultValue: 'dev');

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');

  static const String supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isProduction => envName == 'prod';

  static void validate() {
    if (supabaseUrl.isEmpty ||
        supabasePublishableKey.isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY.\n'
        'Run using:\n'
        'flutter run --dart-define-from-file=env/dev.json',
      );
    }
  }
}