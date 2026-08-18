abstract final class AppwriteConfig {
  static const String endpoint =
      String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: 'https://fra.cloud.appwrite.io/v1',
  );

  static const String projectId =
      String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: 'trace-raffine',
  );

  static const String adminsTeamId =
      String.fromEnvironment(
    'APPWRITE_ADMINS_TEAM_ID',
    defaultValue: 'tr-admins',
  );

  static bool get isConfigured =>
      projectId.isNotEmpty &&
      adminsTeamId.isNotEmpty;
}
