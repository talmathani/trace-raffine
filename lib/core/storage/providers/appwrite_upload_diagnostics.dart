import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

abstract final class AppwriteUploadDiagnostics {
  static const int _maxLogChars = 1000;

  static void logFailure({
    required Object error,
    required Duration elapsed,
    required int bytes,
    required String contentType,
    required String bucketId,
  }) {
    final appwriteError = error is AppwriteException ? error : null;
    final sdkMessage = appwriteError?.message;
    final message = sdkMessage != null && sdkMessage.trim().isNotEmpty
        ? sdkMessage
        : error.toString();
    final response = appwriteError?.response;

    debugPrint(
      'APPWRITE UPLOAD FAILED '
      'bucketId=$bucketId bytes=$bytes contentType=$contentType '
      'elapsedMs=${elapsed.inMilliseconds} '
      'kind=${_kindOf(error, message)} '
      'exception=${error.runtimeType} '
      'httpCode=${appwriteError?.code ?? 'unavailable'} '
      'appwriteType=${_safeText(appwriteError?.type ?? 'unavailable')} '
      'response=${_safeResponse(response)} '
      'message=${_safeText(message)}',
    );
  }

  static String _kindOf(Object error, String message) {
    if (error is AppwriteException && error.code != null) {
      return 'appwrite_http';
    }

    final normalized = message.toLowerCase();
    if (error is TimeoutException ||
        normalized.contains('timeoutexception') ||
        normalized.contains('timed out')) {
      return 'timeout';
    }

    // Appwrite Flutter Web wraps package:http ClientException in an
    // AppwriteException without an HTTP status or response body.
    if (normalized.contains('clientexception') ||
        normalized.contains('failed to fetch') ||
        normalized.contains('socketexception')) {
      return 'transport_or_browser';
    }

    if (error is AppwriteException) {
      return 'appwrite_sdk_or_response';
    }
    return 'unexpected_or_transport';
  }

  static String _safeResponse(String? response) {
    if (response == null || response.trim().isEmpty) {
      return 'unavailable';
    }

    final trimmed = response.trim();
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        // Appwrite error responses use these fields. Whitelisting them avoids
        // accidentally logging credentials or unrelated response data.
        final safe = <String, Object?>{};
        for (final key in const ['message', 'code', 'type', 'version']) {
          if (decoded.containsKey(key)) {
            final value = decoded[key];
            safe[key] = value is String ? _safeText(value) : value;
          }
        }
        return _bounded(jsonEncode(safe));
      }
    } on FormatException {
      // Non-JSON bodies are sanitized and length-limited below.
    }

    return _safeText(trimmed);
  }

  static String _safeText(String value) {
    final redacted = value.replaceAll(
      RegExp(
        r'((?:set-cookie|cookie|authorization|x-appwrite-(?:key|session|jwt)|api[_-]?key|password|secret|(?:access|refresh)?_?token)\s*[:=]\s*)[^,\s;]+',
        caseSensitive: false,
      ),
      r'$1[REDACTED]',
    );
    return _bounded(redacted.replaceAll(RegExp(r'[\r\n]+'), ' '));
  }

  static String _bounded(String value) {
    if (value.length <= _maxLogChars) return value;
    return '${value.substring(0, _maxLogChars)}…[truncated]';
  }
}
