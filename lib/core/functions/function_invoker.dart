import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import '../appwrite/appwrite_config.dart';

class FunctionInvoker {
  final Functions functions;

  FunctionInvoker(this.functions);

  factory FunctionInvoker.create() {
    final client = AppwriteConfig.createClient();
    return FunctionInvoker(Functions(client));
  }

  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    String currency = 'USD',
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'userId': userId,
        'items': items,
        'currency': currency,
      }),
    );

    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> reviewProduct({
    required String userId,
    required String productId,
    required int rating,
    String? reviewText,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.reviewProductFunctionId,
      body: jsonEncode({
        'userId': userId,
        'productId': productId,
        'rating': rating,
        'reviewText': reviewText,
      }),
    );

    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> purchaseProduct({
    required String userId,
    required String productId,
    required String orderId,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.purchaseProductFunctionId,
      body: jsonEncode({
        'userId': userId,
        'productId': productId,
        'orderId': orderId,
      }),
    );

    return _parseResponse(execution.responseBody);
  }

  Map<String, dynamic> _parseResponse(String? body) {
    if (body == null || body.isEmpty) {
      return {'success': false, 'error': 'Empty response'};
    }
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'error': 'Malformed response'};
    }
  }
}
