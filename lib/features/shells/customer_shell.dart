import 'package:flutter/material.dart';

import '../../core/guards/role_guard.dart';
import '../../domain/entities/user_role.dart';
import '../customer/customer_navigation.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleGuard(
      requiredRole: UserRole.customer,
      child: CustomerNavigation(),
    );
  }
}
