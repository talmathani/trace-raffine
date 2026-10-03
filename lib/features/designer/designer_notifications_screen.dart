import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trace_raffine/core/auth/current_user_service.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_surface.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';

import '../notifications/domain/entities/app_notification.dart';
import '../notifications/manager_chat_screen.dart';
import '../notifications/presentation/providers/notification_providers.dart';

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

class DesignerNotificationsScreen extends ConsumerStatefulWidget {
  const DesignerNotificationsScreen({super.key});

  @override
  ConsumerState<DesignerNotificationsScreen> createState() =>
      _DesignerNotificationsScreenState();
}

class _DesignerNotificationsScreenState
    extends ConsumerState<DesignerNotificationsScreen> {
  List<AppNotification> _rawNotifications = const <AppNotification>[];
  bool _loading = true;
  String? _error;

  Future<void> _loadNotifications() async {
    try {
      final userId = await CurrentUserService.userId;
      if (userId == null || userId.isEmpty) {
        if (!mounted) return;
        setState(() {
          _rawNotifications = const [];
          _loading = false;
          _error = null;
        });
        return;
      }

      final notifications = await ref
          .read(notificationRepositoryProvider)
          .getNotifications(userId);
      if (!mounted) return;
      setState(() {
        _rawNotifications = notifications;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _openNotification(int index) async {
    final notification = _rawNotifications[index];
    if (notification.isRead ||
        notification.id == null ||
        notification.id!.isEmpty) {
      return;
    }

    final id = notification.id!;
    try {
      await ref.read(notificationRepositoryProvider).markAsRead(id);
      if (!mounted) return;
      setState(() {
        _rawNotifications = [
          for (final item in _rawNotifications)
            item.id == id ? item.copyWith(isRead: true) : item,
        ];
      });

      if (!mounted) return;
      if (notification.title.trim() == 'رسالة جديدة من الإدارة') {
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ManagerChatScreen()));
      }
    } catch (_) {
      // Keep the unread state if the backend could not persist the change.
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  static DesignerNotification _mapNotification(AppNotification notification) {
    final text = '${notification.title} ${notification.body ?? ''}'
        .toLowerCase();
    final type = text.contains('رفض') || text.contains('rejected')
        ? DesignerNotificationType.rejected
        : text.contains('قبول') ||
              text.contains('اعتماد') ||
              text.contains('approved')
        ? DesignerNotificationType.approved
        : text.contains('بيع') || text.contains('sale')
        ? DesignerNotificationType.sale
        : text.contains('مراجعة') || text.contains('review')
        ? DesignerNotificationType.pendingReview
        : DesignerNotificationType.adminMessage;

    final timeLabel = notification.createdAt == null
        ? ''
        : _formatDate(notification.createdAt!);

    return DesignerNotification(
      type: type,
      title: notification.title,
      message: notification.body ?? '',
      timeLabel: timeLabel,
      isRead: notification.isRead,
    );
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _rawNotifications
        .map(_mapNotification)
        .toList(growable: false);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: MaisonAppBar(title: 'الإشعارات'),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.softRose),
              )
            : _error != null
            ? _buildErrorState(_error!)
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildNotificationSummary(notifications),
                  const SizedBox(height: 20),
                  if (notifications.isEmpty)
                    _buildEmptyState()
                  else
                    ...List.generate(
                      notifications.length,
                      (index) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _openNotification(index),
                        child: _buildNotificationCard(notifications[index]),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'تعذر تحميل الإشعارات: $error',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.fontArabic,
            color: AppTheme.softRose,
          ),
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
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'تابع آخر التحديثات المتعلقة بتصاميمك ومبيعاتك.',
                  style: TextStyle(
                    fontFamily: AppTheme.fontArabic,
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

  Widget _buildNotificationSummary(List<DesignerNotification> notifications) {
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
                fontFamily: AppTheme.fontArabic,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.warmIvory,
              ),
            ),
          ),
          Text(
            '${notifications.where((item) => !item.isRead).length}',
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: AppTheme.fontArabic,
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
              fontFamily: AppTheme.fontArabic,
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
              fontFamily: AppTheme.fontArabic,
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

    return MaisonSurface(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      radius: AppTheme.editorialPanelRadius,
      color: notification.isRead
          ? AppTheme.burgundyBlack
          : AppTheme.deepBurgundy,
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
                          fontFamily: AppTheme.fontArabic,
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
                    fontFamily: AppTheme.fontArabic,
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
                      fontFamily: AppTheme.fontArabic,
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
                    fontFamily: AppTheme.fontArabic,
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
