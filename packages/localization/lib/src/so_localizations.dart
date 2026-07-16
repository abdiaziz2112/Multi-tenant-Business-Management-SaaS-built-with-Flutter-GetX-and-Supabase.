/// Purpose: Make Locale('so') legal for Material/Cupertino widgets.
/// Responsibilities: Flutter's built-in GlobalMaterialLocalizations does not
/// include Somali, so we provide delegates: high-visibility widget strings are
/// translated; the long tail falls back to English defaults (documented in
/// KNOWN_LIMITATIONS.md). App-level strings are fully Somali via GetX already.
/// Dependencies: flutter material/cupertino.
/// Usage: add SoMaterialLocalizations.delegate and SoCupertinoLocalizations.delegate
/// BEFORE the Global*Localizations delegates in localizationsDelegates.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Somali Material strings. Extends the English defaults and overrides the
/// labels users actually see daily; everything else inherits English.
class SoMaterialLocalizations extends DefaultMaterialLocalizations {
  const SoMaterialLocalizations();

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _SoMaterialLocalizationsDelegate();

  @override
  String get okButtonLabel => 'Haye';
  @override
  String get cancelButtonLabel => 'Ka noqo';
  @override
  String get closeButtonLabel => 'Xir';
  @override
  String get closeButtonTooltip => 'Xir';
  @override
  String get backButtonTooltip => 'Dib u noqo';
  @override
  String get searchFieldLabel => 'Raadi';
  @override
  String get saveButtonLabel => 'Kaydi';
  @override
  String get deleteButtonTooltip => 'Tirtir';
  @override
  String get nextMonthTooltip => 'Bisha danbe';
  @override
  String get previousMonthTooltip => 'Bishii hore';
  @override
  String get moreButtonTooltip => 'Wax dheeraad ah';
  @override
  String get showMenuTooltip => 'Muuji liiska';
}

class _SoMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _SoMaterialLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';
  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const SoMaterialLocalizations();
  @override
  bool shouldReload(_SoMaterialLocalizationsDelegate old) => false;
}

/// Cupertino equivalent (needed because GetMaterialApp wires Cupertino too).
class SoCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const SoCupertinoLocalizations();

  static const LocalizationsDelegate<CupertinoLocalizations> delegate =
      _SoCupertinoLocalizationsDelegate();
}

class _SoCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _SoCupertinoLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';
  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      const SoCupertinoLocalizations();
  @override
  bool shouldReload(_SoCupertinoLocalizationsDelegate old) => false;
}
