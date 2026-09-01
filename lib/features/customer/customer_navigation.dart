import 'package:flutter/material.dart';
import '../products/presentation/screens/products_screen.dart';
import '../products/presentation/screens/product_details_screen.dart';
import '../categories/presentation/screens/categories_screen.dart';
import '../favorites/presentation/screens/favorites_screen.dart';
import '../cart/presentation/screens/cart_screen.dart';
import '../orders/presentation/screens/orders_screen.dart';
import '../purchases/presentation/screens/purchases_screen.dart';
import '../notifications/presentation/screens/notifications_screen.dart';

class CustomerNavigation {
  static void goToProducts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductsScreen()),
    );
  }

  static void goToProductDetails(BuildContext context, dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
    );
  }

  static void goToCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoriesScreen()),
    );
  }

  static void goToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
  }

  static void goToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  static void goToOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrdersScreen()),
    );
  }

  static void goToPurchases(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PurchasesScreen()),
    );
  }

  static void goToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }
}
