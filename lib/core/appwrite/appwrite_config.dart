import 'package:appwrite/appwrite.dart';

abstract final class AppwriteConfig {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = 'trace-raffine';
  static const String databaseId = 'tr_database';
  
  static const String adminsTeamId = 'tr-admins';
  
  static const String designFilesBucketId = 'design-files';
  static const String productImagesBucketId = 'product-images';
  
  static const String createOrderFunctionId = 'create-order';
  static const String reviewProductFunctionId = 'review-product';
  static const String purchaseProductFunctionId = 'purchase-product';
  
  static Client createClient() {
    return Client()
      ..setEndpoint(endpoint)
      ..setProject(projectId);
  }
}
