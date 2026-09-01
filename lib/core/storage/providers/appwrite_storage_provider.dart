import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import '../../appwrite/appwrite_config.dart';
import '../../appwrite/appwrite_service.dart';
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
  }) async {
    final file = await _storage.createFile(
      bucketId: _bucketId,
      fileId: ID.unique(),
      file: InputFile.fromBytes(
        bytes: bytes,
        filename: fileName,
        contentType: contentType,
      ),
      permissions: permissions ?? [
        Permission.read(Role.any()),
        Permission.read(Role.users()),
      ],
    );
    return file.$id;
  }

  @override
  String getFileView({required String fileId}) {
    return _storage.getFileDownload(bucketId: _bucketId, fileId: fileId).toString();
  }

  @override
  Future<void> deleteFile({required String fileId}) async {
    await _storage.deleteFile(bucketId: _bucketId, fileId: fileId);
  }
}
