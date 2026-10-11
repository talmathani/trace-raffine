import 'package:trace_raffine/core/functions/function_invoker.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../models/purchase_model.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final FunctionInvoker _functionInvoker;

  PurchaseRepositoryImpl({FunctionInvoker? functionInvoker})
    : _functionInvoker = functionInvoker ?? FunctionInvoker.create();

  @override
  Future<List<Purchase>> getPurchases(String userId) async {
    final result = await _functionInvoker.listPurchases(userId: userId);
    if (result['success'] != true) {
      throw StateError(
        result['error']?.toString() ?? 'Unable to load purchases.',
      );
    }

    final purchases = result['purchases'];
    if (purchases is! List) return const <Purchase>[];

    return purchases
        .whereType<Map>()
        .map((raw) {
          final data = raw['data'] is Map
              ? Map<String, dynamic>.from(raw['data'] as Map)
              : Map<String, dynamic>.from(raw);
          final id = raw[r'$id']?.toString() ?? raw['id']?.toString();
          if (id != null && id.isNotEmpty) data[r'$id'] = id;
          return PurchaseModel.fromJson(data);
        })
        .toList(growable: false);
  }

  @override
  Future<Purchase> addPurchase(Purchase purchase) async {
    final model = PurchaseModel(
      id: purchase.id,
      userId: purchase.userId,
      productId: purchase.productId,
      orderId: purchase.orderId,
      purchasedAt: purchase.purchasedAt,
    );

    final result = await _functionInvoker.purchaseProduct(
      userId: model.userId,
      productId: model.productId,
      orderId: model.orderId,
    );

    if (result['success'] != true) {
      throw StateError(
        result['error']?.toString() ?? 'Purchase could not be completed.',
      );
    }

    return PurchaseModel(
      id: result['purchaseId']?.toString() ?? model.id,
      userId: model.userId,
      productId: model.productId,
      orderId: model.orderId,
      purchasedAt: model.purchasedAt,
    );
  }

  @override
  Future<bool> hasPurchased(String userId, String productId) async {
    final purchases = await getPurchases(userId);
    return purchases.any((purchase) => purchase.productId == productId);
  }
}
