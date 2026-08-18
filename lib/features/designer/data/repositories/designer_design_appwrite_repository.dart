import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/designer_design_model.dart';
import '../../domain/repositories/designer_design_repository.dart';
import '../datasources/appwrite/designer_design_appwrite_datasource.dart';
import '../datasources/appwrite/designer_design_storage_appwrite_datasource.dart';

class DesignerDesignAppwriteRepositoryImpl implements DesignerDesignRepository {
  DesignerDesignAppwriteRepositoryImpl({
    DesignerDesignAppwriteDataSource? databaseDataSource,
    DesignerDesignStorageAppwriteDataSource? storageDataSource,
  }) : _databaseDataSource =
           databaseDataSource ?? DesignerDesignAppwriteDataSource(),
       _storageDataSource =
           storageDataSource ?? DesignerDesignStorageAppwriteDataSource();

  final DesignerDesignAppwriteDataSource _databaseDataSource;
  final DesignerDesignStorageAppwriteDataSource _storageDataSource;

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
    final temporaryId = DateTime.now().microsecondsSinceEpoch.toString();

    final imageExtension = _extensionOf(designImageName);
    final embroideryExtension = _extensionOf(embroideryFileName);

    final imagePath =
        'designer_designs/$designerId/$temporaryId/design.$imageExtension';

    final embroideryPath =
        'designer_designs/$designerId/$temporaryId/embroidery.$embroideryExtension';

    String? imageFileId;
    String? embroideryFileId;

    try {
      debugPrint('=== APPWRITE DESIGN REPOSITORY: IMAGE UPLOAD START ===');

      imageFileId = await _storageDataSource.uploadFile(
        bytes: designImageBytes,
        storagePath: imagePath,
        contentType: _imageContentType(imageExtension),
        permissions: <String>[
          Permission.read(Role.users()),
          Permission.write(Role.user(designerId)),
        ],
      );

      debugPrint('=== APPWRITE DESIGN REPOSITORY: EMBROIDERY UPLOAD START ===');

      embroideryFileId = await _storageDataSource.uploadFile(
        bytes: embroideryFileBytes,
        storagePath: embroideryPath,
        contentType: 'application/octet-stream',
        permissions: <String>[
          Permission.read(Role.user(designerId)),
          Permission.write(Role.user(designerId)),
        ],
      );

      final imageUrl = _storageDataSource.getFileView(fileId: imageFileId);

      final embroideryUrl = _storageDataSource.getFileView(
        fileId: embroideryFileId,
      );

      final designId = await _databaseDataSource.createDesign(
        designId: temporaryId,
        permissions: <String>[
          Permission.read(Role.users()),
          Permission.update(Role.user(designerId)),
          Permission.delete(Role.user(designerId)),
        ],
        data: {
          'designerId': designerId,
          'title': title.trim(),
          'category': category.trim(),
          'description': description.trim(),
          'price': price,
          'fileExtension': embroideryExtension,
          'status': 'pending',
          'designImagePath': imageFileId,
          'designImageUrl': imageUrl,
          'embroideryFilePath': embroideryFileId,
          'embroideryFileUrl': embroideryUrl,
          'stitchDetails': stitchDetails?.trim() ?? '',
          'beadDetails': beadDetails?.trim() ?? '',
          'sequinDetails': sequinDetails?.trim() ?? '',
          'additionalDetails': _nullableValue(additionalDetails),
        },
      );

      return designId;
    } catch (error, stackTrace) {
      debugPrint('=== APPWRITE DESIGN REPOSITORY ERROR ===');
      debugPrint('ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');
      if (embroideryFileId != null) {
        try {
          await _storageDataSource.deleteFile(fileId: embroideryFileId);
        } catch (_) {}
      }

      if (imageFileId != null) {
        try {
          await _storageDataSource.deleteFile(fileId: imageFileId);
        } catch (_) {}
      }

      rethrow;
    }
  }

  @override
  Future<void> updateDesign({
    required String designId,
    required Map<String, dynamic> data,
  }) {
    return _databaseDataSource.updateDesign(designId: designId, data: data);
  }

  @override
  Future<void> deleteDesign({
    required String designId,
    required String? imagePath,
    required String? embroideryPath,
  }) async {
    if (imagePath != null && imagePath.trim().isNotEmpty) {
      await _storageDataSource.deleteFile(fileId: imagePath);
    }

    if (embroideryPath != null && embroideryPath.trim().isNotEmpty) {
      await _storageDataSource.deleteFile(fileId: embroideryPath);
    }

    await _databaseDataSource.deleteDesign(designId: designId);
  }

  @override
  Stream<List<DesignerDesignModel>> watchDesignerDesigns({
    required String designerId,
  }) {
    return _databaseDataSource
        .watchDesignerDesigns(designerId: designerId)
        .map(
          (documentList) => documentList.documents
              .map(
                (document) => DesignerDesignModel.fromFirestore(
                  document.$id,
                  document.data,
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<DesignerDesignModel?> getDesign({required String designId}) async {
    final document = await _databaseDataSource.getDesign(designId: designId);

    final data = document.data;

    if (data.isEmpty) {
      return null;
    }

    return DesignerDesignModel.fromFirestore(document.$id, data);
  }

  String _extensionOf(String fileName) {
    final normalized = fileName.trim();

    if (normalized.isEmpty || !normalized.contains('.')) {
      return 'bin';
    }

    final extension = normalized.split('.').last.trim().toLowerCase();

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
