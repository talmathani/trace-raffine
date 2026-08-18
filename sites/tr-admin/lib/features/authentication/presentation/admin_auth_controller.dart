import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/appwrite_admin_auth_repository.dart';
import '../data/appwrite_admin_authorization_repository.dart';
import '../domain/admin_access.dart';
import '../domain/admin_auth_repository.dart';
import '../domain/admin_auth_result.dart';
import '../domain/admin_authorization_repository.dart';
import 'admin_auth_state.dart';

final adminAuthRepositoryProvider =
    Provider<AdminAuthRepository>((ref) {
  return AppwriteAdminAuthRepository();
});

final adminAuthorizationRepositoryProvider =
    Provider<AdminAuthorizationRepository>((ref) {
  return AppwriteAdminAuthorizationRepository();
});

final adminAuthControllerProvider =
    NotifierProvider<AdminAuthController, AdminAuthState>(
  AdminAuthController.new,
);

final class AdminAuthController
    extends Notifier<AdminAuthState> {
  late final AdminAuthRepository _authRepository;
  late final AdminAuthorizationRepository _authorizationRepository;

  @override
  AdminAuthState build() {
    _authRepository = ref.read(
      adminAuthRepositoryProvider,
    );

    _authorizationRepository = ref.read(
      adminAuthorizationRepositoryProvider,
    );

    return const AdminAuthState.initial();
  }

  Future<void> restoreSession() async {
    state = state.copyWith(
      status: AdminAuthStatus.checkingSession,
      clearMessage: true,
    );

    final AdminAuthResult result =
        await _authRepository.getCurrentSession();

    if (!result.isAuthenticated || result.userId == null) {
      state = AdminAuthState(
        status: AdminAuthStatus.unauthenticated,
        user: result,
        message: result.errorMessage,
      );
      return;
    }

    await _authorize(result);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AdminAuthStatus.checkingSession,
      clearMessage: true,
    );

    final AdminAuthResult result =
        await _authRepository.login(
      email: email,
      password: password,
    );

    if (!result.isAuthenticated || result.userId == null) {
      state = AdminAuthState(
        status: AdminAuthStatus.unauthenticated,
        user: result,
        message: result.errorMessage,
      );
      return;
    }

    await _authorize(result);
  }

  Future<String?> requestPasswordRecovery({
    required String email,
    required String recoveryUrl,
  }) async {
    return _authRepository.requestPasswordRecovery(
      email: email,
      recoveryUrl: recoveryUrl,
    );
  }
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } finally {
      state = const AdminAuthState(
        status: AdminAuthStatus.unauthenticated,
      );
    }
  }

  Future<void> _authorize(
    AdminAuthResult result,
  ) async {
    try {
      final AdminAccess access =
          await _authorizationRepository.getCurrentAdminAccess(
        userId: result.userId!,
      );

      if (!access.isAdmin) {
        await _authRepository.logout();

        state = AdminAuthState(
          status: AdminAuthStatus.unauthorized,
          user: result,
          message:
              'This account is not a member of the Admins team.',
        );
        return;
      }

      state = AdminAuthState(
        status: AdminAuthStatus.authenticated,
        user: result,
        access: access,
      );
    } catch (error) {
      await _authRepository.logout();

      state = AdminAuthState(
        status: AdminAuthStatus.error,
        user: result,
        message:
            'Unable to verify administrator authorization.',
      );
    }
  }
}

