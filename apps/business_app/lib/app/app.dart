/// Purpose: The root widget — wires GetX routing, themes, and 3 languages together.
/// Responsibilities: GetMaterialApp configuration ONLY (no business logic).
/// Dependencies: get, ui_kit, localization, flutter_localizations.
/// Usage: runApp(const App()) from main.dart.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hanti ERP',
      debugShowCheckedModeBanner: false,

      // THEMES — light default, dark optional; user choice persisted.
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeService.to.mode,

      // LANGUAGES — 'key'.tr resolves against these maps; the Arabic locale
      // flips the whole layout to RTL automatically (Directional widgets).
      translations: AppTranslations(),
      locale: LocaleService.to.current,
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('so'), Locale('ar')],
      localizationsDelegates: const [
        // Somali first: custom delegates must come BEFORE the Global ones,
        // because Flutter uses the first delegate that supports the locale.
        SoMaterialLocalizations.delegate,
        SoCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ROUTING — every route declared in one place (app_pages.dart).
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
