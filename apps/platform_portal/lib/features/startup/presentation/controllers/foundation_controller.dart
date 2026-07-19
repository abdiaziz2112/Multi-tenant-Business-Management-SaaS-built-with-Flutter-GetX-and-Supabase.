/// Purpose: State for the portal's foundation check.
/// Responsibilities: Read subscription plans from Supabase; expose reactive
/// status + plan names (a slightly richer check than the mobile app's ping).
/// Dependencies: get, core.
library;

import 'package:core/core.dart';
import 'package:get/get.dart';

enum PingStatus { loading, ok, fail }

class FoundationController extends GetxController {
  final ping = PingStatus.loading.obs;
  final planNames = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    check();
  }

  Future<void> check() async {
    ping.value = PingStatus.loading;
    try {
      final rows = await SupabaseService.client
          .from('subscription_plans')
          .select('name')
          .order('price_monthly');
      planNames.assignAll((rows as List).map((r) => r['name'] as String));
      ping.value = PingStatus.ok;
    } catch (_) {
      ping.value = PingStatus.fail;
    }
  }
}
