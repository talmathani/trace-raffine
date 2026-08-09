import 'package:flutter/material.dart';

import 'core/localization/app_locale.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

class TRApp extends StatelessWidget {
  const TRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TRACÉ RAFFINÉ',
      theme: AppTheme.darkTheme,
      locale: AppLocale.defaultLocale,
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: AppLocale.localizationsDelegates,
      builder: (context, child) {
        return Directionality(
          textDirection: AppLocale.defaultTextDirection,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
