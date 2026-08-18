import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_role.dart';
import '../../features/profile/services/profile_session_service.dart';
import '../../features/auth/login_screen.dart';

class RoleGuard extends StatelessWidget {
  const RoleGuard({super.key, required this.requiredRole, required this.child});

  final UserRole requiredRole;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final session = context.read<ProfileSessionService>();

    final currentRole = session.currentProfile?.role;

    if (currentRole == requiredRole) {
      return child;
    }

    return const LoginScreen();
  }
}
