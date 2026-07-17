/// Purpose: Prove registration follows the deployed contract order:
/// signUp (owner identity) BEFORE register_business, honoring the email toggle,
/// then continuation flows through the single AuthRouter decision point.
library;

import 'package:business_app/app/navigation/auth_router.dart';
import 'package:business_app/features/auth/presentation/controllers/register_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('signUp precedes register_business; toggle picks business email',
      () async {
    final auth = FakeAuthRepository();
    final biz = FakeBusinessRepository();
    var resolved = 0;
    AuthRouter.testHook = () async => resolved++;

    final c = RegisterController(auth: auth, businesses: biz);
    c.businessName.text = 'Hanti Shop';
    c.ownerName.text = 'Cali';
    c.businessEmail.text = 'shop@x.so';
    c.country.text = 'Somalia';
    c.password.text = 'Aa1!aaaa';
    c.sameEmail.value = true;

    await c.submitForTest();

    expect(auth.calls, ['signUp:shop@x.so']);
    expect(biz.calls, ['register:Hanti Shop']);
    expect(resolved, 1);
    c.onClose();
    AuthRouter.testHook = null;
  });

  test('toggle off uses the separate owner email for sign-in', () async {
    final auth = FakeAuthRepository();
    final biz = FakeBusinessRepository();
    AuthRouter.testHook = () async {};

    final c = RegisterController(auth: auth, businesses: biz);
    c.businessName.text = 'Hanti Shop';
    c.ownerName.text = 'Cali';
    c.businessEmail.text = 'shop@x.so';
    c.ownerEmail.text = 'cali@x.so';
    c.country.text = 'Somalia';
    c.password.text = 'Aa1!aaaa';
    c.sameEmail.value = false;

    await c.submitForTest();

    expect(auth.calls, ['signUp:cali@x.so']);
    c.onClose();
    AuthRouter.testHook = null;
  });
}
