import 'package:flutter/material.dart';

import '../../features/authentication/presentation/admin_auth_state.dart';
import '../../features/authentication/presentation/admin_login_page.dart';
import '../../features/authentication/presentation/admin_reset_password_page.dart';
import '../../features/authentication/presentation/admin_recovery_request_page.dart';
import '../../features/dashboard/presentation/admin_dashboard_page.dart';

final class AdminRouteGuard {
  const AdminRouteGuard._();

  static bool canAccessDashboard(AdminAuthState state) {
    return state.status == AdminAuthStatus.authenticated &&
        state.access?.isAdmin == true;
  }

  static String resolveInitialRoute(AdminAuthState state) {
    if (state.status == AdminAuthStatus.authenticated &&
        state.access?.isAdmin == true) {
      return '/dashboard';
    }

    return '/login';
  }
}

final class AdminRouter {
  const AdminRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SizedBox.shrink(),
        );

      case '/login':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AdminLoginPage(),
        );

      case '/recovery':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AdminRecoveryRequestPage(),
        );

      case '/reset-password':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => AdminResetPasswordPage(userId: Uri.base.queryParameters['userId'], secret: Uri.base.queryParameters['secret']),
        );

      case '/dashboard':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AdminDashboardPage(),
        );

      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SizedBox.shrink(),
        );
    }
  }
}



