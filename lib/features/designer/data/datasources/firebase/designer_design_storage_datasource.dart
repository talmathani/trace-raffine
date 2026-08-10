import 'dart:typed_data';

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
    final reference = _storage.ref().child(storagePath);

    final metadata = SettableMetadata(
      contentType: contentType,
    );

    final uploadTask = reference.putData(
      bytes,
      metadata,
    );

    final snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }

  Future<void> deleteFile({
    required String storagePath,
  }) async {
    final reference = _storage.ref().child(storagePath);

    try {
      await reference.delete();
    } on FirebaseException catch (error) {
      if (error.code == 'object-not-found') {
        return;
      }

      rethrow;
    }
  }
}
