import 'package:appwrite/appwrite.dart';

import '../../../core/config/appwrite_services.dart';
import '../domain/admin_auth_result.dart';
import '../domain/admin_auth_repository.dart';

final class AppwriteAdminAuthRepository
    implements AdminAuthRepository {
  AppwriteAdminAuthRepository({
    Account? account,
  }) : _account = account ?? AppwriteServices.account;

  final Account _account;

  @override
  Future<AdminAuthResult> getCurrentSession() async {
    try {
      final user = await _account.get();

      return AdminAuthResult.authenticated(
        userId: user.$id,
        email: user.email,
        name: user.name,
      );
    } on AppwriteException {
      return const AdminAuthResult.unauthenticated();
    } catch (_) {
      return const AdminAuthResult.unauthenticated(
        errorMessage: 'Unable to verify the current session.',
      );
    }
  }

  @override
  Future<AdminAuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      final user = await _account.get();

      return AdminAuthResult.authenticated(
        userId: user.$id,
        email: user.email,
        name: user.name,
      );
    } on AppwriteException catch (error) {
      return AdminAuthResult.unauthenticated(
        errorMessage: error.message ?? 'Authentication failed.',
      );
    } catch (_) {
      return const AdminAuthResult.unauthenticated(
        errorMessage: 'Authentication failed.',
      );
    }
  }

  @override
  Future<String?> requestPasswordRecovery({
    required String email,
    required String recoveryUrl,
  }) async {
    try {
      await _account.createRecovery(
        email: email.trim(),
        url: recoveryUrl,
      );

      return null;
    } on AppwriteException catch (error) {
      return error.message ?? 'Unable to start account recovery.';
    } catch (_) {
      return 'Unable to start account recovery.';
    }
  }
  @override
  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }
}


