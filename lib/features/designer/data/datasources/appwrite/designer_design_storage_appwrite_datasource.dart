import 'package:flutter/foundation.dart';

import '../../../../../core/storage/appwrite_storage_provider.dart';
import '../../../../../core/storage/storage_provider.dart';

class DesignerDesignStorageAppwriteDataSource {
  DesignerDesignStorageAppwriteDataSource({StorageProvider? storageProvider})
    : _storageProvider = storageProvider ?? AppwriteStorageProvider();

  final StorageProvider _storageProvider;

  Future<String> uploadFile({
    required Uint8List bytes,
    required String storagePath,
    required String contentType,
    List<String>? permissions,
  }) async {
    debugPrint('=== STORAGE PROVIDER UPLOAD REQUEST ===');
    debugPrint('FILE NAME: ${storagePath.split('/').last}');
    debugPrint('STORAGE PATH: $storagePath');
    debugPrint('CONTENT TYPE: $contentType');
    debugPrint('FILE SIZE BYTES: ${bytes.length}');
    debugPrint('PERMISSIONS: $permissions');

    try {
      final fileId = await _storageProvider.uploadFile(
        bytes: bytes,
        fileName: storagePath.split('/').last,
        contentType: contentType,
        permissions: permissions,
      );

      debugPrint('=== STORAGE PROVIDER UPLOAD SUCCESS ===');
      debugPrint('FILE ID: $fileId');

      return fileId;
    } catch (error, stackTrace) {
      debugPrint('=== STORAGE PROVIDER UPLOAD ERROR ===');
      debugPrint('ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  String getFileView({required String fileId}) {
    return _storageProvider.getFileView(fileId: fileId);
  }

  Future<void> deleteFile({required String fileId}) {
    return _storageProvider.deleteFile(fileId: fileId);
  }
}
