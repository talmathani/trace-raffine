import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_raffine/core/auth/current_user_service.dart';
import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';

import 'manager_chat_screen.dart';

import 'domain/entities/app_notification.dart';
import 'presentation/providers/notification_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<AppNotification> _notifications = const <AppNotification>[];
  bool _loading = true;
  String? _error;

  Future<void> _loadNotifications() async {
    try {
      final userId = await CurrentUserService.userId;
      if (userId == null || userId.isEmpty) {
        if (!mounted) return;
        setState(() {
          _notifications = const [];
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
        _notifications = notifications;
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

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _openNotification(
    BuildContext context,
    AppNotification notification,
  ) async {
    if (notification.id != null &&
        notification.id!.isNotEmpty &&
        !notification.isRead) {
      await ref
          .read(notificationRepositoryProvider)
          .markAsRead(notification.id!);
      if (mounted) {
        setState(() {
          _notifications = [
            for (final item in _notifications)
              item.id == notification.id ? item.copyWith(isRead: true) : item,
          ];
        });
      }
    }
    if (!context.mounted) return;
    final isManagerMessage =
        notification.title.trim() == 'رسالة جديدة من الإدارة';
    if (isManagerMessage) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ManagerChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notifications;
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: MaisonAppBar(title: 'الإشعارات'),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.responsiveContentMaxWidth,
          ),
          child: Column(
            children: [
              Expanded(
                child: _loading
                    ? const _NotificationsLoadingState()
                    : _error != null
                    ? const _NotificationsMessageState()
                    : notifications.isEmpty
                    ? const _NotificationsMessageState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          context.responsiveHorizontalPadding,
                          context.isCompact ? 28 : 34,
                          context.responsiveHorizontalPadding,
                          56,
                        ),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) =>
                            _EditorialNotificationEntry(
                              index: index,
                              notification: notifications[index],
                              onTap: () => _openNotification(
                                context,
                                notifications[index],
                              ),
                            ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorialNotificationEntry extends StatelessWidget {
  final int index;
  final AppNotification notification;
  final VoidCallback onTap;

  const _EditorialNotificationEntry({
    required this.index,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sequence = (index + 1).toString().padLeft(2, '0');
    final isRead = notification.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 34,
              child: Text(
                sequence,
                style: TextStyle(
                  fontFamily: AppTheme.fontEditorial,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isRead ? AppTheme.mutedText : AppTheme.softRose,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 1,
              constraints: const BoxConstraints(minHeight: 94),
              color: isRead
                  ? AppTheme.divider
                  : AppTheme.softRose.withValues(alpha: 0.78),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          isRead ? 'READ' : 'UNREAD',
                          style: TextStyle(
                            fontFamily: AppTheme.fontTechnical,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.2,
                            color: isRead
                                ? AppTheme.mutedText
                                : AppTheme.softRose,
                            height: 1,
                          ),
                        ),
                      ),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRead ? AppTheme.divider : AppTheme.softRose,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Text(
                    notification.title,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: AppTheme.fontArabic,
                      fontSize: 17,
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                      color: isRead ? AppTheme.mutedIvory : AppTheme.warmIvory,
                      height: 1.45,
                    ),
                  ),
                  if (notification.body != null &&
                      notification.body!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      notification.body!,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppTheme.fontArabic,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: isRead
                            ? AppTheme.mutedText
                            : AppTheme.secondaryText,
                        height: 1.7,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isRead
                        ? AppTheme.divider
                        : AppTheme.softRose.withValues(alpha: 0.24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsLoadingState extends StatelessWidget {
  const _NotificationsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NOTIFICATIONS',
              style: TextStyle(
                fontFamily: AppTheme.fontTechnical,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: AppTheme.softRose.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 54,
              height: 1,
              color: AppTheme.softRose.withValues(alpha: 0.58),
            ),
            const SizedBox(height: 16),
            const Text(
              'جاري تحميل الإشعارات',
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.mutedIvory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsMessageState extends StatelessWidget {
  const _NotificationsMessageState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NOTIFICATIONS',
              style: TextStyle(
                fontFamily: AppTheme.fontTechnical,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: AppTheme.softRose.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'لا توجد إشعارات',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.warmIvory,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
