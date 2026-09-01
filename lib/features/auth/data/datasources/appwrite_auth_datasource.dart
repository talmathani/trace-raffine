import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AppwriteAuthDataSource {
  AppwriteAuthDataSource({required Client client}) : _account = Account(client);

  final Account _account;

  Future<models.User> getCurrentUser() {
    return _account.get();
  }

  Future<models.User?> get currentUser async {
    try {
      return await _account.get();
    } on AppwriteException {
      return null;
    }
  }

  Future<models.Session> createEmailPasswordSession({
    required String email,
    required String password,
  }) {
    return _account.createEmailPasswordSession(
      email: email.trim(),
      password: password,
    );
  }

  Future<models.User> createUser({
    required String email,
    required String password,
  }) {
    return _account.create(
      userId: ID.unique(),
      email: email.trim(),
      password: password,
    );
  }

  Future<void> deleteCurrentSession() {
    return _account.deleteSession(sessionId: 'current');
  }

  Future<void> createRecovery({
    required String email,
    required String redirectUrl,
  }) {
    return _account.createRecovery(email: email.trim(), url: redirectUrl);
  }

  Future<void> updateRecovery({
    required String userId,
    required String secret,
    required String password,
  }) {
    return _account.updateRecovery(
      userId: userId,
      secret: secret,
      password: password,
    );
  }

  Future<void> createVerification({required String redirectUrl}) {
    return _account.createVerification(url: redirectUrl);
  }

  Future<void> updatePassword({required String password}) {
    return _account.updatePassword(password: password);
  }
}
