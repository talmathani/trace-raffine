import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/exceptions/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../profile/services/profile_session_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._authRepository,
    required this._profileSessionService,
  }) : super(const AuthState.unknown()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordRecoveryRequested>(_onPasswordRecoveryRequested);
    on<AuthPasswordRecoveryConfirmed>(_onPasswordRecoveryConfirmed);
  }

  final AuthRepository _authRepository;
  final ProfileSessionService _profileSessionService;

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
      } else {
        emit(AuthState.authenticated(user));
      }
    } on AuthFailure catch (failure) {
      emit(AuthState.failure(failure));
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
      );

      await _profileSessionService.createCurrentProfile(role: event.role);

      emit(AuthState.authenticated(user));
    } on AuthFailure catch (failure) {
      emit(AuthState.failure(failure));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      await _authRepository.signOut();
      _profileSessionService.clear();
      emit(const AuthState.unauthenticated());
    } on AuthFailure catch (failure) {
      emit(AuthState.failure(failure));
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
