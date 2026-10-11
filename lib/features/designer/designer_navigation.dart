import 'package:flutter/material.dart';

import 'package:trace_raffine/core/responsive/responsive.dart';
import '../home/shared_home_screen.dart';
import '../account/account_screen.dart';
import 'designer_upload_screen.dart';
import 'designer_my_designs_screen.dart';
import 'designer_earnings_screen.dart';

class DesignerNavigation extends StatefulWidget {
  const DesignerNavigation({super.key});

  @override
  State<DesignerNavigation> createState() => _DesignerNavigationState();
}

class _DesignerNavigationState extends State<DesignerNavigation> {
  int _currentIndex = 0;

  static final List<Widget> _pages = [
    const SharedHomeScreen(),
    const DesignerUploadScreen(),
    const DesignerMyDesignsScreen(),
    const DesignerEarningsScreen(),
    const AccountScreen(),
  ];

  static const List<AdaptiveNavigationItem> _destinations = [
    AdaptiveNavigationItem(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
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
      body: _pages[_currentIndex],
    );
  }
}
