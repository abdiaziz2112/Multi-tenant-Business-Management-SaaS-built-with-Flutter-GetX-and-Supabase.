/// Purpose: The ONE place in the whole monorepo that talks to Supabase directly.
/// Responsibilities: Initialize the client once; expose it to repositories.
/// Dependencies: supabase_flutter, EnvConfig.
/// Usage: await SupabaseService.init(); then SupabaseService.client in data layer.
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';

class SupabaseService {
  SupabaseService._();

  static Future<void> init() async {
    EnvConfig.validate();
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      // The anon key is SAFE to ship in the app: it grants nothing by itself.
      // Row Level Security in the database is the real lock (docs/SECURITY.md).
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }

  /// Repositories (packages/data) use this. UI and controllers never do —
  /// that separation is the Clean Architecture dependency rule.
  static SupabaseClient get client => Supabase.instance.client;
}
