import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource dataSource;

  NotificationRepositoryImpl(this.dataSource);

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    final models = await dataSource.getNotifications(userId);
    return models.cast<AppNotification>();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await dataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await dataSource.markAllAsRead(userId);
  }
}
