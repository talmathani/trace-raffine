import '../../../../domain/entities/auth_user.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../datasources/appwrite_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AppwriteAuthDataSource? dataSource})
    : _dataSource = dataSource ?? AppwriteAuthDataSource();

  final AppwriteAuthDataSource _dataSource;

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
    await _dataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = _dataSource.currentUser;

    if (user == null) {
      throw StateError('Appwrite returned an empty user after sign-in.');
    }

    return _mapUser(user);
  }

  @override
  Future<AuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = await _dataSource.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return _mapUser(user);
  }

  @override
  Future<void> sendEmailVerification() async {
    await _dataSource.sendEmailVerification(
      verificationUrl: 'https://trace-raffine.com/verify-email',
    );
  }

  @override
  Future<bool> reloadAndCheckEmailVerification() {
    return _dataSource.reloadAndCheckEmailVerification();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _dataSource.sendPasswordResetEmail(
      email: email,
      recoveryUrl: 'https://trace-raffine.com/reset-password',
    );
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  AuthUser _mapUser(dynamic user) {
    return AuthUser(
      id: user.$id as String,
      email: user.email as String?,
      emailVerified: user.emailVerification == true,
    );
  }
}
