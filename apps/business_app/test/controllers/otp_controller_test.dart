/// Purpose: Prove the AUTH-007 challenge: verifying the login OTP TRUSTS the
/// device before continuing; signup mode never touches the device registry.
library;

import 'package:business_app/app/navigation/auth_router.dart';
import 'package:business_app/features/auth/presentation/controllers/otp_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_repositories.dart';

OtpController _make(
        OtpMode mode, FakeAuthRepository auth, FakeDeviceRepository devices) =>
    OtpController(
      mode: mode,
      auth: auth,
      devices: devices,
      getFingerprint: () async => 'fp-test',
      getDeviceName: () async => 'Test Device',
      platformLabel: 'test',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('deviceChallenge: verifyLoginOtp then trust_device with fingerprint',
      () async {
    final auth = FakeAuthRepository();
    final devices = FakeDeviceRepository();
    AuthRouter.testHook = () async {};

    final c = _make(OtpMode.deviceChallenge, auth, devices);
    await c.verify('654321');

    expect(auth.calls, contains('verifyLogin:654321'));
    expect(devices.calls, contains('trust:fp-test'));
    c.onClose();
    AuthRouter.testHook = null;
  });

  test(
      'signup mode: verifySignupOtp then trust_device (D42: AUTH-007 applies to every OTP)',
      () async {
    final auth = FakeAuthRepository();
    final devices = FakeDeviceRepository();
    AuthRouter.testHook = () async {};

    final c = _make(OtpMode.signup, auth, devices);
    await c.verify('111111');

    expect(auth.calls, contains('verifySignup:111111'));
    expect(devices.calls, contains('trust:fp-test'));
    c.onClose();
    AuthRouter.testHook = null;
  });
}
