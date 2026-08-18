import 'package:appwrite/appwrite.dart';

import 'appwrite_client.dart';

final class AppwriteServices {
  AppwriteServices._();

  static final Client client = AppwriteClientFactory.create();

  static final Account account = Account(client);

  static final Databases databases = Databases(client);

  static final Storage storage = Storage(client);

  static final Teams teams = Teams(client);
}
