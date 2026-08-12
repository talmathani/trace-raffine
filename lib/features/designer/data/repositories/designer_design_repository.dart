import 'package:flutter/foundation.dart';

import '../../domain/models/designer_design_model.dart';
import '../../domain/repositories/designer_design_repository.dart';
import '../datasources/firebase/designer_design_firestore_datasource.dart';
import '../datasources/firebase/designer_design_storage_datasource.dart';

class DesignerDesignRepositoryImpl
    implements DesignerDesignRepository {
  DesignerDesignRepositoryImpl({
    DesignerDesignFirestoreDataSource? firestoreDataSource,
    DesignerDesignStorageDataSource? storageDataSource,
  })  : _firestoreDataSource =
            firestoreDataSource ?? DesignerDesignFirestoreDataSource(),
        _storageDataSource =
            storageDataSource ?? DesignerDesignStorageDataSource();

  final DesignerDesignFirestoreDataSource _firestoreDataSource;
  final DesignerDesignStorageDataSource _storageDataSource;

  @override
  Future<String> createDesign({
    required String designerId,
    required String title,
    required String category,
    required String description,
    required double price,
    required String fileExtension,
    required Uint8List designImageBytes,
    required String designImageName,
    required Uint8List embroideryFileBytes,
    required String embroideryFileName,
    String? stitchDetails,
    String? beadDetails,
    String? sequinDetails,
    String? additionalDetails,
  }) async {
    final temporaryId =
        DateTime.now().microsecondsSinceEpoch.toString();

    final imageExtension = _extensionOf(designImageName);
    final embroideryExtension = _extensionOf(embroideryFileName);

    final imagePath =
        'designer_designs/$designerId/$temporaryId/design.$imageExtension';

    final embroideryPath =
        'designer_designs/$designerId/$temporaryId/embroidery.$embroideryExtension';

    final imageContentType = _imageContentType(imageExtension);

    debugPrint('=== DESIGN REPOSITORY: START IMAGE UPLOAD ===');

    final imageUrl = await _storageDataSource.uploadFile(
      bytes: designImageBytes,
      storagePath: imagePath,
      contentType: imageContentType,
    );

    try {
      final embroideryUrl = await _storageDataSource.uploadFile(
        bytes: embroideryFileBytes,
        storagePath: embroideryPath,
        contentType: 'application/octet-stream',
      );

      try {
        final designId = await _firestoreDataSource.createDesign(
          designId: temporaryId,
          data: {
            'designerId': designerId,
            'title': title.trim(),
            'category': category.trim(),
            'description': _nullableValue(description),
            'price': price,
            'fileExtension': embroideryExtension,
            'status': 'pending',
            'designImagePath': imagePath,
            'designImageUrl': imageUrl,
            'embroideryFilePath': embroideryPath,
            'embroideryFileUrl': embroideryUrl,
            'stitchDetails': _nullableValue(stitchDetails),
            'beadDetails': _nullableValue(beadDetails),
            'sequinDetails': _nullableValue(sequinDetails),
            'additionalDetails': _nullableValue(additionalDetails),
            'rejectionReason': null,
          },
        );

        return designId;
      } catch (_) {
        await _storageDataSource.deleteFile(
          storagePath: embroideryPath,
        );
        rethrow;
      }
    } catch (_) {
      await _storageDataSource.deleteFile(
        storagePath: imagePath,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateDesign({
    required String designId,
    required Map<String, dynamic> data,
  }) {
    return _firestoreDataSource.updateDesign(
      designId: designId,
      data: data,
    );
  }

  @override
  Future<void> deleteDesign({
    required String designId,
    required String? imagePath,
    required String? embroideryPath,
  }) async {
    if (imagePath != null && imagePath.trim().isNotEmpty) {
      await _storageDataSource.deleteFile(
        storagePath: imagePath,
      );
    }

    if (embroideryPath != null &&
        embroideryPath.trim().isNotEmpty) {
      await _storageDataSource.deleteFile(
        storagePath: embroideryPath,
      );
    }

    await _firestoreDataSource.deleteDesign(
      designId: designId,
    );
  }

  @override
  Stream<List<DesignerDesignModel>> watchDesignerDesigns({
    required String designerId,
  }) {
    return _firestoreDataSource
        .watchDesignerDesigns(
          designerId: designerId,
        )
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => DesignerDesignModel.fromFirestore(
                  document.id,
                  document.data(),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<DesignerDesignModel?> getDesign({
    required String designId,
  }) async {
    final document = await _firestoreDataSource.getDesign(
      designId: designId,
    );

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return DesignerDesignModel.fromFirestore(
      document.id,
      data,
    );
  }

  String _extensionOf(String fileName) {
    final normalized = fileName.trim();

    if (normalized.isEmpty || !normalized.contains('.')) {
      return 'bin';
    }

    final extension =
        normalized.split('.').last.trim().toLowerCase();

    if (extension.isEmpty) {
      return 'bin';
    }

    return extension;
  }

  String _imageContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  String? _nullableValue(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}


