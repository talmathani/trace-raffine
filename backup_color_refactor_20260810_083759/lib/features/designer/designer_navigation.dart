import 'package:flutter/material.dart';

import '../home/shared_home_screen.dart';
import 'designer_upload_screen.dart';
import 'designer_my_designs_screen.dart';
import 'designer_review_status_screen.dart';
import 'designer_earnings_screen.dart';
import 'designer_notifications_screen.dart';

class DesignerNavigation extends StatefulWidget {
  const DesignerNavigation({super.key});

  @override
  State<DesignerNavigation> createState() => _DesignerNavigationState();
}

class _DesignerNavigationState extends State<DesignerNavigation> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    SharedHomeScreen(),
    DesignerUploadScreen(),
    DesignerMyDesignsScreen(),
    DesignerReviewStatusScreen(),
    DesignerEarningsScreen(),
    DesignerNotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_upload_outlined),
            selectedIcon: Icon(Icons.cloud_upload_rounded),
            label: 'رفع',
          ),
          NavigationDestination(
            icon: Icon(Icons.design_services_outlined),
            selectedIcon: Icon(Icons.design_services_rounded),
            label: 'تصاميمي',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check_rounded),
            label: 'المراجعة',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments_rounded),
            label: 'الأرباح',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_outlined),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'الإشعارات',
          ),
        ],
      ),
    );
  }
}
