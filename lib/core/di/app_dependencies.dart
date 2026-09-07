import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/favorites/domain/repositories/favorite_repository.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/data/datasources/product_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/designer/data/datasources/appwrite/designer_design_appwrite_datasource.dart';
import '../../features/designer/data/datasources/appwrite/designer_design_storage_appwrite_datasource.dart';
import '../../features/designer/data/repositories/designer_design_appwrite_repository.dart';
import '../../features/designer/domain/repositories/designer_design_repository.dart';
import '../../features/purchases/domain/repositories/purchase_repository.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  throw UnimplementedError('Migrated to direct Appwrite/Service architecture');
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  throw UnimplementedError('Migrated to direct Appwrite/Service architecture');
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  throw UnimplementedError('Migrated to direct Appwrite/Service architecture');
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  throw UnimplementedError('Migrated to direct Appwrite/Service architecture');
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  throw UnimplementedError('Migrated to direct Appwrite/Service architecture');
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    dataSource: ProductDataSource.create(),
  );
});

final designerDesignDataSourceProvider =
    Provider<DesignerDesignAppwriteDataSource>((ref) {
  return DesignerDesignAppwriteDataSource();
});

final designerDesignStorageDataSourceProvider =
    Provider<DesignerDesignStorageAppwriteDataSource>((ref) {
  return DesignerDesignStorageAppwriteDataSource();
});

final designerDesignRepositoryProvider = Provider<DesignerDesignRepository>((ref) {
  return DesignerDesignAppwriteRepositoryImpl(
    databaseDataSource: ref.watch(designerDesignDataSourceProvider),
    storageDataSource: ref.watch(designerDesignStorageDataSourceProvider),
  );
});

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  throw UnimplementedError('Migrated to direct Appwrite/Service architecture');
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  throw UnimplementedError('Migrated to direct Appwrite/Service architecture');
});
