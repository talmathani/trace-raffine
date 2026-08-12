import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import 'package:firebase_storage/firebase_storage.dart';

class DesignerDesignStorageDataSource {
  DesignerDesignStorageDataSource({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadFile({
    required Uint8List bytes,
    required String storagePath,
    required String contentType,
  }) async {
    debugPrint('=== STORAGE UPLOAD START ===');
    developer.log('Storage path: $storagePath');
    developer.log('Bytes: ${bytes.length}');
    developer.log('Content type: $contentType');

    final reference = _storage.ref().child(storagePath);

    debugPrint('Storage reference created.');

    final metadata = SettableMetadata(
      contentType: contentType,
    );

    debugPrint('Metadata created.');

    final uploadTask = reference.putData(
      bytes,
      metadata,
    );

    debugPrint('Storage upload task created.');

    uploadTask.snapshotEvents.listen(
      (TaskSnapshot snapshot) {
        debugPrint(
          'UPLOAD STATE: ${snapshot.state} | '
          '${snapshot.bytesTransferred}/${snapshot.totalBytes}',
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'UPLOAD STREAM ERROR: $error',
        );
      },
    );

    debugPrint('Waiting for upload task...');

    final snapshot = await uploadTask;

    developer.log(
      '=== STORAGE UPLOAD COMPLETE === '
      'state=${snapshot.state}',
    );

    debugPrint('Requesting download URL...');

    final downloadUrl = await snapshot.ref.getDownloadURL();

    debugPrint('=== DOWNLOAD URL RECEIVED ===');
    developer.log('Download URL length: ${downloadUrl.length}');

    return downloadUrl;
  }

  Future<void> deleteFile({
    required String storagePath,
  }) async {
    debugPrint('=== STORAGE DELETE START ===');
    developer.log('Storage path: $storagePath');

    final reference = _storage.ref().child(storagePath);

    try {
      await reference.delete();
      debugPrint('=== STORAGE DELETE COMPLETE ===');
    } on FirebaseException catch (error) {
      developer.log(
        'STORAGE DELETE ERROR: ${error.code} - ${error.message}',
      );

      if (error.code == 'object-not-found') {
        return;
      }

      rethrow;
    }
  }
}






