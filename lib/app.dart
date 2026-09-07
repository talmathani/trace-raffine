import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/appwrite/appwrite_config.dart';
import 'core/appwrite/appwrite_service.dart';
import 'core/appwrite/appwrite_database_service.dart';
import 'core/localization/app_locale.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/user_profile_repository.dart';
import 'features/auth/data/datasources/appwrite_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/startup/startup_screen.dart';
import 'features/customer/data/datasources/appwrite/customer_design_appwrite_datasource.dart';
import 'features/customer/data/repositories/customer_design_repository.dart';
import 'features/customer/domain/repositories/customer_design_repository.dart';
import 'features/customer/domain/usecases/watch_approved_customer_designs.dart';
import 'features/designer/data/repositories/designer_design_appwrite_repository.dart';
import 'features/designer/domain/repositories/designer_design_repository.dart';
import 'features/designer/domain/usecases/create_designer_design.dart';
import 'features/profile/data/datasources/appwrite_user_profile_datasource.dart';
import 'features/profile/data/repositories/user_profile_repository_impl.dart';
import 'features/profile/domain/usecases/get_user_profile.dart';
import 'features/profile/services/profile_session_service.dart';

class TRApp extends StatelessWidget {
  const TRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AppwriteDatabaseService>(
      create: (_) => AppwriteDatabaseService(),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AppwriteAuthDataSource>(
            create: (_) =>
                AppwriteAuthDataSource(client: AppwriteConfig.createClient()),
          ),
          RepositoryProvider<AuthRepository>(
            create: (context) => AuthRepositoryImpl(
              dataSource: context.read<AppwriteAuthDataSource>(),
            ),
          ),
          RepositoryProvider<DesignerDesignRepository>(
            create: (_) => DesignerDesignAppwriteRepositoryImpl(),
          ),
          RepositoryProvider<CustomerDesignAppwriteDataSource>(
            create: (context) => CustomerDesignAppwriteDataSource(
              databaseService: context.read<AppwriteDatabaseService>(),
            ),
          ),
          RepositoryProvider<CustomerDesignRepository>(
            create: (context) => CustomerDesignRepositoryImpl(
              appwriteDataSource: context
                  .read<CustomerDesignAppwriteDataSource>(),
            ),
          ),
          RepositoryProvider<WatchApprovedCustomerDesigns>(
            create: (context) => WatchApprovedCustomerDesigns(
              repository: context.read<CustomerDesignRepository>(),
            ),
          ),
          RepositoryProvider<UserProfileRepository>(
            create: (context) => UserProfileRepositoryImpl(
              AppwriteUserProfileDatasource(
                TablesDB(AppwriteService.client),
              ),
            ),
          ),
          RepositoryProvider<GetUserProfile>(
            create: (context) =>
                GetUserProfile(context.read<UserProfileRepository>()),
          ),
          RepositoryProvider<ProfileSessionService>(
            create: (context) => ProfileSessionService(
              context.read<AppwriteAuthDataSource>(),
              context.read<GetUserProfile>(),
              context.read<UserProfileRepository>(),
            ),
          ),
        ],
        child: Builder(
          builder: (context) {
            return BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                authRepository: context.read<AuthRepository>(),
                profileSessionService: context.read<ProfileSessionService>(),
              )..add(const AuthStarted()),
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
                  home: const StartupScreen(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}





