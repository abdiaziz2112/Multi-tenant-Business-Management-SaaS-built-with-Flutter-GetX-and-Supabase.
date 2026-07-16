/// Purpose: The root widget of the Business App.
/// Responsibilities:
/// - Configure GetX routing.
/// - Configure themes.
/// - Configure localization.
/// - Launch the application's navigation tree.
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
      title: 'Ganacsi',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeService.to.mode,

      // Localization
      translations: AppTranslations(),
      locale: LocaleService.to.current,
      fallbackLocale: const Locale('en'),

      // Flutter currently provides Material/Cupertino localizations
      // for English and Arabic. Somali translations are handled by GetX.
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Routing
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}