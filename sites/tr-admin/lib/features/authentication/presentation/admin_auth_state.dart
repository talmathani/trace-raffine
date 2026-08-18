import '../domain/admin_access.dart';
import '../domain/admin_auth_result.dart';

enum AdminAuthStatus {
  initial,
  checkingSession,
  authenticated,
  unauthenticated,
  unauthorized,
  error,
}

final class AdminAuthState {
  const AdminAuthState({
    required this.status,
    this.user,
    this.access,
    this.message,
  });

  const AdminAuthState.initial()
      : this(
          status: AdminAuthStatus.initial,
        );

  final AdminAuthStatus status;
  final AdminAuthResult? user;
  final AdminAccess? access;
  final String? message;

  bool get isLoading =>
      status == AdminAuthStatus.checkingSession;

  bool get isAuthenticated =>
      status == AdminAuthStatus.authenticated;

  bool get isUnauthorized =>
      status == AdminAuthStatus.unauthorized;

  AdminAuthState copyWith({
    AdminAuthStatus? status,
    AdminAuthResult? user,
    AdminAccess? access,
    String? message,
    bool clearUser = false,
    bool clearAccess = false,
    bool clearMessage = false,
  }) {
    return AdminAuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      access: clearAccess ? null : (access ?? this.access),
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
