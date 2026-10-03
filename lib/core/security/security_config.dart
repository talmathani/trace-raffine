class SecurityConfig {
  static const bool enableObfuscation = true;
  static const bool enableRootDetection = true;
  static const bool enableSSLPinning = true;
  static const bool enableJailbreakDetection = true;
  static const bool enableEmulatorDetection = true;

  static const List<String> allowedCertificates = [
    'fra.cloud.appwrite.io',
    'trace-raffine.com',
  ];

  static const Duration sessionTimeout = Duration(minutes: 30);
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
}
