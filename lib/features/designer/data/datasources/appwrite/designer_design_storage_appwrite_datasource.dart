import 'package:flutter/foundation.dart';
import 'package:trace_raffine/core/storage/providers/storage_provider.dart';
import 'package:trace_raffine/core/storage/providers/appwrite_storage_provider.dart';

class DesignerDesignStorageAppwriteDataSource {
  final StorageProvider _storageProvider;

  DesignerDesignStorageAppwriteDataSource({StorageProvider? storageProvider})
    : _storageProvider = storageProvider ?? AppwriteStorageProvider();

  Future<String> uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    List<String>? permissions,
  }) async {
    return _storageProvider.uploadFile(
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
      permissions: permissions,
    );
  }

  String getFileView({required String fileId}) {
    return _storageProvider.getFileView(fileId: fileId);
  }

  Future<void> deleteFile({required String fileId}) {
    return _storageProvider.deleteFile(fileId: fileId);
  }
}
