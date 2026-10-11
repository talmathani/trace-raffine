import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_role.dart';
import '../../features/profile/services/profile_session_service.dart';

class RoleGuard extends StatelessWidget {
  const RoleGuard({super.key, required this.requiredRole, required this.child});

  final UserRole requiredRole;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final session = context.read<ProfileSessionService>();
    final currentRole = session.activeRole ?? session.currentProfile?.role;

    if (currentRole == requiredRole) {
      return child;
    }

    return const _RoleAccessDenied();
  }
}

class _RoleAccessDenied extends StatelessWidget {
  const _RoleAccessDenied();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('هذه الواجهة غير متاحة لهذا الحساب.')),
    );
  }
}
