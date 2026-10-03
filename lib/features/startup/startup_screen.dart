import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/deep_link/app_deep_link_service.dart';
import '../auth/presentation/pages/auth_gate.dart';
import '../auth/reset_password_screen.dart';
import '../home/shared_home_screen.dart';
import '../splash/splash_screen.dart';

enum _StartupMode { start, auth, guest, recovery }

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  _StartupMode _mode = _StartupMode.start;
  RecoveryLink? _recovery;
  StreamSubscription<RecoveryLink>? _recoverySubscription;

  @override
  void initState() {
    super.initState();

    _recoverySubscription = AppDeepLinkService.instance.recoveryLinks.listen(
      _openRecovery,
    );

    final pending = AppDeepLinkService.instance.pendingRecovery;
    if (pending != null) {
      _openRecovery(pending);
    }
  }

  @override
  void dispose() {
    _recoverySubscription?.cancel();
    super.dispose();
  }

  void _openRecovery(RecoveryLink recovery) {
    if (!mounted) {
      return;
    }

    setState(() {
      _recovery = recovery;
      _mode = _StartupMode.recovery;
    });

    AppDeepLinkService.instance.consumeRecovery();
  }

  void _openAuth() {
    if (!mounted) {
      return;
    }

    setState(() {
      _mode = _StartupMode.auth;
    });
  }

  void _backToStart() {
    if (!mounted) {
      return;
    }

    setState(() {
      _recovery = null;
      _mode = _StartupMode.start;
    });
  }

  void _openGuest() {
    if (!mounted) {
      return;
    }

    setState(() {
      _mode = _StartupMode.guest;
    });
  }

  void _closeRecovery() {
    if (!mounted) {
      return;
    }

    setState(() {
      _recovery = null;
      _mode = _StartupMode.auth;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_mode) {
      case _StartupMode.start:
        return SplashScreen(onLogin: _openAuth, onGuest: _openGuest);

      case _StartupMode.auth:
        return AuthGate(onBackToStart: _backToStart);

      case _StartupMode.guest:
        return const SharedHomeScreen();

      case _StartupMode.recovery:
        final recovery = _recovery;
        if (recovery == null) {
          return AuthGate(onBackToStart: _backToStart);
        }

        return ResetPasswordScreen(
          userId: recovery.userId,
          secret: recovery.secret,
          onCompleted: _closeRecovery,
          onBack: _closeRecovery,
        );
    }
  }
}
