import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class DesignerDesignStorageDataSource {
  DesignerDesignStorageDataSource({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  static const Duration _uploadTimeout = Duration(minutes: 3);

  Future<String> uploadFile({
    required Uint8List bytes,
    required String storagePath,
    required String contentType,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError('Cannot upload an empty file.');
    }

    debugPrint('=== STORAGE UPLOAD START ===');
    developer.log('Storage path: $storagePath');
    developer.log('Bytes: ${bytes.length}');
    developer.log('Content type: $contentType');

    final reference = _storage.ref().child(storagePath);

    final metadata = SettableMetadata(
      contentType: contentType,
    );

    debugPrint('Creating Firebase Storage upload task...');

    final uploadTask = reference.putData(
      bytes,
      metadata,
    );

    debugPrint('Storage upload task created.');

    final subscription = uploadTask.snapshotEvents.listen(
      (TaskSnapshot snapshot) {
        final total = snapshot.totalBytes;
        final transferred = snapshot.bytesTransferred;

        final percentage = total > 0
            ? (transferred / total * 100).toStringAsFixed(1)
            : '0.0';

        debugPrint(
          'UPLOAD STATE: ${snapshot.state} | '
          '$transferred/$total bytes | $percentage%',
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('UPLOAD STREAM ERROR: $error');

        developer.log(
          'UPLOAD STREAM ERROR',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    try {
      debugPrint('Waiting for Firebase Storage upload...');

      final snapshot = await uploadTask.timeout(
        _uploadTimeout,
        onTimeout: () {
          throw TimeoutException(
            'Firebase Storage upload timed out after '
            '${_uploadTimeout.inMinutes} minutes.',
          );
        },
      );

      debugPrint(
        '=== STORAGE UPLOAD COMPLETE === '
        'state=${snapshot.state} '
        'bytes=${snapshot.bytesTransferred}/${snapshot.totalBytes}',
      );

      if (snapshot.state != TaskState.success) {
        throw FirebaseException(
          plugin: 'firebase_storage',
          code: 'upload-failed',
          message:
              'Firebase Storage upload finished with state '
              '${snapshot.state}.',
        );
      }

      debugPrint('Requesting download URL...');

      final downloadUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
            'Timed out while requesting the Firebase Storage download URL.',
          );
        },
      );

      debugPrint('=== DOWNLOAD URL RECEIVED ===');
      developer.log('Download URL length: ${downloadUrl.length}');

      return downloadUrl;
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('=== STORAGE UPLOAD TIMEOUT ===');
      debugPrint(error.toString());

      developer.log(
        'STORAGE UPLOAD TIMEOUT',
        error: error,
        stackTrace: stackTrace,
      );

      try {
        await uploadTask.cancel();
      } catch (_) {
        // Ignore cancellation errors.
      }

      rethrow;
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        '=== STORAGE UPLOAD FIREBASE ERROR === '
        '${error.code}: ${error.message}',
      );

      developer.log(
        'STORAGE UPLOAD FIREBASE ERROR',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } catch (error, stackTrace) {
      debugPrint('=== STORAGE UPLOAD ERROR ===');
      debugPrint(error.toString());

      developer.log(
        'STORAGE UPLOAD ERROR',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      await subscription.cancel();
      debugPrint('Storage upload listener disposed.');
    }
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
    } on FirebaseException catch (error, stackTrace) {
      developer.log(
        'STORAGE DELETE ERROR: ${error.code} - ${error.message}',
        error: error,
        stackTrace: stackTrace,
      );

      if (error.code == 'object-not-found') {
        return;
      }

      rethrow;
    }
  }
}
