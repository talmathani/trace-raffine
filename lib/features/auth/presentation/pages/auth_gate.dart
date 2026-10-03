import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_raffine/core/motion/maison_motion.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';
import 'security_lock_screen.dart';
import 'package:trace_raffine/features/auth/login_screen.dart';

import 'package:trace_raffine/domain/entities/user_role.dart';
import 'package:trace_raffine/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trace_raffine/features/auth/presentation/bloc/auth_event.dart';
import 'package:trace_raffine/features/auth/presentation/bloc/auth_state.dart';
import 'package:trace_raffine/features/profile/services/profile_session_service.dart';
import 'package:trace_raffine/features/shells/customer_shell.dart';
import 'package:trace_raffine/features/shells/designer_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.onBackToStart});

  final VoidCallback onBackToStart;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthStarted());
      }
    });
  }

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
            return LoginScreen(onBackToStart: widget.onBackToStart);

          case AuthStatus.authenticated:
            return const _AuthenticatedRoleRouter();

          case AuthStatus.securityLocked:
            return const SecurityLockScreen();

          case AuthStatus.authenticatedProfileMissing:
            return _AuthProfileMissingScreen(user: state.user);

          case AuthStatus.recoverySent:
          case AuthStatus.recoveryConfirmed:
            return LoginScreen(onBackToStart: widget.onBackToStart);
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
        debugPrint(
          '=== AUTH GATE: UNEXPECTED NULL ROLE IN AUTHENTICATED STATE ===',
        );
        return const _AuthLoadingScreen();
    }
  }
}

class _AuthLoadingScreen extends StatefulWidget {
  const _AuthLoadingScreen();

  @override
  State<_AuthLoadingScreen> createState() => _AuthLoadingScreenState();
}

class _AuthLoadingScreenState extends State<_AuthLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: MaisonMotion.pageEntrance,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final expanded = size.width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppTheme.burgundyBlack,
                  AppTheme.obsidian,
                  AppTheme.deepBurgundy.withValues(alpha: 0.72),
                ],
                stops: const [0.0, 0.52, 1.0],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: expanded
                        ? const Alignment(0.42, -0.24)
                        : const Alignment(0.0, -0.28),
                    radius: expanded ? 0.92 : 0.88,
                    colors: [
                      AppTheme.roseBurgundy.withValues(
                        alpha: expanded ? 0.085 : 0.065,
                      ),
                      AppTheme.primaryBurgundy.withValues(
                        alpha: expanded ? 0.028 : 0.022,
                      ),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.44, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: expanded ? -120 : -90,
            top: expanded ? -140 : -100,
            child: Container(
              width: expanded ? 430 : 300,
              height: expanded ? 430 : 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBurgundy.withValues(alpha: 0.14),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _controller,
                curve: MaisonMotion.easeOut,
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.035),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: MaisonMotion.easeOut,
                      ),
                    ),
                child: Container(
                  constraints: BoxConstraints(maxWidth: expanded ? 500 : 560),
                  margin: EdgeInsets.symmetric(horizontal: expanded ? 48 : 20),
                  padding: EdgeInsets.symmetric(
                    horizontal: expanded ? 42 : 26,
                    vertical: expanded ? 38 : 30,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.burgundyBlack.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(
                      AppTheme.editorialPanelRadius,
                    ),
                    border: Border.all(
                      color: AppTheme.softRose.withValues(alpha: 0.14),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 40,
                        spreadRadius: 2,
                        offset: Offset(0, 18),
                        color: Colors.black45,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TRACÉ RAFFINÉ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontEditorial,
                          color: AppTheme.warmIvory,
                          fontSize: expanded ? 30 : 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: expanded ? 5.0 : 3.8,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: 42,
                        height: 1,
                        color: AppTheme.softRose.withValues(alpha: 0.58),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'جارٍ تجهيز تجربتك',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontArabic,
                          color: AppTheme.mutedIvory,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.softRose,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
    final size = MediaQuery.sizeOf(context);
    final expanded = size.width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppTheme.burgundyBlack,
                  AppTheme.obsidian,
                  AppTheme.deepBurgundy.withValues(alpha: 0.52),
                ],
                stops: const [0.0, 0.48, 1.0],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: expanded
                        ? const Alignment(-0.34, 0.18)
                        : const Alignment(0.0, -0.18),
                    radius: expanded ? 0.94 : 0.88,
                    colors: [
                      AppTheme.roseBurgundy.withValues(
                        alpha: expanded ? 0.075 : 0.058,
                      ),
                      AppTheme.primaryBurgundy.withValues(
                        alpha: expanded ? 0.024 : 0.018,
                      ),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.44, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: expanded ? -160 : -120,
            bottom: expanded ? -180 : -130,
            child: Container(
              width: expanded ? 500 : 360,
              height: expanded ? 500 : 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBurgundy.withValues(alpha: 0.11),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? 48 : 20,
                vertical: expanded ? 40 : 28,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    expanded ? 42 : 26,
                    expanded ? 38 : 30,
                    expanded ? 42 : 26,
                    expanded ? 34 : 28,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.burgundyBlack.withValues(alpha: 0.74),
                    borderRadius: BorderRadius.circular(
                      AppTheme.editorialPanelRadius,
                    ),
                    border: Border.all(
                      color: AppTheme.softRose.withValues(alpha: 0.16),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 40,
                        spreadRadius: 2,
                        offset: Offset(0, 18),
                        color: Colors.black45,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TRACÉ RAFFINÉ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontEditorial,
                          color: AppTheme.warmIvory,
                          fontSize: expanded ? 30 : 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: expanded ? 5.0 : 3.8,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 42,
                        height: 1,
                        color: AppTheme.softRose.withValues(alpha: 0.58),
                      ),
                      const SizedBox(height: 34),
                      Icon(
                        Icons.person_off_outlined,
                        color: AppTheme.softRose.withValues(alpha: 0.86),
                        size: expanded ? 42 : 38,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'لم يتم العثور على الملف الشخصي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontArabic,
                          color: AppTheme.warmIvory,
                          fontSize: expanded ? 27 : 23,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'حسابك موجود لكن لم يتم إنشاء الملف الشخصي بعد.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontArabic,
                          color: AppTheme.secondaryText,
                          fontSize: expanded ? 15 : 14,
                          fontWeight: FontWeight.w400,
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 34),
                      SizedBox(
                        width: expanded ? 320 : double.infinity,
                        child: EditorialButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              const AuthLogoutRequested(),
                            );
                          },
                          label: 'تسجيل الخروج',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
