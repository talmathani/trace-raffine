import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/auth_user.dart';
import '../../../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this._authRepository}) : super(const AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthEmailVerificationRequested>(_onEmailVerificationRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;

    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    emit(AuthAuthenticated(user));
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      emit(AuthAuthenticated(user));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(AuthFailure(_mapErrorMessage(error)));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      emit(AuthAuthenticated(user));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(AuthFailure(_mapErrorMessage(error)));
    }
  }

  Future<void> _onEmailVerificationRequested(
    AuthEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final verified = await _authRepository.reloadAndCheckEmailVerification();

      final user = _authRepository.currentUser;

      if (user == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      if (verified && user.emailVerified) {
        emit(AuthAuthenticated(user));
        return;
      }

      emit(AuthEmailVerificationRequired(user));
    } catch (error, stackTrace) {
      addError(error, stackTrace);

      final user = _authRepository.currentUser;

      if (user != null && !user.emailVerified) {
        emit(AuthEmailVerificationRequired(user));
      } else {
        emit(AuthFailure(_mapErrorMessage(error)));
      }
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(AuthFailure(_mapErrorMessage(error)));
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.sendPasswordResetEmail(email: event.email);

      emit(const AuthUnauthenticated());
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(AuthFailure(_mapErrorMessage(error)));
    }
  }

  String _mapErrorMessage(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('email-already-in-use')) {
      return 'هذا البريد الإلكتروني مستخدم بالفعل.';
    }

    if (message.contains('invalid-email')) {
      return 'صيغة البريد الإلكتروني غير صحيحة.';
    }

    if (message.contains('user-not-found')) {
      return 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني.';
    }

    if (message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }

    if (message.contains('weak-password')) {
      return 'كلمة المرور ضعيفة. استخدم كلمة مرور أقوى.';
    }

    if (message.contains('operation-not-allowed')) {
      return 'تسجيل الدخول بالبريد الإلكتروني غير مفعّل حالياً.';
    }

    if (message.contains('network-request-failed')) {
      return 'تعذر الاتصال بالخدمة. تحقق من الإنترنت.';
    }

    if (message.contains('too-many-requests')) {
      return 'تم تنفيذ محاولات كثيرة. انتظر قليلًا ثم حاول مرة أخرى.';
    }

    if (message.contains('user-disabled')) {
      return 'هذا الحساب معطل.';
    }

    return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
  }
}
