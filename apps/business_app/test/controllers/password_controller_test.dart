/// Purpose: Prove FR-A18: after password change, revoke_other_devices runs
/// with the CURRENT device fingerprint — automatically.
library;

import 'package:business_app/app/navigation/auth_router.dart';
import 'package:business_app/features/auth/presentation/controllers/password_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('changePassword: verify -> update -> revokeOtherDevices order',
      () async {
    final auth = FakeAuthRepository();
    final devices = FakeDeviceRepository();
    AuthRouter.testHook = () async {};

    final c = PasswordController(
        auth: auth, devices: devices, getFingerprint: () async => 'fp-current');
    c.email.text = 'owner@x.so';
    c.code.text = '123456';
    c.newPassword.text = 'Aa1!aaaa';

    await c.changePasswordForTest();

    expect(auth.calls,
        containsAllInOrder(['verifyRecovery:123456', 'updatePassword']));
    expect(devices.calls, ['revokeOthers:fp-current']);
    c.onClose();
    AuthRouter.testHook = null;
  });
}
