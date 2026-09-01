import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationRepository = ref.watch(notificationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<List<AppNotification>>(
        future: notificationRepository.getNotifications('current_user_id'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                color: notification.isRead ? Colors.white : Colors.amber.shade50,
                child: ListTile(
                  leading: Icon(
                    notification.isRead ? Icons.check_circle : Icons.circle,
                    color: notification.isRead ? Colors.grey : Colors.orange,
                  ),
                  title: Text(notification.title),
                  subtitle: notification.body != null ? Text(notification.body!) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
