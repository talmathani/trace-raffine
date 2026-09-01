import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trace_raffine/domain/entities/user_role.dart';
import 'package:trace_raffine/features/auth/login_screen.dart';
import 'package:trace_raffine/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trace_raffine/features/auth/presentation/bloc/auth_event.dart';
import 'package:trace_raffine/features/auth/presentation/bloc/auth_state.dart';
import 'package:trace_raffine/features/profile/services/profile_session_service.dart';
import 'package:trace_raffine/features/shells/customer_shell.dart';
import 'package:trace_raffine/features/shells/designer_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
          case AuthStatus.loading:
            return const _AuthLoadingScreen();

          case AuthStatus.unauthenticated:
          case AuthStatus.failure:
            return const LoginScreen();

          case AuthStatus.authenticated:
            return const _AuthenticatedRoleRouter();

          case AuthStatus.authenticatedProfileMissing:
            // Auth session is valid — do NOT log the user out.
            // Profile document is missing in Appwrite Database.
            // This state should be handled by a future ProfileCreationFlow.
            return _AuthProfileMissingScreen(user: state.user);

          case AuthStatus.recoverySent:
          case AuthStatus.recoveryConfirmed:
            return const LoginScreen();
        }
      },
    );
  }
}

/// Reads the already-loaded profile from [ProfileSessionService] synchronously.
/// AuthBloc guarantees the profile is loaded before emitting [AuthStatus.authenticated].
class _AuthenticatedRoleRouter extends StatelessWidget {
  const _AuthenticatedRoleRouter();

  @override
  Widget build(BuildContext context) {
    final session = context.read<ProfileSessionService>();
    final role = session.activeRole ?? session.currentProfile?.role;

    debugPrint('=== AUTH GATE: ROLE ROUTER === role=$role');

    switch (role) {
      case UserRole.customer:
        debugPrint('=== AUTH GATE: CUSTOMER -> CUSTOMER SHELL ===');
        return const CustomerShell();

      case UserRole.designer:
        debugPrint('=== AUTH GATE: DESIGNER -> DESIGNER SHELL ===');
        return const DesignerShell();

      case null:
        // Should not reach here under normal operation.
        // AuthBloc should have emitted authenticatedProfileMissing instead.
        debugPrint('=== AUTH GATE: UNEXPECTED NULL ROLE IN AUTHENTICATED STATE ===');
        return const _AuthLoadingScreen();
    }
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF12090D),
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// Shown when the auth session is valid but no UserProfile document was found.
/// The user is NOT logged out. This is a distinct incomplete-account state.
class _AuthProfileMissingScreen extends StatelessWidget {
  const _AuthProfileMissingScreen({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12090D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_outlined, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              const Text(
                'لم يتم العثور على الملف الشخصي',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'حسابك موجود لكن لم يتم إنشاء الملف الشخصي بعد.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthLogoutRequested()),
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
