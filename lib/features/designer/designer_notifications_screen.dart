import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum DesignerNotificationType {
  pendingReview,
  approved,
  rejected,
  sale,
  adminMessage,
}

class DesignerNotification {
  const DesignerNotification({
    required this.type,
    required this.title,
    required this.message,
    required this.timeLabel,
    this.designName,
    this.isRead = false,
  });

  final DesignerNotificationType type;
  final String title;
  final String message;
  final String timeLabel;
  final String? designName;
  final bool isRead;
}

class DesignerNotificationsScreen extends StatelessWidget {
  const DesignerNotificationsScreen({super.key});

  static const List<DesignerNotification> _notifications = [];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإشعارات')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildNotificationSummary(),
            const SizedBox(height: 20),
            if (_notifications.isEmpty)
              _buildEmptyState()
            else
              ..._notifications.map(_buildNotificationCard),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppTheme.deepBurgundy, AppTheme.burgundyBlack],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.notifications_active_rounded,
            color: AppTheme.softRose,
            size: 34,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إشعاراتك',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'تابع آخر التحديثات المتعلقة بتصاميمك ومبيعاتك.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppTheme.mutedIvory,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.mark_email_unread_outlined,
            color: AppTheme.softRose,
            size: 22,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'الإشعارات الجديدة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.warmIvory,
              ),
            ),
          ),
          Text(
            '${_notifications.where((item) => !item.isRead).length}',
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.softRose,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: AppTheme.softRose,
            size: 52,
          ),
          SizedBox(height: 18),
          Text(
            'لا توجد إشعارات جديدة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ستظهر هنا إشعارات قبول أو رفض التصاميم، '
            'حالة المراجعة، ومبيعات تصاميمك.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppTheme.mutedIvory,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(DesignerNotification notification) {
    final icon = _iconFor(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppTheme.burgundyBlack
            : AppTheme.deepBurgundy,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: notification.isRead
              ? AppTheme.divider
              : AppTheme.softRose.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.burgundyBlack,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.softRose, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.warmIvory,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppTheme.softRose,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppTheme.mutedIvory,
                    height: 1.7,
                  ),
                ),
                if (notification.designName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    notification.designName!,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.softRose,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  notification.timeLabel,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(DesignerNotificationType type) {
    switch (type) {
      case DesignerNotificationType.pendingReview:
        return Icons.pending_actions_rounded;
      case DesignerNotificationType.approved:
        return Icons.check_circle_outline_rounded;
      case DesignerNotificationType.rejected:
        return Icons.cancel_outlined;
      case DesignerNotificationType.sale:
        return Icons.shopping_bag_outlined;
      case DesignerNotificationType.adminMessage:
        return Icons.support_agent_rounded;
    }
  }
}
