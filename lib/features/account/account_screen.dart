import 'package:flutter/material.dart';
import '../favorites/presentation/screens/favorites_screen.dart';
import '../orders/presentation/screens/orders_screen.dart';
import '../notifications/presentation/screens/notifications_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('المفضلة'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('طلباتي'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_none_outlined),
              title: const Text('الإشعارات'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
