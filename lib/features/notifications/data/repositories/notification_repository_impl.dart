import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../../../../core/appwrite/appwrite_database_service.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/app_notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final AppwriteDatabaseService _databaseService;

  NotificationRepositoryImpl(this._databaseService);

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    final response = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.notificationsCollection,
    );

    return response.documents
        .map((doc) => AppNotificationModel.fromJson({
              ...doc.data,
              r'$id': doc.$id,
            }))
        .where((notification) => notification.userId == userId)
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _databaseService.updateDocument(
      collectionId: AppwriteDatabaseConstants.notificationsCollection,
      documentId: notificationId,
      data: {'is_read': true},
    );
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final response = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.notificationsCollection,
    );

    for (final doc in response.documents) {
      if (doc.data['user_id'] == userId) {
        await _databaseService.updateDocument(
          collectionId: AppwriteDatabaseConstants.notificationsCollection,
          documentId: doc.$id,
          data: {'is_read': true},
        );
      }
    }
  }
}
