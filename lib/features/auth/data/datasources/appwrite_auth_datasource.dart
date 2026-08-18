import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

import '../../../../core/appwrite/appwrite_service.dart';
import '../../../../domain/exceptions/auth_exception.dart';

class AppwriteAuthDataSource {
  AppwriteAuthDataSource({Account? account})
    : _account = account ?? AppwriteService.account {
    _initializeAuthState();
  }

  final Account _account;

  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  User? _currentUser;

  Stream<User?> get authStateChanges => _authStateController.stream;

  User? get currentUser => _currentUser;

  Future<void> _initializeAuthState() async {
    try {
      debugPrint('AUTH DEBUG: initializing auth state...');

      final user = await _account.get();

      debugPrint('AUTH DEBUG: existing session found for user ${user.$id}');

      _currentUser = user;
      _authStateController.add(user);
    } on AppwriteException {
      _currentUser = null;
      _authStateController.add(null);
    } catch (_) {
      _currentUser = null;
      _authStateController.add(null);
    }
  }

  Future<Session> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AUTH DEBUG: checking current session...');

      try {
        final currentSession =
            await _account.getSession(sessionId: 'current');

        debugPrint(
          'AUTH DEBUG: existing session found: ${currentSession.$id}',
        );

        await _account.deleteSession(sessionId: 'current');

        _currentUser = null;
        _authStateController.add(null);

        debugPrint('AUTH DEBUG: previous session deleted successfully.');
      } on AppwriteException catch (e) {
        if (e.type != 'user_session_not_found') {
          debugPrint(
            'AUTH DEBUG: current session check returned '
            'code=${e.code}, type=${e.type}, message=${e.message}',
          );
        }
      }

      debugPrint('AUTH DEBUG: creating email/password session...');

      final session = await _account
          .createEmailPasswordSession(
            email: email.trim(),
            password: password,
          )
          .timeout(const Duration(seconds: 15));

      debugPrint(
        'AUTH DEBUG: session created successfully: ${session.$id}',
      );

      final user = await _account.get();

      debugPrint(
        'AUTH DEBUG: Account.get() succeeded for user ${user.$id}',
      );

      _currentUser = user;
      _authStateController.add(user);

      return session;
    } on AppwriteException catch (e) {
      debugPrint(
        'AUTH DEBUG: LOGIN EXCEPTION '
        'code=${e.code}, '
        'type=${e.type}, '
        'message=${e.message}',
      );

      throw AuthException(
        message: e.message ?? 'تعذر تسجيل الدخول.',
        code: e.type,
      );
    }
  }

  Future<User> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email.trim(),
        password: password,
      );

      final session = await _account
          .createEmailPasswordSession(email: email.trim(), password: password)
          .timeout(const Duration(seconds: 15));

      if (session.$id.isEmpty) {
        throw StateError(
          'Appwrite returned an empty session after registration.',
        );
      }

      _currentUser = await _account.get();
      _authStateController.add(_currentUser);

      return user;
    } on AppwriteException catch (e) {
      if (e.type == 'user_already_exists') {
        throw StateError('هذا البريد مستخدم مسبقاً.');
      }

      rethrow;
    }
  }

  Future<void> sendEmailVerification({required String verificationUrl}) async {
    final user = _currentUser ?? await _account.get();

    if (user.emailVerification == true) {
      return;
    }

    await _account.createVerification(url: verificationUrl);
  }

  Future<bool> reloadAndCheckEmailVerification() async {
    debugPrint('AUTH DEBUG: reloading account for email verification...');

    final user = await _account.get();

    debugPrint(
      'AUTH DEBUG: Account.get() verification state: '
      '${user.emailVerification}',
    );

    _currentUser = user;
    _authStateController.add(user);

    return user.emailVerification == true;
  }

  Future<void> sendPasswordResetEmail({
    required String email,
    required String recoveryUrl,
  }) {
    return _account.createRecovery(email: email.trim(), url: recoveryUrl);
  }

  Future<void> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } finally {
      _currentUser = null;
      _authStateController.add(null);
    }
  }

  Future<void> dispose() async {
    await _authStateController.close();
  }
}
