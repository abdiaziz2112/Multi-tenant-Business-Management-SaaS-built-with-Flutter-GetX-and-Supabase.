/// Purpose: Widget-level proof that StatusScreen renders localized content.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('StatusScreen shows title, body and action', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: Builder(
          builder: (_) => StatusScreen(
            icon: Icons.hourglass_top_rounded,
            title: 'auth.pending.title'.tr,
            body: 'auth.pending.body'.tr,
            actions: [
              OutlinedButton(
                onPressed: () => tapped = true,
                child: Text('auth.pending.refresh'.tr),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Waiting for approval'), findsOneWidget);
    expect(find.textContaining('reviewed by Hanti ERP'), findsOneWidget);

    await tester.tap(find.text('Check status'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
