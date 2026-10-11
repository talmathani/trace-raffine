import 'dart:typed_data';

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
}) {
  throw UnsupportedError('Browser upload transport is only available on web.');
}
