import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import 'appwrite_browser_upload_stub.dart'
    if (dart.library.js_interop) 'appwrite_browser_upload_web.dart'
    as browser_upload;
import '../../appwrite/appwrite_config.dart';
import '../../appwrite/appwrite_service.dart';
import 'appwrite_upload_diagnostics.dart';
import 'storage_provider.dart';

class AppwriteStorageProvider implements StorageProvider {
  final Storage _storage;
  final String _bucketId;

  AppwriteStorageProvider({Storage? storage, String? bucketId})
    : _storage = storage ?? AppwriteService.storage,
      _bucketId = bucketId ?? AppwriteConfig.designFilesBucketId;

  @override
  Future<String> uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    List<String>? permissions,
    void Function(double progress)? onProgress,
    void Function(void Function()?)? onCancelAvailable,
  }) async {
    final stopwatch = Stopwatch()..start();
    // Appwrite Web SDK does not emit onProgress for files at or below its
    // chunk size. Start explicitly, then report completion only after the
    // server confirms the file was created.
    onProgress?.call(0);
    try {
      if (kIsWeb) {
        // Appwrite's Flutter Web SDK uses a request without upload events for
        // files <= 5 MB, leaving the UI at 0% until the whole request returns.
        // Use browser XHR on web so progress reflects bytes actually sent.
        final fileId = await browser_upload.uploadFileWithBrowserProgress(
          endpoint: AppwriteConfig.endpoint,
          projectId: AppwriteConfig.projectId,
          bucketId: _bucketId,
          fileId: ID.unique(),
          bytes: bytes,
          fileName: fileName,
          contentType: contentType,
          permissions: permissions ?? const <String>[],
          onProgress: onProgress,
          onCancelAvailable: onCancelAvailable,
        );
        stopwatch.stop();
        debugPrint(
          'APPWRITE UPLOAD SUCCESS '
          'bucketId=$_bucketId bytes=${bytes.length} '
          'elapsedMs=${stopwatch.elapsedMilliseconds} fileId=$fileId',
        );
        return fileId;
      }

      final file = await _storage.createFile(
        bucketId: _bucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: bytes,
          filename: fileName,
          contentType: contentType,
        ),
        permissions: permissions ?? const <String>[],
        onProgress: (progress) {
          if (bytes.isEmpty) {
            onProgress?.call(0);
            return;
          }
          onProgress?.call(
            (progress.sizeUploaded / bytes.length).clamp(0.0, 1.0),
          );
        },
      );
      onProgress?.call(1);
      stopwatch.stop();
      debugPrint(
        'APPWRITE UPLOAD SUCCESS '
        'bucketId=$_bucketId bytes=${bytes.length} '
        'elapsedMs=${stopwatch.elapsedMilliseconds} fileId=${file.$id}',
      );
      return file.$id;
    } catch (error, stackTrace) {
      stopwatch.stop();
      AppwriteUploadDiagnostics.logFailure(
        error: error,
        elapsed: stopwatch.elapsed,
        bytes: bytes.length,
        contentType: contentType,
        bucketId: _bucketId,
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  @override
  String getFileView({required String fileId}) {
    return _storage
        .getFileDownload(bucketId: _bucketId, fileId: fileId)
        .toString();
  }

  @override
  Future<void> deleteFile({required String fileId}) async {
    await _storage.deleteFile(bucketId: _bucketId, fileId: fileId);
  }
}
