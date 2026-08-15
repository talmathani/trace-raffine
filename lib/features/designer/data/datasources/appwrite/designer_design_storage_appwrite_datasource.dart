import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import '../../../../../core/appwrite/appwrite_service.dart';
import '../../../../../core/appwrite/appwrite_storage_constants.dart';

class DesignerDesignStorageAppwriteDataSource {
  DesignerDesignStorageAppwriteDataSource({Storage? storage})
    : _storage = storage ?? AppwriteService.storage;

  final Storage _storage;

  Future<String> uploadFile({
    required Uint8List bytes,
    required String storagePath,
    required String contentType,
    List<String>? permissions,
  }) async {
    debugPrint('=== APPWRITE STORAGE UPLOAD REQUEST ===');
    debugPrint('BUCKET: ${AppwriteStorageConstants.designsBucketId}');
    debugPrint('FILE NAME: ${storagePath.split('/').last}');
    debugPrint('STORAGE PATH: $storagePath');
    debugPrint('CONTENT TYPE: $contentType');
    debugPrint('FILE SIZE BYTES: ${bytes.length}');
    debugPrint('PERMISSIONS: $permissions');

    try {
      final appwriteUser = await AppwriteService.account.get();

      debugPrint('=== APPWRITE LIVE SESSION CHECK ===');
      debugPrint('APPWRITE USER ID: ${appwriteUser.$id}');
      debugPrint('APPWRITE USER EMAIL: ${appwriteUser.email}');
      debugPrint(
        'APPWRITE EMAIL VERIFIED: ${appwriteUser.emailVerification}',
      );

      final file = await _storage.createFile(
        bucketId: AppwriteStorageConstants.designsBucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: bytes,
          filename: storagePath.split('/').last,
          contentType: contentType,
        ),
        permissions: permissions,
      );

      debugPrint('=== APPWRITE STORAGE CREATEFILE SUCCESS ===');
      debugPrint('FILE ID: ${file.$id}');
      debugPrint('FILE PERMISSIONS: ${file.$permissions}');

      return file.$id;
    } on AppwriteException catch (error, stackTrace) {
      debugPrint('=== APPWRITE STORAGE CREATEFILE ERROR ===');
      debugPrint('CODE: ${error.code}');
      debugPrint('TYPE: ${error.type}');
      debugPrint('MESSAGE: ${error.message}');
      debugPrint('RESPONSE: ${error.response}');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('=== APPWRITE STORAGE UNKNOWN ERROR ===');
      debugPrint('ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  String getFileView({required String fileId}) {
    return 'https://fra.cloud.appwrite.io/v1/storage/buckets/'
        '${AppwriteStorageConstants.designsBucketId}/files/$fileId/view'
        '?project=trace-raffine';
  }

  Future<void> deleteFile({required String fileId}) async {
    await _storage.deleteFile(
      bucketId: AppwriteStorageConstants.designsBucketId,
      fileId: fileId,
    );
  }
}
