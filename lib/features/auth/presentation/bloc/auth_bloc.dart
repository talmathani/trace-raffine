import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trace_raffine/core/security/security_service.dart';
import '../../domain/exceptions/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../profile/services/profile_session_service.dart';
import '../../services/remembered_login_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._authRepository,
    required this._profileSessionService,
    required this._securityService,
  }) : super(const AuthState.unknown()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSecurityLockRequested>(_onSecurityLockRequested);
    on<AuthPasswordRecoveryRequested>(_onPasswordRecoveryRequested);
    on<AuthPasswordRecoveryConfirmed>(_onPasswordRecoveryConfirmed);
  }

  final AuthRepository _authRepository;
  final ProfileSessionService _profileSessionService;
  final SecurityService _securityService;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    try {
      final user = await _authRepository.restoreSession();

      if (user == null) {
        emit(const AuthState.unauthenticated());
      } else {
        final profile = await _profileSessionService.loadCurrentProfile();
        if (profile == null) {
          emit(AuthState.authenticatedProfileMissing(user));
        } else if (profile.isCurrentlySuspended) {
          await _profileSessionService.clearPresence();
          await _authRepository.signOut();
          _profileSessionService.clear();
          emit(
            AuthState.failure(
              const AuthFailure(
                code: 'account_suspended',
                message: 'هذا الحساب موقوف حالياً.',
              ),
            ),
          );
        } else {
          emit(AuthState.authenticated(user));
        }
      }
    } on AuthFailure catch (failure) {
      emit(AuthState.failure(failure));
    } catch (error) {
      emit(
        AuthState.failure(
          AuthFailure(code: 'unknown', message: error.toString()),
        ),
      );
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      final profile = await _profileSessionService.loadCurrentProfile();
      if (profile == null) {
        emit(AuthState.authenticatedProfileMissing(user));
      } else if (profile.isCurrentlySuspended) {
        await _profileSessionService.clearPresence();
        await _authRepository.signOut();
        _profileSessionService.clear();
        emit(
          AuthState.failure(
            const AuthFailure(
              code: 'account_suspended',
              message: 'هذا الحساب موقوف حالياً.',
            ),
          ),
        );
      } else {
        emit(AuthState.authenticated(user));
      }
    } on AuthFailure catch (failure) {
      emit(AuthState.failure(failure));
    } catch (error) {
      emit(
        AuthState.failure(
          AuthFailure(
            code: 'login_failed',
            message: 'تعذر تسجيل الدخول حالياً.',
          ),
        ),
      );
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final user = await _authRepository.register(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
        role: event.role,
      );

      try {
        await _profileSessionService.createCurrentProfile(role: event.role);
      } catch (error) {
        try {
          await _authRepository.signOut();
        } catch (_) {}
        _profileSessionService.clear();
        throw AuthFailure(
          code: 'profile_creation_failed',
          message: 'تم إنشاء الحساب لكن تعذر إنشاء ملف الحساب. حاول مرة أخرى.',
        );
      }

      emit(AuthState.authenticated(user));
    } on AuthFailure catch (failure) {
      emit(AuthState.failure(failure));
    } catch (error) {
      emit(
        AuthState.failure(
          AuthFailure(
            code: 'registration_failed',
            message: 'تعذر إنشاء الحساب حالياً.',
          ),
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      await _profileSessionService.clearPresence();
      await _authRepository.signOut();
      _profileSessionService.clear();
      await RememberedLoginService.clearIfNotRemembered();
      emit(const AuthState.unauthenticated());
    } on AuthFailure catch (failure) {
      emit(AuthState.failure(failure));
    }
  }

  Future<void> _onSecurityLockRequested(
    AuthSecurityLockRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _securityService.lockSession(
        action: event.action,
        entity: event.entity,
        entityId: event.entityId,
        metadata: event.metadata,
      );
    } finally {
      _profileSessionService.clear();
      emit(const AuthState.securityLocked());
    }
  }

  Future<void> _onPasswordRecoveryRequested(
    AuthPasswordRecoveryRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      await _authRepository.sendPasswordRecovery(
        email: event.email,
        redirectUrl: event.redirectUrl,
      );

      emit(const AuthState.recoverySent());
    } on AuthFailure catch (failure) {
      emit(AuthState.failure(failure));
    }
  }

  Future<void> _onPasswordRecoveryConfirmed(
    AuthPasswordRecoveryConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      await _authRepository.confirmPasswordRecovery(
        userId: event.userId,
        secret: event.secret,
        password: event.password,
      );

      emit(const AuthState.recoveryConfirmed());
    } on AuthFailure catch (failure) {
      emit(AuthState.failure(failure));
    }
  }
}
