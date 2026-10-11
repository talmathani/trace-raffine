import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class RecoveryLink {
  const RecoveryLink({required this.userId, required this.secret});

  final String userId;
  final String secret;

  static RecoveryLink? fromUri(Uri uri) {
    final path = uri.path.toLowerCase();
    final host = uri.host.toLowerCase();
    final isRecoveryPath =
        path == '/reset-password' ||
        path == '/recovery' ||
        path.endsWith('/reset-password') ||
        path.endsWith('/recovery') ||
        host == 'reset-password' ||
        host == 'recovery';

    final userId = uri.queryParameters['userId']?.trim();
    final secret = uri.queryParameters['secret']?.trim();

    if (!isRecoveryPath ||
        userId == null ||
        userId.isEmpty ||
        secret == null ||
        secret.isEmpty) {
      return null;
    }

    return RecoveryLink(userId: userId, secret: secret);
  }
}

class AppDeepLinkService {
  AppDeepLinkService._();

  static final AppDeepLinkService instance = AppDeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  final StreamController<RecoveryLink> _recoveryController =
      StreamController<RecoveryLink>.broadcast();

  StreamSubscription<Uri>? _subscription;
  RecoveryLink? _pendingRecovery;
  bool _initialized = false;

  RecoveryLink? get pendingRecovery => _pendingRecovery;

  Stream<RecoveryLink> get recoveryLinks => _recoveryController.stream;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    // On web, the browser URL is the authoritative deep-link source.
    // Avoid subscribing to the native app-links stream on web.
    if (kIsWeb) {
      _handleUri(Uri.base);
      return;
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Deep link error: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _handleUri(initial);
      }
    } catch (error, stackTrace) {
      debugPrint('Initial deep link error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _handleUri(Uri uri) {
    final recovery = RecoveryLink.fromUri(uri);
    if (recovery == null) {
      return;
    }

    _pendingRecovery = recovery;
    _recoveryController.add(recovery);
  }

  void consumeRecovery() {
    _pendingRecovery = null;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _recoveryController.close();
  }
}
