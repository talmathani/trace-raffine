import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../models/app_notification_model.dart';

class NotificationDataSource {
  final Databases databases;

  NotificationDataSource(this.databases);

  factory NotificationDataSource.create() {
    final client = AppwriteConfig.createClient();
    return NotificationDataSource(Databases(client));
  }

  Future<List<AppNotificationModel>> getNotifications(String userId) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.notificationsCollection,
      queries: [
        Query.equal('user_id', userId),
        Query.orderDesc('created_at'),
        Query.limit(50),
      ],
    );
    return response.documents.map((doc) => AppNotificationModel.fromJson(doc.data)).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await databases.updateDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.notificationsCollection,
      documentId: notificationId,
      data: {'is_read': true},
    );
  }

  Future<void> markAllAsRead(String userId) async {
    final notifications = await getNotifications(userId);
    for (final notification in notifications) {
      if (!notification.isRead && notification.id != null) {
        await markAsRead(notification.id!);
      }
    }
  }
}
