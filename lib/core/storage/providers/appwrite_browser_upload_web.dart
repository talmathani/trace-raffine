import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

// Keep each browser upload request below 1 MiB so a failed request moves
// less data, while staying below Appwrite's 5 MiB maximum chunk size.
const int _appwriteChunkSize = 1024 * 1024;
// Appwrite's chunk endpoint uses a shared upload ID; serialize chunk requests
// to avoid overlapping writes/races that can fail intermittently in browsers.
const int _maxConcurrentChunks = 1;

Future<String> uploadFileWithBrowserProgress({
  required String endpoint,
  required String projectId,
  required String bucketId,
  required String fileId,
  required Uint8List bytes,
  required String fileName,
  required String contentType,
  required List<String> permissions,
  void Function(double progress)? onProgress,
  void Function(void Function()?)? onCancelAvailable,
}) async {
  if (bytes.isEmpty) {
    throw StateError('لا يمكن رفع ملف فارغ.');
  }

  var cancelled = false;
  var completedBytes = 0;
  var failed = false;
  final activeRequests = <web.XMLHttpRequest>{};
  final inFlightProgress = <int, double>{};

  void reportProgress() {
    final inFlightBytes = inFlightProgress.values.fold<double>(
      0,
      (total, value) => total + value,
    );
    onProgress?.call(
      ((completedBytes + inFlightBytes) / bytes.length).clamp(0.0, 0.99),
    );
  }

  void abortActiveRequests() {
    for (final request in activeRequests.toList()) {
      request.abort();
    }
  }

  void cancelUpload() {
    if (cancelled) return;
    cancelled = true;
    abortActiveRequests();
  }

  onCancelAvailable?.call(cancelUpload);

  Future<Map<String, dynamic>> sendChunk({
    required int start,
    required int end,
    required String? uploadId,
    required bool chunked,
  }) {
    if (cancelled) {
      return Future<Map<String, dynamic>>.error(
        StateError('تم إلغاء رفع التصميم.'),
      );
    }

    final completer = Completer<Map<String, dynamic>>();
    final request = web.XMLHttpRequest();
    activeRequests.add(request);
    final form = web.FormData();
    final chunkBytes = bytes.sublist(start, end);
    final blob = web.Blob(
      <JSAny>[chunkBytes.toJS].toJS,
      web.BlobPropertyBag(type: contentType),
    );

    form.append('fileId', fileId.toJS);
    form.append('file', blob, fileName);
    for (var index = 0; index < permissions.length; index++) {
      form.append('permissions[$index]', permissions[index].toJS);
    }

    request.open(
      'POST',
      '$endpoint/storage/buckets/${Uri.encodeComponent(bucketId)}/files',
    );
    request.withCredentials = true;
    request.timeout = 600000;
    request.setRequestHeader('X-Appwrite-Project', projectId);
    request.setRequestHeader('X-Appwrite-Response-Format', '2.3.0');
    request.setRequestHeader('Accept', 'application/json');
    if (chunked) {
      request.setRequestHeader(
        'Content-Range',
        'bytes $start-${end - 1}/${bytes.length}',
      );
      if (uploadId != null && uploadId.isNotEmpty) {
        request.setRequestHeader('X-Appwrite-ID', uploadId);
      }
    }

    try {
      final fallbackCookies = web.window.localStorage.getItem('cookieFallback');
      if (fallbackCookies != null && fallbackCookies.isNotEmpty) {
        request.setRequestHeader('X-Fallback-Cookies', fallbackCookies);
      }
    } catch (_) {
      // Browser storage may be blocked; session cookies can still be used.
    }

    request.upload.onprogress = ((web.ProgressEvent event) {
      if (!completer.isCompleted && event.lengthComputable && event.total > 0) {
        final fraction = (event.loaded.toDouble() / event.total.toDouble())
            .clamp(0.0, 1.0);
        inFlightProgress[start] = (end - start) * fraction;
        reportProgress();
      }
    }).toJS;

    request.onload = ((web.Event _) {
      if (completer.isCompleted) return;
      activeRequests.remove(request);
      inFlightProgress.remove(start);
      final status = request.status;
      final body = request.responseText;
      if (status >= 200 && status < 300) {
        try {
          final decoded = jsonDecode(body);
          final response = decoded is Map<String, dynamic>
              ? decoded
              : decoded is Map
              ? Map<String, dynamic>.from(decoded)
              : null;
          if (response != null && response[r'$id'] is String) {
            completedBytes += end - start;
            reportProgress();
            completer.complete(response);
          } else {
            completer.completeError(
              StateError('استجابة Appwrite لا تحتوي على معرّف الملف.'),
            );
          }
        } catch (error, stackTrace) {
          completer.completeError(error, stackTrace);
        }
        return;
      }

      var message = 'Appwrite أعاد HTTP $status.';
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['message'] is String) {
          message = 'Appwrite HTTP $status: ${decoded['message']}';
        }
      } catch (_) {
        if (body.trim().isNotEmpty) {
          message = 'Appwrite HTTP $status: ${body.trim()}';
        }
      }
      completer.completeError(StateError(message));
    }).toJS;

    request.onerror = ((web.Event _) {
      if (!completer.isCompleted) {
        activeRequests.remove(request);
        inFlightProgress.remove(start);
        completer.completeError(
          StateError(
            'فشل اتصال المتصفح بخدمة تخزين Appwrite أثناء رفع الجزء '
            '($start–$end من ${bytes.length} بايت). قد يكون السبب اتصالًا '
            'منقطعًا أو حجبًا من المتصفح/الشبكة.',
          ),
        );
      }
    }).toJS;

    request.ontimeout = ((web.Event _) {
      if (!completer.isCompleted) {
        activeRequests.remove(request);
        inFlightProgress.remove(start);
        completer.completeError(
          TimeoutException('انتهت مهلة رفع جزء الملف بعد 10 دقائق.'),
        );
      }
    }).toJS;

    request.onabort = ((web.Event _) {
      if (!completer.isCompleted) {
        activeRequests.remove(request);
        inFlightProgress.remove(start);
        completer.completeError(
          StateError(
            cancelled ? 'تم إلغاء رفع التصميم.' : 'توقف جزء من الرفع بعد فشل طلب آخر.',
          ),
        );
      }
    }).toJS;

    try {
      request.send(form);
    } catch (error, stackTrace) {
      activeRequests.remove(request);
      inFlightProgress.remove(start);
      completer.completeError(
        StateError(
          'تعذر بدء طلب رفع الملف إلى Appwrite '
          '(الجزء $start–$end من ${bytes.length} بايت): $error',
        ),
        stackTrace,
      );
    }
    return completer.future;
  }

  try {
    final chunked = bytes.length > _appwriteChunkSize;
    final firstEnd = math.min(_appwriteChunkSize, bytes.length);
    final firstResponse = await sendChunk(
      start: 0,
      end: firstEnd,
      uploadId: null,
      chunked: chunked,
    );
    final uploadId = firstResponse[r'$id'] as String;
    if (uploadId.isEmpty) {
      throw StateError('لم يُرجع Appwrite معرّف الملف بعد الرفع.');
    }

    if (firstEnd < bytes.length) {
      final starts = <int>[];
      for (var start = firstEnd; start < bytes.length; start += _appwriteChunkSize) {
        starts.add(start);
      }
      var nextChunk = 0;

      Future<void> uploadNext() async {
        while (nextChunk < starts.length && !cancelled && !failed) {
          final start = starts[nextChunk++];
          final end = math.min(start + _appwriteChunkSize, bytes.length);
          try {
            await sendChunk(
              start: start,
              end: end,
              uploadId: uploadId,
              chunked: true,
            );
          } catch (_) {
            failed = true;
            abortActiveRequests();
            rethrow;
          }
        }
      }

      final concurrency = math.min(_maxConcurrentChunks, starts.length);
      await Future.wait<void>(
        List<Future<void>>.generate(concurrency, (_) => uploadNext()),
      );
    }

    if (cancelled) throw StateError('تم إلغاء رفع التصميم.');
    onProgress?.call(1);
    return uploadId;
  } finally {
    onCancelAvailable?.call(null);
  }
}
