import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/exceptions/auth_failure.dart';

enum AuthStatus {
  unknown,
  loading,
  unauthenticated,
  authenticated,
  /// Auth session is valid but no UserProfile document exists in the database.
  /// The user is NOT logged out — they are authenticated but incomplete.
  authenticatedProfileMissing,
  failure,
  recoverySent,
  recoveryConfirmed,
}

class AuthState extends Equatable {
  const AuthState({required this.status, this.user, this.failure});

  const AuthState.unknown()
    : status = AuthStatus.unknown,
      user = null,
      failure = null;

  const AuthState.loading()
    : status = AuthStatus.loading,
      user = null,
      failure = null;

  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      user = null,
      failure = null;

  const AuthState.authenticated(AuthUser value)
    : status = AuthStatus.authenticated,
      user = value,
      failure = null;

  /// Auth session is valid but the Profile document was not found in Appwrite.
  const AuthState.authenticatedProfileMissing(AuthUser value)
    : status = AuthStatus.authenticatedProfileMissing,
      user = value,
      failure = null;

  const AuthState.failure(AuthFailure value)
    : status = AuthStatus.failure,
      user = null,
      failure = value;

  const AuthState.recoverySent()
    : status = AuthStatus.recoverySent,
      user = null,
      failure = null;

  const AuthState.recoveryConfirmed()
    : status = AuthStatus.recoveryConfirmed,
      user = null,
      failure = null;

  final AuthStatus status;
  final AuthUser? user;
  final AuthFailure? failure;

  @override
  List<Object?> get props => [status, user, failure];
}
