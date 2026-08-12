import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/localization/app_locale.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/splash/splash_screen.dart';

class TRApp extends StatelessWidget {
  const TRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (_) => AuthRepositoryImpl(),
      child: Builder(
        builder: (context) {
          return BlocProvider<AuthBloc>(
            create: (_) =>
                AuthBloc(authRepository: context.read<AuthRepository>())
                  ..add(const AuthStarted()),
            child: MaterialApp(
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
            ),
          );
        },
      ),
    );
  }
}
