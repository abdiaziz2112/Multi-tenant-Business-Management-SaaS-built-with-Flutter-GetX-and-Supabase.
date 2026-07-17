/// Purpose: Truth table for the routing brain — every state has a proven home.
library;

import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

AuthBusiness _biz(BusinessStatus s, {bool setup = false, int resub = 0}) =>
    AuthBusiness(
      id: 'b1',
      name: 'Shop',
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
  }) =>
      AuthFlowResolver.resolve(
        hasSession: session,
        emailVerified: verified,
        business: business,
        deviceTrusted: trusted,
      );

  test('no session -> login', () {
    expect(r(session: false), AuthDestination.login);
  });

  test('unverified email -> verifyEmail', () {
    expect(r(verified: false), AuthDestination.verifyEmail);
  });

  test('verified but no business -> continueRegistration (killed mid-flow)', () {
    expect(r(business: null), AuthDestination.continueRegistration);
  });

  test('pending -> pending', () {
    expect(r(business: _biz(BusinessStatus.pending)), AuthDestination.pending);
  });

  test('rejected -> rejected, and canResubmit honors the 3-attempt limit', () {
    final b = _biz(BusinessStatus.rejected, resub: 2);
    expect(r(business: b), AuthDestination.rejected);
    expect(b.canResubmit, isTrue);
    expect(_biz(BusinessStatus.rejected, resub: 3).canResubmit, isFalse);
  });

  test('suspended -> suspended', () {
    expect(r(business: _biz(BusinessStatus.suspended)), AuthDestination.suspended);
  });

  test('UNKNOWN status fails closed -> suspended', () {
    expect(r(business: _biz(BusinessStatus.unknown)), AuthDestination.suspended);
  });

  test('approved without setup -> wizard', () {
    expect(r(business: _biz(BusinessStatus.approved)), AuthDestination.setupWizard);
  });

  test('approved+setup on untrusted device -> otpChallenge', () {
    expect(r(business: _biz(BusinessStatus.approved, setup: true)),
        AuthDestination.otpChallenge);
  });

  test('approved+setup on trusted device -> unlock', () {
    expect(
        r(business: _biz(BusinessStatus.approved, setup: true), trusted: true),
        AuthDestination.unlock);
  });
}
