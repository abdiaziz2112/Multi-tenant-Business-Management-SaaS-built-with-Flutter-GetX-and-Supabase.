/// Purpose: State + actions for the AUTH-007 device registry screen.
/// Responsibilities: Load registry, mark the current device, revoke one /
/// revoke all via the deployed RPCs. Revoking THIS device's trust signs the
/// session out (the AUTH-007 pairing) so the next login faces the OTP gate.
/// Dependencies: auth contracts.
/// Usage: bound to AppRoutes.devices.
library;

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:get/get.dart';

import '../../../../app/navigation/auth_router.dart';

class DeviceManagementController extends GetxController {
  DeviceManagementController({
    AuthRepository? auth,
    DeviceRepository? devices,
    Future<String> Function()? getFingerprint,
  })  : _auth = auth ?? Get.find(),
        _devices = devices ?? Get.find(),
        _getFingerprint =
            getFingerprint ?? DeviceIdentityService.instance.fingerprint;

  final AuthRepository _auth;
  final DeviceRepository _devices;
  final Future<String> Function() _getFingerprint;

  final items = <TrustedDevice>[].obs;
  final currentFingerprint = ''.obs;
  final loading = true.obs;
  final busy = false.obs;
  final errorKey = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    errorKey.value = null;
    try {
      currentFingerprint.value = await _getFingerprint();
      items.assignAll(await _devices.listDevices());
    } on Failure catch (f) {
      errorKey.value = f.messageKey;
    } finally {
      loading.value = false;
    }
  }

  bool isCurrent(TrustedDevice d) => d.fingerprint == currentFingerprint.value;

  Future<void> revoke(TrustedDevice d) async {
    busy.value = true;
    errorKey.value = null;
    try {
      await _devices.revokeDevice(d.id);
      if (isCurrent(d)) {
        // AUTH-007 pairing: killing this device's trust ends this session.
        await _auth.signOut();
        await AuthRouter.resolveAndGo();
        return;
      }
      await load();
    } on Failure catch (f) {
      errorKey.value = f.messageKey;
    } finally {
      busy.value = false;
    }
  }

  Future<void> revokeAll() async {
    busy.value = true;
    errorKey.value = null;
    try {
      await _devices.revokeAllDevices();
      // "Logout everywhere" includes HERE, by definition.
      await _auth.signOut();
      await AuthRouter.resolveAndGo();
    } on Failure catch (f) {
      errorKey.value = f.messageKey;
      busy.value = false;
    }
  }
}
