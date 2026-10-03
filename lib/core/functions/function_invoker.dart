import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';

class FunctionInvoker {
  final Functions functions;

  FunctionInvoker(this.functions);

  factory FunctionInvoker.create() {
    return FunctionInvoker(Functions(AppwriteService.client));
  }

  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.adminUserControlFunctionId,
      body: jsonEncode({
        'action': 'register_user',
        'email': email.trim(),
        'password': password,
        'name': name.trim(),
        'phone': phone.trim(),
        'role': role,
      }),
      xasync: false,
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    String currency = 'USD',
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'create_order',
        'userId': userId,
        'items': items,
        'currency': currency,
      }),
    );

    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> listNotifications({
    required String userId,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({'action': 'list_notifications', 'userId': userId}),
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> markNotificationRead({
    required String userId,
    required String notificationId,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'mark_notification_read',
        'userId': userId,
        'notificationId': notificationId,
      }),
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> markAllNotificationsRead({
    required String userId,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'mark_all_notifications_read',
        'userId': userId,
      }),
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> listManagerMessages({
    required String userId,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({'action': 'list_manager_messages', 'userId': userId}),
      xasync: false,
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> sendManagerMessage({
    required String userId,
    required String body,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'send_manager_message',
        'userId': userId,
        'body': body,
      }),
      xasync: false,
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> markManagerMessagesRead({
    required String userId,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'mark_manager_messages_read',
        'userId': userId,
      }),
      xasync: false,
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> listOrders({required String userId}) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({'action': 'list_orders', 'userId': userId}),
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> getOrder({
    required String userId,
    required String orderId,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'get_order',
        'userId': userId,
        'orderId': orderId,
      }),
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> listPurchases({required String userId}) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({'action': 'list_purchases', 'userId': userId}),
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> listReviews({
    required String userId,
    required String productId,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'list_reviews',
        'userId': userId,
        'productId': productId,
      }),
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> deleteReview({
    required String userId,
    required String reviewId,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'delete_review',
        'userId': userId,
        'reviewId': reviewId,
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
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'review_product',
        'userId': userId,
        'productId': productId,
        'rating': rating,
        'reviewText': reviewText,
      }),
    );

    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> getPurchasedFile({
    required String userId,
    required String productId,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'get_purchased_file',
        'userId': userId,
        'productId': productId,
      }),
      xasync: false,
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> purchaseProduct({
    required String userId,
    required String productId,
    required String orderId,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'purchase_product',
        'userId': userId,
        'productId': productId,
        'orderId': orderId,
      }),
    );

    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> listCartItems({required String userId}) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({'action': 'list_cart_items', 'userId': userId}),
      xasync: false,
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> addCartItem({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'add_cart_item',
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
      }),
      xasync: false,
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> updateCartItem({
    required String userId,
    required String cartItemId,
    required int quantity,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'update_cart_item',
        'userId': userId,
        'cartItemId': cartItemId,
        'quantity': quantity,
      }),
      xasync: false,
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> removeCartItem({
    required String userId,
    required String cartItemId,
  }) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({
        'action': 'remove_cart_item',
        'userId': userId,
        'cartItemId': cartItemId,
      }),
      xasync: false,
    );
    return _parseResponse(execution.responseBody);
  }

  Future<Map<String, dynamic>> clearCart({required String userId}) async {
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.createOrderFunctionId,
      body: jsonEncode({'action': 'clear_cart', 'userId': userId}),
      xasync: false,
    );
    return _parseResponse(execution.responseBody);
  }

  Map<String, dynamic> _parseResponse(String? body) {
    if (body == null || body.isEmpty) {
      return {'success': false, 'error': 'Empty response'};
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        return {'success': false, 'error': 'Malformed response'};
      }
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return {'success': false, 'error': 'Malformed response'};
    }
  }
}
