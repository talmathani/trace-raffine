import 'package:flutter/services.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

class SecurityDetectionService {
  SecurityDetectionService({required this._authBloc}) {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static const MethodChannel _channel = MethodChannel(
    'trace_raffine/security_detection',
  );

  final AuthBloc _authBloc;

  bool _lockRequested = false;

  Future<void> _handleMethodCall(MethodCall call) async {
    if (_lockRequested) {
      return;
    }

    switch (call.method) {
      case 'screenCaptureDetected':
        await _triggerSecurityLock(
          action: 'screen_capture_detected',
          metadata: _normalizeMetadata(call.arguments),
        );
        break;

      case 'screenRecordingDetected':
        await _triggerSecurityLock(
          action: 'screen_recording_detected',
          metadata: _normalizeMetadata(call.arguments),
        );
        break;
    }
  }

  Future<void> _triggerSecurityLock({
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    if (_lockRequested) {
      return;
    }

    _lockRequested = true;

    _authBloc.add(
      AuthSecurityLockRequested(
        action: action,
        entity: 'protected_content',
        metadata: metadata,
      ),
    );
  }

  Map<String, dynamic>? _normalizeMetadata(dynamic arguments) {
    if (arguments is! Map) {
      return null;
    }

    return arguments.map((key, value) => MapEntry(key.toString(), value));
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
  }
}
