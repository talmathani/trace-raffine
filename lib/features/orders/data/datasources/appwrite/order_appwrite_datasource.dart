import 'package:appwrite/appwrite.dart';

import '../../../../../core/appwrite/appwrite_database_constants.dart';
import '../../../../../core/appwrite/appwrite_database_service.dart';

class OrderAppwriteDataSource {
  OrderAppwriteDataSource({AppwriteDatabaseService? databaseService})
    : _databaseService = databaseService ?? AppwriteDatabaseService();

  final AppwriteDatabaseService _databaseService;

  Future<String> createOrder({
    required String customerId,
    required String designId,
    required String designerId,
    required double amount,
  }) async {
    final document = await _databaseService.createDocument(
      collectionId: AppwriteDatabaseConstants.ordersCollectionId,
      data: {
        'customerId': customerId,
        'designId': designId,
        'designerId': designerId,
        'amount': amount,
        'status': 'pending',
      },
      permissions: [Permission.read(Role.user(customerId))],
    );

    return document.$id;
  }
}
