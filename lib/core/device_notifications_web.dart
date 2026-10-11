import 'dart:js_interop';

import 'package:web/web.dart' as web;

class DeviceNotifications {
  static bool get isSupported {
    try {
      return web.Notification.permission.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static String get permission {
    try {
      return web.Notification.permission;
    } catch (_) {
      return 'unsupported';
    }
  }

  static Future<String> requestPermission() async {
    return (await web.Notification.requestPermission().toDart).toDart;
  }

  static void show({
    required String title,
    required String body,
    required String tag,
  }) {
    web.Notification(
      title,
      web.NotificationOptions(body: body, tag: tag),
    );
  }
}
