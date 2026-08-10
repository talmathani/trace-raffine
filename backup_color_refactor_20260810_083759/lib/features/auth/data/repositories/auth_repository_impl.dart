import '../../../../domain/entities/auth_user.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    FirebaseAuthDataSource? dataSource,
  }) : _dataSource = dataSource ?? FirebaseAuthDataSource();

  final FirebaseAuthDataSource _dataSource;

  @override
  Stream<AuthUser?> get authStateChanges =>
      _dataSource.authStateChanges.map(_mapUser);

  @override
  AuthUser? get currentUser {
    final user = _dataSource.currentUser;

    if (user == null) {
      return null;
    }

    return _mapUser(user);
  }

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _dataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw StateError(
        'Firebase returned an empty user after sign-in.',
      );
    }

    return _mapUser(user);
  }

  @override
  Future<AuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _dataSource.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw StateError(
        'Firebase returned an empty user after registration.',
      );
    }

    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }

    return _mapUser(user);
  }

  @override
  Future<void> sendEmailVerification() {
    return _dataSource.sendEmailVerification();
  }

  @override
  Future<bool> reloadAndCheckEmailVerification() {
    return _dataSource.reloadAndCheckEmailVerification();
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) {
    return _dataSource.sendPasswordResetEmail(
      email: email,
    );
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  AuthUser _mapUser(dynamic user) {
    return AuthUser(
      id: user.uid as String,
      email: user.email as String?,
      emailVerified: user.emailVerified as bool,
    );
  }
}
