import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/purchase.dart';
import '../providers/purchase_providers.dart';
import '../../../../core/auth/current_user_service.dart';

class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  Future<List<Purchase>> _loadPurchases(WidgetRef ref) async {
    final userId = await CurrentUserService.userId;
    if (userId == null) return [];

    return ref.read(purchaseRepositoryProvider).getPurchases(userId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Purchases')),
      body: FutureBuilder<List<Purchase>>(
        future: _loadPurchases(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('تعذر تحميل المشتريات: ${snapshot.error}'),
            );
          }

          final purchases = snapshot.data ?? [];

          if (purchases.isEmpty) {
            return const Center(child: Text('No purchases yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: Text('Product: ${purchase.productId}'),
                  subtitle: Text('Order: ${purchase.orderId}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
