/// Purpose: Root widget of the portal. English-locale, desktop-plain by design
/// (docs/PROJECT_DECISIONS.md D18): it has exactly one user.
/// Responsibilities: GetMaterialApp configuration only.
/// Dependencies: get, ui_kit, localization.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class PortalApp extends StatelessWidget {
  const PortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hanti ERP Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeService.to.mode,
      // Translations registered so shared widgets using .tr render correctly;
      // locale is fixed to English per D18 (portal is English-only).
      translations: AppTranslations(),
      locale: const Locale('en'),
      fallbackLocale: const Locale('en'),
      initialRoute: AppRoutes.foundation,
      getPages: AppPages.pages,
    );
  }
}
