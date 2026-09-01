import 'package:flutter/material.dart';

import '../../core/guards/role_guard.dart';
import '../../core/responsive/responsive.dart';
import '../../domain/entities/user_role.dart';
import '../account/account_screen.dart';
import '../cart/presentation/screens/cart_screen.dart';
import '../home/shared_home_screen.dart';
import '../purchases/presentation/screens/purchases_screen.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleGuard(
      requiredRole: UserRole.customer,
      child: _CustomerNavigation(),
    );
  }
}

class _CustomerNavigation extends StatefulWidget {
  const _CustomerNavigation();

  @override
  State<_CustomerNavigation> createState() => _CustomerNavigationState();
}

class _CustomerNavigationState extends State<_CustomerNavigation> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    SharedHomeScreen(),
    CartScreen(),
    PurchasesScreen(),
    AccountScreen(),
  ];

  static const List<AdaptiveNavigationItem> _destinations = [
    AdaptiveNavigationItem(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'الرئيسية',
    ),
    AdaptiveNavigationItem(
      icon: Icon(Icons.shopping_cart_outlined),
      selectedIcon: Icon(Icons.shopping_cart_rounded),
      label: 'السلة',
    ),
    AdaptiveNavigationItem(
      icon: Icon(Icons.shopping_bag_outlined),
      selectedIcon: Icon(Icons.shopping_bag_rounded),
      label: 'مشترياتي',
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
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
    );
  }
}
