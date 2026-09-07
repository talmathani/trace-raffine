import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_providers.dart';
import '../../../../core/auth/current_user_service.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  Future<List<CartItem>> _loadItems() async {
    final userId = await CurrentUserService.userId;
    if (userId == null) return [];

    return ref.read(cartRepositoryProvider).getCartItems(userId);
  }

  Future<void> _remove(String id) async {
    try {
      await ref.read(cartRepositoryProvider).removeFromCart(id);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر حذف العنصر: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: FutureBuilder<List<CartItem>>(
        future: _loadItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('تعذر تحميل السلة: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('Cart is empty'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                child: ListTile(
                  title: Text(item.productId),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: item.id == null
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _remove(item.id!),
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
