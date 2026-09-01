import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order.dart';
import '../providers/order_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderRepository = ref.watch(orderRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: FutureBuilder<List<Order>>(
        future: orderRepository.getOrders('current_user_id'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: ListTile(
                  title: Text('Order: ${order.id ?? 'Unknown'}'),
                  subtitle: Text('Status: ${order.orderStatus}'),
                  trailing: Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC9A227),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
