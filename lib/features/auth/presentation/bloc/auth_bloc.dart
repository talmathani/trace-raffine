import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/auth_user.dart';
import '../../../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this._authRepository}) : super(const AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
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

    if (!user.emailVerified) {
      emit(AuthEmailVerificationRequired(user));
      return;
    }

    emit(AuthAuthenticated(user));
  }
}
