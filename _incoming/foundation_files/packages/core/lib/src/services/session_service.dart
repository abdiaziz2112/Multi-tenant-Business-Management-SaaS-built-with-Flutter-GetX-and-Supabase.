/// Purpose: Know who is logged in, app-wide, reactively.
/// Responsibilities: Wrap Supabase auth state in GetX observables.
/// Dependencies: SupabaseService, GetX.
/// Usage: Get.put(SessionService()) in initial binding; SessionService.to.isLoggedIn
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/supabase_service.dart';

class SessionService extends GetxService {
  static SessionService get to => Get.find();

  /// .obs makes this reactive: any Obx() using it rebuilds on change.
  final Rxn<User> currentUser = Rxn<User>();

  bool get isLoggedIn => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = SupabaseService.client.auth.currentUser;
    // Supabase emits an event on login/logout/token refresh; we mirror it.
    SupabaseService.client.auth.onAuthStateChange.listen((event) {
      currentUser.value = event.session?.user;
    });
  }
}
