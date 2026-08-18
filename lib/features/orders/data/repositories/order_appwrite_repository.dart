import '../../domain/repositories/order_repository.dart';
import '../datasources/appwrite/order_appwrite_datasource.dart';

class OrderAppwriteRepositoryImpl implements OrderRepository {
  OrderAppwriteRepositoryImpl({OrderAppwriteDataSource? dataSource})
    : _dataSource = dataSource ?? OrderAppwriteDataSource();

  final OrderAppwriteDataSource _dataSource;

  @override
  Future<String> createOrder({
    required String customerId,
    required String designId,
    required String designerId,
    required double amount,
  }) {
    return _dataSource.createOrder(
      customerId: customerId,
      designId: designId,
      designerId: designerId,
      amount: amount,
    );
  }
}
