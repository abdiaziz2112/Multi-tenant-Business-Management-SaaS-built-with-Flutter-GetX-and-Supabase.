/// Purpose: Prove the AUTH-007 pairings: revoking THIS device or all devices
/// ends the session; revoking another device just refreshes the list.
library;

import 'package:auth/auth.dart';
import 'package:business_app/app/navigation/auth_router.dart';
import 'package:business_app/features/devices/presentation/controllers/device_management_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_repositories.dart';

TrustedDevice _dev(String id, String fp) => TrustedDevice(
      id: id,
      fingerprint: fp,
      name: 'D$id',
      platform: 'android',
      trustedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      revokedAt: null,
      lastSeenAt: DateTime.now(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  DeviceManagementController make(
          FakeAuthRepository auth, FakeDeviceRepository devices) =>
      DeviceManagementController(
          auth: auth, devices: devices, getFingerprint: () async => 'fp-me');

  test('revoking ANOTHER device keeps the session and reloads', () async {
    final auth = FakeAuthRepository();
    final devices = FakeDeviceRepository()
      ..devices = [_dev('1', 'fp-me'), _dev('2', 'fp-other')];
    AuthRouter.testHook = () async {};

    final c = make(auth, devices);
    await c.load();
    await c.revoke(devices.devices[1]);

    expect(devices.calls, contains('revokeOne:2'));
    expect(auth.calls, isNot(contains('signOut')));
    AuthRouter.testHook = null;
  });

  test('revoking THIS device signs out (AUTH-007 pairing)', () async {
    final auth = FakeAuthRepository();
    final devices = FakeDeviceRepository()..devices = [_dev('1', 'fp-me')];
    var resolved = 0;
    AuthRouter.testHook = () async => resolved++;

    final c = make(auth, devices);
    await c.load();
    await c.revoke(devices.devices.first);

    expect(devices.calls, contains('revokeOne:1'));
    expect(auth.calls, contains('signOut'));
    expect(resolved, 1);
    AuthRouter.testHook = null;
  });

  test('revoke all signs out everywhere including here', () async {
    final auth = FakeAuthRepository();
    final devices = FakeDeviceRepository()..devices = [_dev('1', 'fp-me')];
    AuthRouter.testHook = () async {};

    final c = make(auth, devices);
    await c.load();
    await c.revokeAll();

    expect(devices.calls, contains('revokeAll'));
    expect(auth.calls, contains('signOut'));
    AuthRouter.testHook = null;
  });
}
