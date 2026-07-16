/// Purpose: State for the foundation-check screen (proves the wiring works).
/// Responsibilities: Ping Supabase; expose reactive status. Pattern to learn:
/// ALL state lives in the controller; the screen only renders it.
/// Dependencies: get, core.
library;

import 'package:core/core.dart';
import 'package:get/get.dart';

enum PingStatus { loading, ok, fail }

class FoundationController extends GetxController {
  final ping = PingStatus.loading.obs; // .obs = observable; Obx() reacts to it

  @override
  void onInit() {
    super.onInit();
    _checkSupabase();
  }

  Future<void> _checkSupabase() async {
    ping.value = PingStatus.loading;
    try {
      // Smallest legal query: public read of subscription_plans (RLS-allowed).
      await SupabaseService.client
          .from('subscription_plans')
          .select('name')
          .limit(1);
      ping.value = PingStatus.ok;
    } catch (_) {
      ping.value = PingStatus.fail;
    }
  }

  void retry() => _checkSupabase();
}
