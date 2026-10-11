import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trace_raffine/core/auth/current_user_service.dart';
import 'package:trace_raffine/core/device_notifications.dart';
import 'package:trace_raffine/core/functions/function_invoker.dart';
import 'package:trace_raffine/core/guards/role_guard.dart';
import 'package:trace_raffine/core/responsive/responsive.dart';
import '../../domain/entities/user_role.dart';
import '../account/account_screen.dart';
import '../designer/designer_my_designs_screen.dart';
import '../designer/designer_review_status_screen.dart';
import '../designer/designer_upload_screen.dart';
import '../home/shared_home_screen.dart';

class DesignerShell extends StatelessWidget {
  const DesignerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleGuard(
      requiredRole: UserRole.designer,
      child: _DesignerNavigation(),
    );
  }
}

class _DesignerNavigation extends StatefulWidget {
  const _DesignerNavigation();

  @override
  State<_DesignerNavigation> createState() => _DesignerNavigationState();
}

class _DesignerNavigationState extends State<_DesignerNavigation> {
  int _currentIndex = 0;
  Timer? _notificationTimer;
  final Set<String> _knownNotificationIds = <String>{};
  final Set<String> _deviceNotifiedIds = <String>{};
  bool _hasLoadedNotificationIds = false;
  bool _hasLegacyKnownNotificationIds = false;
  bool _hasLoadedDeviceNotifiedIds = false;
  Map<String, String>? _pendingDeviceNotification;

  static const String _knownNotificationsPreferenceKey =
      'designer_known_device_notification_ids_v2';
  static const String _legacyKnownNotificationsPreferenceKey =
      'designer_known_device_notification_ids_v1';
  static const String _deviceNotifiedPreferenceKey =
      'designer_device_notified_ids_v1';

  @override
  void initState() {
    super.initState();
    _restoreKnownNotificationIds().then((_) {
      if (!mounted) return;
      _refreshDesignerNotifications();
      _notificationTimer = Timer.periodic(
        const Duration(seconds: 15),
        (_) => _refreshDesignerNotifications(),
      );
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _restoreKnownNotificationIds() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final ids = preferences.getStringList(_knownNotificationsPreferenceKey);
      final legacyIds = preferences.getStringList(
        _legacyKnownNotificationsPreferenceKey,
      );
      if (ids != null) {
        _knownNotificationIds.addAll(ids);
      } else if (legacyIds != null) {
        _knownNotificationIds.addAll(legacyIds);
        _hasLegacyKnownNotificationIds = true;
      }
      final deviceIds = preferences.getStringList(_deviceNotifiedPreferenceKey);
      if (deviceIds != null) {
        _deviceNotifiedIds.addAll(deviceIds);
      }
      _hasLoadedDeviceNotifiedIds = deviceIds != null;
      _hasLoadedNotificationIds = ids != null;
    } catch (_) {
      // Notifications still refresh in memory when browser storage is unavailable.
    }
  }

  Future<void> _refreshDesignerNotifications() async {
    // Always poll in-app notifications; device notification support is optional.
    try {
      final userId = await CurrentUserService.userId;
      if (userId == null || userId.isEmpty) return;
      final result = await FunctionInvoker.create().listNotifications(
        userId: userId,
      );
      if (result['success'] != true) {
        debugPrint(
          'DESIGNER NOTIFICATION POLL FAILED: '
          '${result['error'] ?? 'server returned success=false'}',
        );
        return;
      }
      if (!mounted) return;
      final raw = result['notifications'];
      if (raw is! List) {
        debugPrint(
          'DESIGNER NOTIFICATION POLL INVALID RESPONSE: '
          'notifications is ${raw.runtimeType}',
        );
        return;
      }

      final notifications = raw.whereType<Map>().map((item) {
        final document = Map<String, dynamic>.from(item);
        final data = item['data'] is Map
            ? Map<String, dynamic>.from(item['data'] as Map)
            : document;
        final id = (document[r'$id'] ?? data[r'$id'] ?? '').toString();
        return <String, dynamic>{...data, r'$id': id};
      }).where((item) => (item[r'$id']?.toString() ?? '').isNotEmpty).toList();

      final unread = notifications
          .where((item) => item['is_read'] != true)
          .toList(growable: false);
      final newUnread = _hasLoadedNotificationIds
          ? unread
              .where((item) => !_knownNotificationIds.contains(item[r'$id'].toString()))
              .toList(growable: false)
          : unread.take(3).toList(growable: false);

      debugPrint(
        'DESIGNER NOTIFICATION POLL: total=${notifications.length} '
        'unread=${unread.length} new=${newUnread.length} '
        'devicePermission=${DeviceNotifications.permission}',
      );

      // Migrate legacy unread records without replaying the whole backlog:
      // keep the latest unread item eligible for one device alert.
      if (!_hasLoadedDeviceNotifiedIds) {
        if (_hasLegacyKnownNotificationIds && unread.length > 1) {
          _deviceNotifiedIds.addAll(
            unread.skip(1).map((item) => item[r'$id'].toString()),
          );
        }
        _hasLoadedDeviceNotifiedIds = true;
        try {
          final preferences = await SharedPreferences.getInstance();
          await preferences.setStringList(
            _deviceNotifiedPreferenceKey,
            _deviceNotifiedIds.toList(growable: false),
          );
        } catch (_) {
          // The migration is retried next poll if browser storage is unavailable.
          _hasLoadedDeviceNotifiedIds = false;
        }
      }
      if (!mounted) return;

      // Schedule the in-app alert before persisting the IDs. If the shell is
      // disposed or browser storage fails, the next poll can still retry.
      if (newUnread.isNotEmpty && mounted) {
        final latest = newUnread.first;
        final title = latest['title']?.toString() ?? 'تحديث بشأن تصميمك';
        final body = latest['body']?.toString() ??
            'لديك تحديث جديد من فريق TRACÉ RAFFINÉ.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title\n$body'),
            duration: const Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      _knownNotificationIds.addAll(
        notifications.map((item) => item[r'$id'].toString()),
      );
      if (_knownNotificationIds.length > 300) {
        _knownNotificationIds.removeAll(
          _knownNotificationIds.take(_knownNotificationIds.length - 300).toList(),
        );
      }
      _hasLoadedNotificationIds = true;
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setStringList(
          _knownNotificationsPreferenceKey,
          _knownNotificationIds.toList(growable: false),
        );
      } catch (_) {}

      // Device delivery has its own durable receipt ledger. Do not treat an
      // in-app toast or a previous failed browser notification as delivered.
      if (DeviceNotifications.isSupported &&
          DeviceNotifications.permission == 'granted') {
        final pendingForDevice = unread
            .where((item) =>
                !_deviceNotifiedIds.contains(item[r'$id'].toString()))
            .take(3);
        for (final item in pendingForDevice) {
          final id = item[r'$id'].toString();
          final delivered = _showDeviceNotification(
            item['title']?.toString() ?? 'تحديث بشأن تصميمك',
            item['body']?.toString() ??
                'لديك تحديث جديد من فريق TRACÉ RAFFINÉ.',
            id,
          );
          if (delivered) {
            _deviceNotifiedIds.add(id);
          }
        }
        try {
          final preferences = await SharedPreferences.getInstance();
          if (_deviceNotifiedIds.length > 300) {
            _deviceNotifiedIds.removeAll(
              _deviceNotifiedIds
                  .take(_deviceNotifiedIds.length - 300)
                  .toList(),
            );
          }
          await preferences.setStringList(
            _deviceNotifiedPreferenceKey,
            _deviceNotifiedIds.toList(growable: false),
          );
        } catch (_) {
          // In-memory retries still work until the current session ends.
        }
        _pendingDeviceNotification = null;
      } else if (DeviceNotifications.isSupported) {
        final undelivered = unread
            .where((item) =>
                !_deviceNotifiedIds.contains(item[r'$id'].toString()))
            .toList(growable: false);
        if (undelivered.isNotEmpty) {
          final latestUndelivered = undelivered.first;
          _pendingDeviceNotification = {
            'id': latestUndelivered[r'$id'].toString(),
            'title': latestUndelivered['title']?.toString() ??
                'تحديث بشأن تصميمك',
            'body': latestUndelivered['body']?.toString() ??
                'لديك تحديث جديد من فريق TRACÉ RAFFINÉ.',
          };
          if (mounted) setState(() {});
        }
      }
    } catch (error, stackTrace) {
      debugPrint('DESIGNER NOTIFICATION POLL ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  bool _showDeviceNotification(String title, String body, String id) {
    try {
      DeviceNotifications.show(
        title: title,
        body: body,
        tag: 'tr-designer-$id',
      );
      debugPrint('DESIGNER DEVICE NOTIFICATION SHOWN id=$id');
      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'DESIGNER DEVICE NOTIFICATION FAILED id=$id error=$error',
      );
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> _enableDeviceNotifications() async {
    try {
      var permission = DeviceNotifications.permission;
      if (permission == 'default') {
        permission = await DeviceNotifications.requestPermission();
      }
      if (!mounted) return;
      if (permission != 'granted') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم السماح بإشعارات الجهاز. فعّلها من إعدادات المتصفح.'),
          ),
        );
        return;
      }
      final pending = _pendingDeviceNotification;
      if (pending != null) {
        final id = pending['id'] ?? 'designer-update';
        if (_showDeviceNotification(
          pending['title'] ?? 'تحديث بشأن تصميمك',
          pending['body'] ?? 'لديك تحديث جديد من فريق TRACÉ RAFFINÉ.',
          id,
        )) {
          _deviceNotifiedIds.add(id);
          try {
            final preferences = await SharedPreferences.getInstance();
            await preferences.setStringList(
              _deviceNotifiedPreferenceKey,
              _deviceNotifiedIds.toList(growable: false),
            );
            _pendingDeviceNotification = null;
          } catch (_) {
            // Keep the notification pending if its receipt cannot be saved.
          }
        }
      }
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تفعيل إشعارات الجهاز لهذا المتصفح.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تفعيل إشعارات الجهاز في هذا المتصفح.'),
        ),
      );
    }
  }

  Widget _buildNotificationPermissionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.blueGrey.shade900,
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: Colors.white),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'فعّل إشعارات الجهاز لتصلك تحديثات قبول التصميم أو طلب تعديله.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: _enableDeviceNotifications,
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );
  }

  static const List<Widget> _pages = [
    SharedHomeScreen(),
    DesignerUploadScreen(),
    DesignerMyDesignsScreen(),
    DesignerReviewStatusScreen(),
    AccountScreen(),
  ];

  static const List<AdaptiveNavigationItem> _destinations = [
    AdaptiveNavigationItem(
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront_rounded),
      label: 'الرئيسية',
    ),
    AdaptiveNavigationItem(
      icon: Icon(Icons.cloud_upload_outlined),
      selectedIcon: Icon(Icons.cloud_upload_rounded),
      label: 'رفع تصميم',
    ),
    AdaptiveNavigationItem(
      icon: Icon(Icons.design_services_outlined),
      selectedIcon: Icon(Icons.design_services_rounded),
      label: 'مكتبتي',
    ),
    AdaptiveNavigationItem(
      icon: Icon(Icons.fact_check_outlined),
      selectedIcon: Icon(Icons.fact_check_rounded),
      label: 'حالة المراجعة',
    ),
    AdaptiveNavigationItem(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'حسابي',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigationScaffold(
      currentIndex: _currentIndex,
      onDestinationSelected: (index) {
        if (index == _currentIndex) {
          return;
        }

        setState(() {
          _currentIndex = index;
        });
      },
      destinations: _destinations,
      body: Column(
        children: [
          if (DeviceNotifications.isSupported && DeviceNotifications.permission != 'granted')
            _buildNotificationPermissionBanner(),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
        ],
      ),
    );
  }
}
