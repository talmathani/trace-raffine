import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cart/data/datasources/cart_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/categories/data/datasources/category_data_source.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/favorites/data/datasources/favorite_data_source.dart';
import '../../features/favorites/data/repositories/favorite_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorite_repository.dart';
import '../../features/notifications/data/datasources/notification_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/orders/data/datasources/order_data_source.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/products/data/datasources/product_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/purchases/data/datasources/purchase_data_source.dart';
import '../../features/purchases/data/repositories/purchase_repository_impl.dart';
import '../../features/purchases/domain/repositories/purchase_repository.dart';
import '../../features/reviews/data/datasources/review_data_source.dart';
import '../../features/reviews/data/repositories/review_repository_impl.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';

/// Composition Root الخاص باعتماديات Riverpod.
///
/// طبقة Presentation تستورد هذا الملف عند الحاجة إلى Repository contract،
/// ولا تستورد DataSource أو RepositoryImpl مباشرةً.
///
/// تم الإبقاء على factory `create()` لأن مصادر البيانات الحالية تملك هذا
/// الـ factory، ولضمان توافق التعديل مع النسخة الحالية من المشروع.

final cartDataSourceProvider = Provider<CartDataSource>((ref) {
  return CartDataSource.create();
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(ref.watch(cartDataSourceProvider));
});

final categoryDataSourceProvider = Provider<CategoryDataSource>((ref) {
  return CategoryDataSource.create();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryDataSourceProvider));
});

final favoriteDataSourceProvider = Provider<FavoriteDataSource>((ref) {
  return FavoriteDataSource.create();
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepositoryImpl(ref.watch(favoriteDataSourceProvider));
});

final notificationDataSourceProvider = Provider<NotificationDataSource>((ref) {
  return NotificationDataSource.create();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(notificationDataSourceProvider));
});

final orderDataSourceProvider = Provider<OrderDataSource>((ref) {
  return OrderDataSource.create();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(orderDataSourceProvider));
});

final productDataSourceProvider = Provider<ProductDataSource>((ref) {
  return ProductDataSource.create();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(productDataSourceProvider));
});

final purchaseDataSourceProvider = Provider<PurchaseDataSource>((ref) {
  return PurchaseDataSource.create();
});

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepositoryImpl(ref.watch(purchaseDataSourceProvider));
});

final reviewDataSourceProvider = Provider<ReviewDataSource>((ref) {
  return ReviewDataSource.create();
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(ref.watch(reviewDataSourceProvider));
});
