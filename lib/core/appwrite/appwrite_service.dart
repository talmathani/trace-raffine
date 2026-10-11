import 'package:appwrite/appwrite.dart';

import 'appwrite_config.dart';

abstract final class AppwriteService {
  static late final Client client;
  static late final Account account;
  static late final Databases databases;
  static late final Storage storage;

  static void initialize() {
    client = AppwriteConfig.createClient();

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }
}
