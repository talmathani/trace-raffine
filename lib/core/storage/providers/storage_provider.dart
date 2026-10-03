import 'dart:typed_data';

abstract class StorageProvider {
  Future<String> uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    List<String>? permissions,
  });

  String getFileView({required String fileId});

  Future<void> deleteFile({required String fileId});
}
