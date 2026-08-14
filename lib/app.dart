import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/localization/app_locale.dart';
import 'core/appwrite/appwrite_database_service.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/appwrite_auth_datasource.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/designer/data/repositories/designer_design_appwrite_repository.dart';
import 'features/designer/domain/repositories/designer_design_repository.dart';
import 'features/designer/domain/usecases/create_designer_design.dart';
import 'features/splash/splash_screen.dart';

class TRApp extends StatelessWidget {
  const TRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppwriteDatabaseService>(
          create: (_) => AppwriteDatabaseService(),
        ),
        RepositoryProvider<AppwriteAuthDataSource>(
          create: (_) => AppwriteAuthDataSource(),
        ),

        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            dataSource: context.read<AppwriteAuthDataSource>(),
          ),
        ),
        RepositoryProvider<DesignerDesignRepository>(
          create: (_) => DesignerDesignAppwriteRepositoryImpl(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocProvider<AuthBloc>(
            create: (_) =>
                AuthBloc(authRepository: context.read<AuthRepository>())
                  ..add(const AuthStarted()),
            child: RepositoryProvider<CreateDesignerDesign>(
              create: (context) => CreateDesignerDesign(
                repository: context.read<DesignerDesignRepository>(),
              ),
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
            ),
          );
        },
      ),
    );
  }
}
