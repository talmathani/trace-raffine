import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/routing/admin_router.dart';
import '../features/authentication/presentation/admin_auth_controller.dart';
import '../features/authentication/presentation/admin_auth_state.dart';
import '../features/authentication/presentation/admin_login_page.dart';
import '../features/authentication/presentation/admin_reset_password_page.dart';
import '../features/dashboard/presentation/admin_dashboard_page.dart';
import 'tr_admin_theme.dart';

final class TRAdminApp extends ConsumerStatefulWidget {
  const TRAdminApp({super.key});

  @override
  ConsumerState<TRAdminApp> createState() => _TRAdminAppState();
}

final class _TRAdminAppState extends ConsumerState<TRAdminApp> {
  bool _sessionRestoreStarted = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(_restoreSession);
  }

  Future<void> _restoreSession() async {
    if (_sessionRestoreStarted) {
      return;
    }

    _sessionRestoreStarted = true;

    await ref
        .read(adminAuthControllerProvider.notifier)
        .restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TRACÉ RAFFINÉ — Admin',
      theme: TRAdminTheme.dark,
      home: _buildEntryPage(authState),
      onGenerateRoute: AdminRouter.generateRoute,
    );
  }

  Widget _buildEntryPage(AdminAuthState authState) {
    if (Uri.base.path == '/reset-password') {
      return AdminResetPasswordPage(
        userId: Uri.base.queryParameters['userId'],
        secret: Uri.base.queryParameters['secret'],
      );
    }

    switch (authState.status) {
      case AdminAuthStatus.initial:
      case AdminAuthStatus.checkingSession:
        return const _AdminSessionLoadingPage();

      case AdminAuthStatus.authenticated:
        if (AdminRouteGuard.canAccessDashboard(authState)) {
          return const AdminDashboardPage();
        }

        return const AdminLoginPage();

      case AdminAuthStatus.unauthenticated:
      case AdminAuthStatus.unauthorized:
      case AdminAuthStatus.error:
        return const AdminLoginPage();
    }
  }
}

final class _AdminSessionLoadingPage extends StatelessWidget {
  const _AdminSessionLoadingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TRAdminTheme.obsidian,
      body: Center(
        child: CircularProgressIndicator(
          color: TRAdminTheme.roseBurgundy,
        ),
      ),
    );
  }
}

