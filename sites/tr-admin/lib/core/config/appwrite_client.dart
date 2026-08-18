import 'package:appwrite/appwrite.dart';

import 'appwrite_config.dart';

final class AppwriteClientFactory {
  const AppwriteClientFactory._();

  static Client create() {
    if (!AppwriteConfig.isConfigured) {
      throw StateError(
        'Appwrite configuration is incomplete. '
        'APPWRITE_PROJECT_ID and APPWRITE_ADMINS_TEAM_ID are required.',
      );
    }

    return Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId);
  }
}
