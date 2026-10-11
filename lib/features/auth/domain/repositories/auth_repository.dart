import '../entities/auth_user.dart';
import '../../../../domain/entities/user_role.dart';

abstract interface class AuthRepository {
  AuthUser? get currentUser;

  Future<AuthUser?> restoreSession();

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  });

  Future<void> signOut();

  Future<void> sendPasswordRecovery({
    required String email,
    required String redirectUrl,
  });

  Future<void> confirmPasswordRecovery({
    required String userId,
    required String secret,
    required String password,
  });

  Future<void> sendEmailVerification({required String redirectUrl});

  Future<AuthUser> refreshCurrentUser();

  Future<void> updatePassword({required String currentPassword, required String newPassword});

  Future<void> updatePhone({required String phone, required String password});
}
