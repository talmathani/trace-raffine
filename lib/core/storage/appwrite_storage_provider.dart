import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';

import '../appwrite/appwrite_service.dart';
import '../appwrite/appwrite_storage_constants.dart';
import 'storage_provider.dart';

final class AppwriteStorageProvider implements StorageProvider {
  AppwriteStorageProvider({Storage? storage, Account? account})
    : _storage = storage ?? AppwriteService.storage,
      _account = account ?? AppwriteService.account;

  final Storage _storage;
  final Account _account;

  @override
  Future<String> uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    List<String>? permissions,
  }) async {
    await _account.get();

    final file = await _storage.createFile(
      bucketId: AppwriteStorageConstants.designsBucketId,
      fileId: ID.unique(),
      file: InputFile.fromBytes(
        bytes: bytes,
        filename: fileName,
        contentType: contentType,
      ),
      permissions: permissions,
    );

    return file.$id;
  }

  @override
  String getFileView({required String fileId}) {
    return 'https://fra.cloud.appwrite.io/v1/storage/buckets/'
        '${AppwriteStorageConstants.designsBucketId}/files/$fileId/view'
        '?project=trace-raffine';
  }

  @override
  Future<void> deleteFile({required String fileId}) {
    return _storage.deleteFile(
      bucketId: AppwriteStorageConstants.designsBucketId,
      fileId: fileId,
    );
  }
}
