/// Purpose: State for Pending and Rejected screens.
/// Responsibilities: Poll own business status (10s) so approval flips the
/// screen without reinstall; prefill + submit resubmission (BR-11 aware).
/// Dependencies: get, auth contracts.
/// Usage: bound to pending/rejected routes.
library;

import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/navigation/auth_router.dart';

class BusinessStatusController extends GetxController {
  BusinessStatusController({
    AuthRepository? auth,
    BusinessRepository? businesses,
  })  : _auth = auth ?? Get.find(),
        _businesses = businesses ?? Get.find();
  final AuthRepository _auth;
  final BusinessRepository _businesses;

  final business = Rxn<AuthBusiness>();
  final busy = false.obs;
  final errorKey = RxnString();
  Timer? _poll;

  // Resubmission form (prefilled from the rejected business row)
  final formKey = GlobalKey<FormState>();
  final businessName = TextEditingController();
  final ownerName = TextEditingController();
  final businessEmail = TextEditingController();
  final country = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    refreshStatus();
    _poll = Timer.periodic(const Duration(seconds: 10), (_) => refreshStatus());
  }

  Future<void> refreshStatus() async {
    try {
      final b = await _businesses.fetchOwnBusiness();
      final statusChanged =
          business.value != null && b?.status != business.value?.status;
      business.value = b;
      if (b != null && businessName.text.isEmpty) {
        businessName.text = b.name;
        ownerName.text = b.ownerName;
        businessEmail.text = b.email;
        country.text = b.country;
      }
      if (statusChanged) await AuthRouter.resolveAndGo();
    } on Failure catch (f) {
      errorKey.value = f.messageKey;
    }
  }

  Future<void> resubmit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    busy.value = true;
    errorKey.value = null;
    try {
      await _businesses.resubmitBusiness(
        businessName: businessName.text.trim(),
        businessEmail: businessEmail.text.trim(),
        country: country.text.trim(),
        ownerName: ownerName.text.trim(),
      );
      await AuthRouter.resolveAndGo();
    } on Failure catch (f) {
      errorKey.value = f.messageKey;
    } finally {
      busy.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await AuthRouter.resolveAndGo();
  }

  @override
  void onClose() {
    _poll?.cancel();
    for (final c in [businessName, ownerName, businessEmail, country]) {
      c.dispose();
    }
    super.onClose();
  }
}
