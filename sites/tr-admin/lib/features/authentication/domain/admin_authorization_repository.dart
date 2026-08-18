import 'admin_access.dart';

abstract interface class AdminAuthorizationRepository {
  Future<AdminAccess> getCurrentAdminAccess({
    required String userId,
  });
}
