/// Purpose: Read environment values injected at build time via --dart-define.
/// Responsibilities: Expose Supabase URL/key and environment name; fail fast if missing.
/// Dependencies: none (pure Dart).
/// Usage: EnvConfig.supabaseUrl  (run with --dart-define-from-file=env/dev.json)
class EnvConfig {
  EnvConfig._(); // no instances — this is a namespace, not an object.

  /// String.fromEnvironment reads values baked in at COMPILE time.
  /// Why not a .env file at runtime? Compile-time values cannot be forgotten
  /// in release builds and need no file-loading code on any platform.
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const envName = String.fromEnvironment('ENV', defaultValue: 'dev');

  static bool get isProd => envName == 'prod';

  /// Called once at startup: crash loudly NOW rather than mysteriously later.
  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL / SUPABASE_ANON_KEY. '
        'Run with: flutter run --dart-define-from-file=env/dev.json',
      );
    }
  }
}
