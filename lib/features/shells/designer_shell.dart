import 'package:flutter/material.dart';

import 'package:trace_raffine/core/guards/role_guard.dart';
import 'package:trace_raffine/core/responsive/responsive.dart';
import '../../domain/entities/user_role.dart';
import '../account/account_screen.dart';
import '../designer/designer_earnings_screen.dart';
import '../designer/designer_my_designs_screen.dart';
import '../designer/designer_upload_screen.dart';
import '../designer/designer_review_status_screen.dart';
import '../designer/designer_notifications_screen.dart';
import '../home/shared_home_screen.dart';

class DesignerShell extends StatelessWidget {
  const DesignerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleGuard(
      requiredRole: UserRole.designer,
      child: _DesignerNavigation(),
    );
  }
}

class _DesignerNavigation extends StatefulWidget {
  const _DesignerNavigation();

  @override
  State<_DesignerNavigation> createState() => _DesignerNavigationState();
}

class _DesignerNavigationState extends State<_DesignerNavigation> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    SharedHomeScreen(),
    DesignerUploadScreen(),
    DesignerMyDesignsScreen(),
    DesignerEarningsScreen(),
    DesignerReviewStatusScreen(),
    DesignerNotificationsScreen(),
    AccountScreen(),
  ];

  static const List<AdaptiveNavigationItem> _destinations = [
    AdaptiveNavigationItem(
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront_rounded),
      label: 'الرئيسية',
    ),
    AdaptiveNavigationItem(
      icon: Icon(Icons.cloud_upload_outlined),
      selectedIcon: Icon(Icons.cloud_upload_rounded),
      label: 'رفع تصميم',
    ),
    AdaptiveNavigationItem(
      icon: Icon(Icons.design_services_outlined),
      selectedIcon: Icon(Icons.design_services_rounded),
      label: 'مكتبتي',
    ),
    AdaptiveNavigationItem(
      icon: Icon(Icons.payments_outlined),
      selectedIcon: Icon(Icons.payments_rounded),
      label: 'الأرباح',
    ),
    AdaptiveNavigationItem(
      icon: Icon(Icons.fact_check_outlined),
      selectedIcon: Icon(Icons.fact_check_rounded),
      label: 'المراجعة',
    ),
    AdaptiveNavigationItem(
      icon: Icon(Icons.notifications_none_outlined),
      selectedIcon: Icon(Icons.notifications_rounded),
      label: 'الإشعارات',
    ),
    AdaptiveNavigationItem(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'حسابي',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigationScaffold(
      currentIndex: _currentIndex,
      onDestinationSelected: (index) {
        if (index == _currentIndex) {
          return;
        }

        setState(() {
          _currentIndex = index;
        });
      },
      destinations: _destinations,
      body: IndexedStack(index: _currentIndex, children: _pages),
    );
  }
}
