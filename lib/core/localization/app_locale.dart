import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// TRACÉ RAFFINÉ
/// Arabic-first localization foundation.
///
/// The application is Arabic by default and uses RTL direction.
/// English support can be added later without changing the architecture.
class AppLocale {
  AppLocale._();

  static const Locale arabic = Locale('ar');

  static const List<Locale> supportedLocales = <Locale>[arabic];

  static const Locale defaultLocale = arabic;

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static const TextDirection defaultTextDirection = TextDirection.rtl;
}
