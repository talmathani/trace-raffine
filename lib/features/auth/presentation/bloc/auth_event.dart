import 'package:equatable/equatable.dart';

import '../../../../domain/entities/user_role.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.role,
  });

  final String email;
  final String password;
  final String name;
  final String phone;
  final UserRole role;

  @override
  List<Object?> get props => [email, password, name, phone, role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthSecurityLockRequested extends AuthEvent {
  const AuthSecurityLockRequested({
    required this.action,
    this.entity,
    this.entityId,
    this.metadata,
  });

  final String action;
  final String? entity;
  final String? entityId;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [action, entity, entityId, metadata];
}

class AuthPasswordRecoveryRequested extends AuthEvent {
  const AuthPasswordRecoveryRequested({
    required this.email,
    required this.redirectUrl,
  });

  final String email;
  final String redirectUrl;

  @override
  List<Object?> get props => [email, redirectUrl];
}

class AuthPasswordRecoveryConfirmed extends AuthEvent {
  const AuthPasswordRecoveryConfirmed({
    required this.userId,
    required this.secret,
    required this.password,
  });

  final String userId;
  final String secret;
  final String password;

  @override
  List<Object?> get props => [userId, secret, password];
}
