import 'package:appwrite/models.dart' as models;
import '../appwrite/appwrite_service.dart';

abstract final class CurrentUserService {
  static Future<models.User?> get currentUser async {
    try {
      return await AppwriteService.account.get();
    } on Exception {
      return null;
    }
  }

  static Future<String?> get userId async {
    final user = await currentUser;
    return user?.$id;
  }
}
