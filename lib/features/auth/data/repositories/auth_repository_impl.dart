import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../../domain/entities/auth_user.dart';
import '../../domain/exceptions/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/appwrite_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this._dataSource});

  final AppwriteAuthDataSource _dataSource;

  AuthUser? _currentUser;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser?> restoreSession() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return _setCurrentUser(user);
    } on AppwriteException catch (error) {
      if (error.code == 401) {
        _currentUser = null;
        return null;
      }

      throw AuthFailure(
        message: error.message ?? 'Unable to restore session.',
        code: error.type ?? 'session_restore_failed',
      );
    } catch (error) {
      throw AuthFailure(
        message: error.toString(),
        code: 'session_restore_failed',
      );
    }
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      try {
        await _dataSource.deleteCurrentSession();
      } on AppwriteException catch (error) {
        if (error.code != 401) {
          rethrow;
        }
      }

      await _dataSource.createEmailPasswordSession(
        email: email.trim(),
        password: password,
      );

      final user = await _dataSource.getCurrentUser();
      return _setCurrentUser(user);
    } on AppwriteException catch (error) {
      throw AuthFailure(
        message: error.message ?? 'Login failed.',
        code: error.type ?? 'login_failed',
      );
    } catch (error) {
      throw AuthFailure(
        message: error.toString(),
        code: 'login_failed',
      );
    }
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    try {
      await _dataSource.createUser(email: email, password: password);

      await _dataSource.createEmailPasswordSession(
        email: email,
        password: password,
      );

      final user = await _dataSource.getCurrentUser();
      return _setCurrentUser(user);
    } on AppwriteException catch (error) {
      throw AuthFailure(
        message: error.message ?? 'Registration failed.',
        code: error.type ?? 'registration_failed',
      );
    } catch (error) {
      throw AuthFailure(message: error.toString(), code: 'registration_failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.deleteCurrentSession();
      _currentUser = null;
    } on AppwriteException catch (error) {
      throw AuthFailure(
        message: error.message ?? 'Logout failed.',
        code: error.type ?? 'logout_failed',
      );
    } catch (error) {
      throw AuthFailure(message: error.toString(), code: 'logout_failed');
    }
  }

  @override
  Future<void> sendPasswordRecovery({
    required String email,
    required String redirectUrl,
  }) async {
    try {
      await _dataSource.createRecovery(email: email, redirectUrl: redirectUrl);
    } on AppwriteException catch (error) {
      throw AuthFailure(
        message: error.message ?? 'Password recovery failed.',
        code: error.type ?? 'recovery_failed',
      );
    } catch (error) {
      throw AuthFailure(message: error.toString(), code: 'recovery_failed');
    }
  }

  @override
  Future<void> confirmPasswordRecovery({
    required String userId,
    required String secret,
    required String password,
  }) async {
    try {
      await _dataSource.updateRecovery(
        userId: userId,
        secret: secret,
        password: password,
      );
    } on AppwriteException catch (error) {
      throw AuthFailure(
        message: error.message ?? 'Password reset failed.',
        code: error.type ?? 'password_reset_failed',
      );
    } catch (error) {
      throw AuthFailure(
        message: error.toString(),
        code: 'password_reset_failed',
      );
    }
  }

  @override
  Future<void> sendEmailVerification({required String redirectUrl}) async {
    try {
      await _dataSource.createVerification(redirectUrl: redirectUrl);
    } on AppwriteException catch (error) {
      throw AuthFailure(
        message: error.message ?? 'Email verification failed.',
        code: error.type ?? 'verification_failed',
      );
    } catch (error) {
      throw AuthFailure(message: error.toString(), code: 'verification_failed');
    }
  }

  @override
  Future<AuthUser> refreshCurrentUser() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return _setCurrentUser(user);
    } on AppwriteException catch (error) {
      throw AuthFailure(
        message: error.message ?? 'Unable to refresh user.',
        code: error.type ?? 'refresh_failed',
      );
    } catch (error) {
      throw AuthFailure(message: error.toString(), code: 'refresh_failed');
    }
  }

  @override
  Future<void> updatePassword({required String password}) async {
    try {
      await _dataSource.updatePassword(password: password);

      await refreshCurrentUser();
    } on AuthFailure {
      rethrow;
    } on AppwriteException catch (error) {
      throw AuthFailure(
        message: error.message ?? 'Password update failed.',
        code: error.type ?? 'password_update_failed',
      );
    } catch (error) {
      throw AuthFailure(
        message: error.toString(),
        code: 'password_update_failed',
      );
    }
  }

  AuthUser _setCurrentUser(models.User user) {
    final authUser = AuthUser(
      id: user.$id,
      email: user.email,
      emailVerified: user.emailVerification,
    );

    _currentUser = authUser;
    return authUser;
  }
}

