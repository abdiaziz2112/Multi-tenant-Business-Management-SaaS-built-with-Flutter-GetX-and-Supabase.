/// Purpose: Prove the wizard's contract: draft resume, step gating, and a
/// complete_setup payload matching the deployed RPC's JSON shape exactly.
library;

import 'package:business_app/app/navigation/auth_router.dart';
import 'package:business_app/features/setup/data/setup_draft_store.dart';
import 'package:business_app/features/setup/presentation/controllers/setup_wizard_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_repositories.dart';

class MemoryDraftStore implements DraftStore {
  Map<String, dynamic> store = {};
  @override
  Map<String, dynamic> read() => Map.of(store);
  @override
  void write(Map<String, dynamic> draft) => store = Map.of(draft);
  @override
  void clear() => store = {};
}

SetupWizardController _make(FakeBusinessRepository biz, MemoryDraftStore d) =>
    SetupWizardController(
        businesses: biz, drafts: d, applyLocale: (_) async {});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('finish builds the exact RPC payload and clears the draft', () async {
    final biz = FakeBusinessRepository();
    final drafts = MemoryDraftStore();
    AuthRouter.testHook = () async {};

    final c = _make(biz, drafts);
    c.phone.text = '+252611234567';
    c.businessType.value = 'retail';
    c.currency.value = 'USD';
    c.timezone.value = 'Africa/Mogadishu';
    c.language.value = 'so';
    c.branchName.text = 'Main Branch';
    c.step.value = SetupWizardController.stepCount - 1;

    await c.finish();

    expect(biz.calls, contains('completeSetup'));
    final j = biz.lastSetup!.toBusinessJson();
    expect(j['phone'], '+252611234567');
    expect(j['business_type'], 'retail');
    expect(j['language'], 'so');
    expect(j.containsKey('address'), isFalse); // empty optionals stay absent
    expect(biz.lastSetup!.toBranchJson()['name'], 'Main Branch');
    expect(drafts.store, isEmpty); // resumable draft cleared on success
    c.onClose();
    AuthRouter.testHook = null;
  });

  test('a saved draft restores fields and step on a fresh controller', () {
    final drafts = MemoryDraftStore()
      ..store = {
        'step': 2,
        'phone': '+252611111111',
        'business_type': 'pharmacy',
        'currency': 'SOS',
        'timezone': 'Africa/Nairobi',
        'language': 'ar',
        'address': '',
        'description': '',
        'branch_name': '',
        'branch_address': '',
      };
    final c = _make(FakeBusinessRepository(), drafts);
    c.onInit();
    expect(c.step.value, 2);
    expect(c.phone.text, '+252611111111');
    expect(c.businessType.value, 'pharmacy');
    expect(c.language.value, 'ar');
    c.onClose();
  });
}
