import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  AuthUser? get currentUser;

  Future<AuthUser?> restoreSession();

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> register({required String email, required String password});

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

  Future<void> updatePassword({required String password});
}
