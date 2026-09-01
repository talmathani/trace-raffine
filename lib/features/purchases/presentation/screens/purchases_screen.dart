import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/purchase.dart';
import '../providers/purchase_providers.dart';

class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseRepository = ref.watch(purchaseRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Purchases')),
      body: FutureBuilder<List<Purchase>>(
        future: purchaseRepository.getPurchases('current_user_id'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                  leading: const Icon(Icons.check_circle, color: Colors.green),
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
