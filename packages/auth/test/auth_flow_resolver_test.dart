/// Purpose: Truth table for the routing brain — every state has a proven home.
library;

import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

AuthBusiness _biz(BusinessStatus s, {bool setup = false, int resub = 0}) =>
    AuthBusiness(
      id: 'b1',
      name: 'Shop',
      ownerName: 'Cali',
      email: 'shop@x.so',
      country: 'Somalia',
      status: s,
      rejectionReason: s == BusinessStatus.rejected ? 'Incomplete' : null,
      resubmissionCount: resub,
      setupCompleted: setup,
    );

void main() {
  AuthDestination r({
    bool session = true,
    bool verified = true,
    AuthBusiness? business,
    bool trusted = false,
    bool pin = false,
    bool bio = false,
  }) =>
      AuthFlowResolver.resolve(
        hasSession: session,
        emailVerified: verified,
        business: business,
        deviceTrusted: trusted,
        pinConfigured: pin,
        biometricAvailable: bio,
      );

  test('no session -> login', () {
    expect(r(session: false), AuthDestination.login);
  });
  test('unverified email -> verifyEmail', () {
    expect(r(verified: false), AuthDestination.verifyEmail);
  });
  test('verified but no business -> continueRegistration', () {
    expect(r(business: null), AuthDestination.continueRegistration);
  });
  test('pending -> pending', () {
    expect(r(business: _biz(BusinessStatus.pending)), AuthDestination.pending);
  });
  test('rejected -> rejected; canResubmit honors 3-attempt limit', () {
    expect(r(business: _biz(BusinessStatus.rejected, resub: 2)),
        AuthDestination.rejected);
    expect(_biz(BusinessStatus.rejected, resub: 2).canResubmit, isTrue);
    expect(_biz(BusinessStatus.rejected, resub: 3).canResubmit, isFalse);
  });
  test('suspended -> suspended', () {
    expect(
        r(business: _biz(BusinessStatus.suspended)), AuthDestination.suspended);
  });
  test('UNKNOWN status fails closed -> suspended', () {
    expect(
        r(business: _biz(BusinessStatus.unknown)), AuthDestination.suspended);
  });
  test('approved without setup -> wizard', () {
    expect(r(business: _biz(BusinessStatus.approved)),
        AuthDestination.setupWizard);
  });
  test('approved+setup, untrusted device -> otpChallenge', () {
    expect(r(business: _biz(BusinessStatus.approved, setup: true)),
        AuthDestination.otpChallenge);
  });
  test('trusted device, NO pin, NO biometrics -> pinSetup', () {
    expect(
        r(business: _biz(BusinessStatus.approved, setup: true), trusted: true),
        AuthDestination.pinSetup);
  });
  test('trusted device with pin -> unlock', () {
    expect(
        r(
            business: _biz(BusinessStatus.approved, setup: true),
            trusted: true,
            pin: true),
        AuthDestination.unlock);
  });
  test('trusted device with biometrics only -> unlock', () {
    expect(
        r(
            business: _biz(BusinessStatus.approved, setup: true),
            trusted: true,
            bio: true),
        AuthDestination.unlock);
  });
}
