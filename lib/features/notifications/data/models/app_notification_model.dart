import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    super.id,
    required super.userId,
    required super.title,
    super.body,
    super.isRead,
    super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['\$id'],
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
