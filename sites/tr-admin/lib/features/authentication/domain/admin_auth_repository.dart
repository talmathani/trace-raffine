import 'admin_auth_result.dart';

abstract interface class AdminAuthRepository {
  Future<AdminAuthResult> getCurrentSession();

  Future<AdminAuthResult> login({
    required String email,
    required String password,
  });

  Future<String?> requestPasswordRecovery({
    required String email,
    required String recoveryUrl,
  });
  Future<void> logout();
}

