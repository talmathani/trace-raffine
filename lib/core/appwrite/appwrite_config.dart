import 'package:appwrite/appwrite.dart';

abstract final class AppwriteConfig {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';

  static const String projectId = 'trace-raffine';

  static Client createClient() {
    return Client()
      ..setEndpoint(endpoint)
      ..setProject(projectId);
  }
}
