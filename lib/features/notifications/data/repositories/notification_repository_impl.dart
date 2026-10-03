import 'package:trace_raffine/core/appwrite/appwrite_service.dart';
import 'package:trace_raffine/core/functions/function_invoker.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/app_notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FunctionInvoker _functionInvoker;

  NotificationRepositoryImpl({FunctionInvoker? functionInvoker})
    : _functionInvoker = functionInvoker ?? FunctionInvoker.create();

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    final result = await _functionInvoker.listNotifications(userId: userId);
    if (result['success'] != true) {
      throw StateError(
        result['error']?.toString() ?? 'Unable to load notifications.',
      );
    }

    final notifications = result['notifications'];
    if (notifications is! List) return const <AppNotification>[];

    return notifications
        .whereType<Map>()
        .map((raw) {
          final data = raw['data'] is Map
              ? Map<String, dynamic>.from(raw['data'] as Map)
              : Map<String, dynamic>.from(raw);
          final id = raw[r'$id']?.toString() ?? raw['id']?.toString();
          if (id != null && id.isNotEmpty) data[r'$id'] = id;
          return AppNotificationModel.fromJson(data);
        })
        .toList(growable: false);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final userId = (await AppwriteService.account.get()).$id;
    final result = await _functionInvoker.markNotificationRead(
      userId: userId,
      notificationId: notificationId,
    );
    if (result['success'] != true) {
      throw StateError(
        result['error']?.toString() ?? 'Unable to mark notification as read.',
      );
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final result = await _functionInvoker.markAllNotificationsRead(
      userId: userId,
    );
    if (result['success'] != true) {
      throw StateError(
        result['error']?.toString() ?? 'Unable to mark notifications as read.',
      );
    }
  }
}
