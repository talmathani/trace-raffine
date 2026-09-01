import 'package:flutter/material.dart';

import '../auth/presentation/pages/auth_gate.dart';
import '../splash/splash_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  bool _entered = false;

  void _enter() {
    if (_entered || !mounted) {
      return;
    }

    setState(() {
      _entered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_entered) {
      return const AuthGate();
    }

    return SplashScreen(onEnter: _enter);
  }
}
