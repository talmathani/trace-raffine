class DeviceNotifications {
  static bool get isSupported => false;
  static String get permission => 'unsupported';

  static Future<String> requestPermission() async => 'unsupported';

  static void show({
    required String title,
    required String body,
    required String tag,
  }) {}
}
