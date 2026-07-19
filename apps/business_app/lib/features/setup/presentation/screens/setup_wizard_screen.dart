/// Purpose: The 4-step Setup Wizard UI. Renders controller state only.
/// Dependencies: get, ui_kit, core validators, SetupWizardController.
library;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_kit/ui_kit.dart';

import '../controllers/setup_wizard_controller.dart';

class SetupWizardScreen extends GetView<SetupWizardController> {
  const SetupWizardScreen({super.key});

  static const _stepTitleKeys = [
    'setup.step.business',
    'setup.step.preferences',
    'setup.step.details',
    'setup.step.branch',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('setup.title'.tr)),
      body: SafeArea(
        child: Obx(() {
          final s = controller.step.value;
          return Column(children: [
            LinearProgressIndicator(
                value: (s + 1) / SetupWizardController.stepCount),
            Padding(
              padding: const EdgeInsetsDirectional.all(16),
              child: Text(
                '${'setup.step_of'.trParams({
                      'current': '${s + 1}',
                      'total': '${SetupWizardController.stepCount}'
                    })} — ${_stepTitleKeys[s].tr}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Form(
                      key: controller.stepKeys[s],
                      child: _StepBody(step: s),
                    ),
                  ),
                ),
              ),
            ),
            Obx(() => controller.errorKey.value == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsetsDirectional.all(8),
                    child: Text(controller.errorKey.value!.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  )),
            Padding(
              padding: const EdgeInsetsDirectional.all(16),
              child: Row(children: [
                if (s > 0)
                  OutlinedButton(
                      onPressed: controller.back, child: Text('setup.back'.tr)),
                const Spacer(),
                if (s < SetupWizardController.stepCount - 1)
                  AppButton(label: 'setup.next'.tr, onPressed: controller.next)
                else
                  Obx(() => AppButton(
                        label: 'setup.finish'.tr,
                        busy: controller.busy.value,
                        onPressed: controller.finish,
                      )),
              ]),
            ),
          ]);
        }),
      ),
    );
  }
}

class _StepBody extends GetView<SetupWizardController> {
  const _StepBody({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return Column(children: [
          AppTextField(
            label: 'setup.phone'.tr,
            controller: controller.phone,
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
          ),
          const SizedBox(height: 12),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.businessType.value,
                decoration:
                    InputDecoration(labelText: 'setup.business_type'.tr),
                items: SetupWizardController.businessTypes
                    .map((t) => DropdownMenuItem(
                        value: t, child: Text('setup.type.$t'.tr)))
                    .toList(),
                onChanged: (v) => controller.businessType.value = v,
                validator: (v) => v == null ? 'validation.required'.tr : null,
              )),
        ]);
      case 1:
        return Column(children: [
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.currency.value,
                decoration: InputDecoration(labelText: 'setup.currency'.tr),
                items: SetupWizardController.currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => controller.currency.value = v!,
              )),
          const SizedBox(height: 12),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.timezone.value,
                decoration: InputDecoration(labelText: 'setup.timezone'.tr),
                items: SetupWizardController.timezones
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => controller.timezone.value = v!,
              )),
          const SizedBox(height: 12),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.language.value,
                decoration: InputDecoration(labelText: 'setup.language'.tr),
                items: const [
                  DropdownMenuItem(value: 'so', child: Text('Soomaali')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (v) => controller.language.value = v!,
              )),
        ]);
      case 2:
        return Column(children: [
          AppTextField(
              label: 'setup.address'.tr, controller: controller.address),
          const SizedBox(height: 12),
          AppTextField(
              label: 'setup.description'.tr,
              controller: controller.description),
        ]);
      default:
        return Column(children: [
          AppTextField(
            label: 'setup.branch_name'.tr,
            controller: controller.branchName,
            validator: Validators.requiredField,
          ),
          const SizedBox(height: 12),
          AppTextField(
              label: 'setup.branch_address'.tr,
              controller: controller.branchAddress),
        ]);
    }
  }
}
