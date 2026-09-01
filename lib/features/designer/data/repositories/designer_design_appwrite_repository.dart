import 'package:flutter/foundation.dart';

import '../../domain/models/designer_design_model.dart';
import '../../domain/repositories/designer_design_repository.dart';
import '../datasources/appwrite/designer_design_appwrite_datasource.dart';
import '../datasources/appwrite/designer_design_storage_appwrite_datasource.dart';

class DesignerDesignAppwriteRepositoryImpl implements DesignerDesignRepository {
  final DesignerDesignAppwriteDataSource _databaseDataSource;
  final DesignerDesignStorageAppwriteDataSource _storageDataSource;

  DesignerDesignAppwriteRepositoryImpl({
    DesignerDesignAppwriteDataSource? databaseDataSource,
    DesignerDesignStorageAppwriteDataSource? storageDataSource,
  })  : _databaseDataSource =
            databaseDataSource ?? DesignerDesignAppwriteDataSource(),
        _storageDataSource = storageDataSource ??
            DesignerDesignStorageAppwriteDataSource();

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
    final totalStopwatch = Stopwatch()..start();
    final temporaryId = DateTime.now().microsecondsSinceEpoch.toString();
    final imageExt = _extensionOf(designImageName);
    final embroideryExt = _extensionOf(embroideryFileName);

    debugPrint(
      'DESIGN PERFORMANCE: parallel uploads START '
      'imageBytes=${designImageBytes.length} '
      'embroideryBytes=${embroideryFileBytes.length}',
    );

    // Both Storage requests start immediately and run concurrently.
    final uploadResults = await Future.wait<_UploadOutcome>(<Future<_UploadOutcome>>[
      _uploadImage(
        bytes: designImageBytes,
        extension: imageExt,
      ),
      _uploadEmbroidery(
        bytes: embroideryFileBytes,
        extension: embroideryExt,
      ),
    ]);

    final imageResult = uploadResults[0];
    final embroideryResult = uploadResults[1];

    if (!imageResult.isSuccess || !embroideryResult.isSuccess) {
      debugPrint(
        'DESIGN PERFORMANCE: parallel uploads FAILED '
        'imageMs=${imageResult.elapsed.inMilliseconds} '
        'embroideryMs=${embroideryResult.elapsed.inMilliseconds}',
      );

      // If one request succeeded and the other failed, remove the orphan.
      final uploadedIds = <String>[
        if (imageResult.fileId != null) imageResult.fileId!,
        if (embroideryResult.fileId != null) embroideryResult.fileId!,
      ];
      await _rollbackUploadedFiles(uploadedIds);

      final failed = !imageResult.isSuccess ? imageResult : embroideryResult;
      Error.throwWithStackTrace(
        failed.error ?? StateError('تعذر رفع ملفات التصميم.'),
        failed.stackTrace ?? StackTrace.current,
      );
    }

    debugPrint(
      'DESIGN PERFORMANCE: parallel uploads SUCCESS '
      'imageMs=${imageResult.elapsed.inMilliseconds} '
      'embroideryMs=${embroideryResult.elapsed.inMilliseconds} '
      'parallelMs=${_maxElapsed(imageResult.elapsed, embroideryResult.elapsed)}',
    );

    final databaseStopwatch = Stopwatch()..start();
    try {
      final documentId = await _databaseDataSource.createDesign(
        designId: temporaryId,
        data: {
          'designer_id': designerId,
          'title': title.trim(),
          'description': description.trim(),
          'category_id': category.trim(),
          'price': price.toInt(),
          'currency': 'USD',
          'status': 'pending',
          'cover_image_url': imageResult.fileId!,
          'file_key': embroideryResult.fileId!,
          'sales_count': 0,
          'review_count': 0,
          'rating': 0,
          'stitch_details': stitchDetails ?? '',
          'bead_details': beadDetails ?? '',
          'sequin_details': sequinDetails ?? '',
          'additional_details': additionalDetails ?? '',
        },
      );

      databaseStopwatch.stop();
      totalStopwatch.stop();
      debugPrint(
        'DESIGN PERFORMANCE: database SUCCESS '
        'databaseMs=${databaseStopwatch.elapsedMilliseconds} '
        'totalMs=${totalStopwatch.elapsedMilliseconds} '
        'documentId=$documentId',
      );
      return documentId;
    } catch (error, stackTrace) {
      databaseStopwatch.stop();
      debugPrint(
        'DESIGN PERFORMANCE: database FAILED '
        'databaseMs=${databaseStopwatch.elapsedMilliseconds} '
        'totalMs=${totalStopwatch.elapsedMilliseconds} '
        'error=$error',
      );

      await _rollbackUploadedFiles(<String>[
        imageResult.fileId!,
        embroideryResult.fileId!,
      ]);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<_UploadOutcome> _uploadImage({
    required Uint8List bytes,
    required String extension,
  }) async {
    final stopwatch = Stopwatch()..start();
    final fileName = 'design.$extension';
    final contentType = _imageContentType(extension);
    debugPrint(
      'DESIGN PERFORMANCE: image START '
      'bytes=${bytes.length} contentType=$contentType',
    );

    try {
      final fileId = await _storageDataSource.uploadFile(
        bytes: bytes,
        fileName: fileName,
        contentType: contentType,
      );
      stopwatch.stop();
      debugPrint(
        'DESIGN PERFORMANCE: image SUCCESS '
        'elapsedMs=${stopwatch.elapsedMilliseconds} fileId=$fileId',
      );
      return _UploadOutcome.success(fileId, stopwatch.elapsed);
    } catch (error, stackTrace) {
      stopwatch.stop();
      debugPrint(
        'DESIGN PERFORMANCE: image FAILED '
        'elapsedMs=${stopwatch.elapsedMilliseconds} error=$error',
      );
      return _UploadOutcome.failure(error, stackTrace, stopwatch.elapsed);
    }
  }

  Future<_UploadOutcome> _uploadEmbroidery({
    required Uint8List bytes,
    required String extension,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint(
      'DESIGN PERFORMANCE: embroidery START '
      'bytes=${bytes.length} contentType=application/octet-stream',
    );

    try {
      final fileId = await _storageDataSource.uploadFile(
        bytes: bytes,
        fileName: 'embroidery.$extension',
        contentType: 'application/octet-stream',
      );
      stopwatch.stop();
      debugPrint(
        'DESIGN PERFORMANCE: embroidery SUCCESS '
        'elapsedMs=${stopwatch.elapsedMilliseconds} fileId=$fileId',
      );
      return _UploadOutcome.success(fileId, stopwatch.elapsed);
    } catch (error, stackTrace) {
      stopwatch.stop();
      debugPrint(
        'DESIGN PERFORMANCE: embroidery FAILED '
        'elapsedMs=${stopwatch.elapsedMilliseconds} error=$error',
      );
      return _UploadOutcome.failure(error, stackTrace, stopwatch.elapsed);
    }
  }

  Future<void> _rollbackUploadedFiles(List<String> fileIds) async {
    if (fileIds.isEmpty) {
      return;
    }
    debugPrint(
      'DESIGN PERFORMANCE: rollback START count=${fileIds.length}',
    );
    for (final fileId in fileIds) {
      try {
        await _storageDataSource.deleteFile(fileId: fileId);
        debugPrint('DESIGN PERFORMANCE: rollback SUCCESS fileId=$fileId');
      } catch (error) {
        // Preserve the original upload/database error; log cleanup failure.
        debugPrint(
          'DESIGN PERFORMANCE: rollback FAILED '
          'fileId=$fileId error=$error',
        );
      }
    }
  }

  @override
  Stream<List<DesignerDesignModel>> watchDesignerDesigns({
    required String designerId,
  }) {
    return _databaseDataSource.watchDesignerDesigns(designerId: designerId);
  }

  @override
  Future<DesignerDesignModel?> getDesign({required String designId}) async => null;

  @override
  Future<void> updateDesign({
    required String designId,
    required Map<String, dynamic> data,
  }) async {}

  @override
  Future<void> deleteDesign({
    required String designId,
    required String? imagePath,
    required String? embroideryPath,
  }) async {}

  String _extensionOf(String fileName) {
    final normalized = fileName.trim();
    final lastDot = normalized.lastIndexOf('.');
    if (lastDot < 0 || lastDot == normalized.length - 1) {
      return 'bin';
    }
    return normalized.substring(lastDot + 1).toLowerCase();
  }

  int _maxElapsed(Duration first, Duration second) {
    return first.inMilliseconds > second.inMilliseconds
        ? first.inMilliseconds
        : second.inMilliseconds;
  }

  String _imageContentType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}

class _UploadOutcome {
  final String? fileId;
  final Object? error;
  final StackTrace? stackTrace;
  final Duration elapsed;

  const _UploadOutcome({
    required this.fileId,
    required this.error,
    required this.stackTrace,
    required this.elapsed,
  });

  factory _UploadOutcome.success(String fileId, Duration elapsed) {
    return _UploadOutcome(
      fileId: fileId,
      error: null,
      stackTrace: null,
      elapsed: elapsed,
    );
  }

  factory _UploadOutcome.failure(
    Object error,
    StackTrace stackTrace,
    Duration elapsed,
  ) {
    return _UploadOutcome(
      fileId: null,
      error: error,
      stackTrace: stackTrace,
      elapsed: elapsed,
    );
  }

  bool get isSuccess => fileId != null;
}
