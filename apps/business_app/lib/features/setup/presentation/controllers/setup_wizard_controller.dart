/// Purpose: State machine for the 4-step Setup Wizard (approved businesses).
/// Responsibilities: Step navigation, per-step validation, local draft
/// persistence (resumable), final complete_setup() via the shared contract,
/// live app-language switch on finish. Zero widgets, zero provider types.
/// Dependencies: auth contracts, localization (LocaleService), draft store.
/// Usage: bound to AppRoutes.setupWizard.
library;

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:localization/localization.dart';

import '../../../../app/navigation/auth_router.dart';
import '../../data/setup_draft_store.dart';

class SetupWizardController extends GetxController {
  SetupWizardController({
    BusinessRepository? businesses,
    DraftStore? drafts,
    Future<void> Function(String code)? applyLocale,
  })  : _businesses = businesses ?? Get.find(),
        _drafts = drafts ?? SetupDraftStore(),
        _applyLocale = applyLocale ?? ((code) => LocaleService.to.change(code));

  final BusinessRepository _businesses;
  final DraftStore _drafts;
  final Future<void> Function(String) _applyLocale;

  static const stepCount = 4; // business -> preferences -> details -> branch
  final step = 0.obs;
  final busy = false.obs;
  final errorKey = RxnString();
  final stepKeys = List.generate(stepCount, (_) => GlobalKey<FormState>());

  // Step 1 — business essentials (the fields registration deferred, BR)
  final phone = TextEditingController();
  final businessType = RxnString();
  static const businessTypes = [
    'retail',
    'restaurant',
    'pharmacy',
    'electronics',
    'wholesale',
    'services',
    'other',
  ];

  // Step 2 — preferences
  final currency = 'USD'.obs;
  static const currencies = ['USD', 'SOS', 'KES', 'ETB'];
  final timezone = 'Africa/Mogadishu'.obs;
  static const timezones = [
    'Africa/Mogadishu',
    'Africa/Nairobi',
    'Africa/Addis_Ababa',
    'Africa/Djibouti',
  ];
  final language = 'so'.obs;

  // Step 3 — optional details
  final address = TextEditingController();
  final description = TextEditingController();

  // Step 4 — default branch
  final branchName = TextEditingController();
  final branchAddress = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _restoreDraft();
  }

  void _restoreDraft() {
    final d = _drafts.read();
    if (d.isEmpty) return;
    phone.text = (d['phone'] as String?) ?? '';
    businessType.value = d['business_type'] as String?;
    currency.value = (d['currency'] as String?) ?? currency.value;
    timezone.value = (d['timezone'] as String?) ?? timezone.value;
    language.value = (d['language'] as String?) ?? language.value;
    address.text = (d['address'] as String?) ?? '';
    description.text = (d['description'] as String?) ?? '';
    branchName.text = (d['branch_name'] as String?) ?? '';
    branchAddress.text = (d['branch_address'] as String?) ?? '';
    step.value = (d['step'] as int?)?.clamp(0, stepCount - 1) ?? 0;
  }

  void _saveDraft() => _drafts.write({
        'step': step.value,
        'phone': phone.text,
        'business_type': businessType.value,
        'currency': currency.value,
        'timezone': timezone.value,
        'language': language.value,
        'address': address.text,
        'description': description.text,
        'branch_name': branchName.text,
        'branch_address': branchAddress.text,
      });

  bool _validateCurrentStep() =>
      stepKeys[step.value].currentState?.validate() ?? true;

  void next() {
    if (!_validateCurrentStep()) return;
    if (step.value < stepCount - 1) {
      step.value++;
      _saveDraft();
    }
  }

  void back() {
    if (step.value > 0) {
      step.value--;
      _saveDraft();
    }
  }

  SetupData buildSetupData() => SetupData(
        phone: phone.text.trim(),
        businessType: businessType.value ?? '',
        currency: currency.value,
        timezone: timezone.value,
        language: language.value,
        address: address.text.trim().isEmpty ? null : address.text.trim(),
        description:
            description.text.trim().isEmpty ? null : description.text.trim(),
        branchName: branchName.text.trim(),
        branchAddress: branchAddress.text.trim().isEmpty
            ? null
            : branchAddress.text.trim(),
      );

  Future<void> finish() async {
    if (!_validateCurrentStep()) return;
    busy.value = true;
    errorKey.value = null;
    try {
      await _businesses.completeSetup(buildSetupData());
      _drafts.clear();
      await _applyLocale(language.value); // the chosen language, live
      await AuthRouter.resolveAndGo();
    } on Failure catch (f) {
      errorKey.value = f.messageKey;
    } finally {
      busy.value = false;
    }
  }

  @override
  void onClose() {
    for (final c in [phone, address, description, branchName, branchAddress]) {
      c.dispose();
    }
    super.onClose();
  }
}
