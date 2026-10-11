import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';
import '../../domain/models/designer_design_model.dart';
import '../../domain/repositories/designer_design_repository.dart';
import '../datasources/appwrite/designer_design_appwrite_datasource.dart';
import '../datasources/appwrite/designer_design_storage_appwrite_datasource.dart';

typedef DesignerAdminFileAccessGrant = Future<void> Function({
  required String fileId,
  required String designerId,
});

class DesignerDesignAppwriteRepositoryImpl implements DesignerDesignRepository {
  final DesignerDesignAppwriteDataSource _databaseDataSource;
  final DesignerDesignStorageAppwriteDataSource _storageDataSource;
  final DesignerAdminFileAccessGrant? _adminFileAccessGrantOverride;

  DesignerDesignAppwriteRepositoryImpl({
    DesignerDesignAppwriteDataSource? databaseDataSource,
    DesignerDesignStorageAppwriteDataSource? storageDataSource,
    DesignerAdminFileAccessGrant? adminFileAccessGrant,
  }) : _databaseDataSource =
           databaseDataSource ?? DesignerDesignAppwriteDataSource(),
       _storageDataSource =
           storageDataSource ?? DesignerDesignStorageAppwriteDataSource(),
       _adminFileAccessGrantOverride = adminFileAccessGrant;

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
    void Function(double progress)? onProgress,
    void Function(void Function()?)? onCancelAvailable,
  }) async {
    final totalStopwatch = Stopwatch()..start();
    final temporaryId = DateTime.now().microsecondsSinceEpoch.toString();
    final imageExt = _extensionOf(designImageName);
    final embroideryExt = _extensionOf(embroideryFileName);

    debugPrint(
      'DESIGN PERFORMANCE: uploads START '
      'imageBytes=${designImageBytes.length} '
      'embroideryBytes=${embroideryFileBytes.length}',
    );

    var imageProgress = 0.0;
    var embroideryProgress = 0.0;
    void reportProgress() {
      final totalBytes = designImageBytes.length + embroideryFileBytes.length;
      if (totalBytes <= 0) {
        onProgress?.call(0);
        return;
      }
      final uploadedBytes =
          designImageBytes.length * imageProgress +
          embroideryFileBytes.length * embroideryProgress;
      onProgress?.call((uploadedBytes / totalBytes).clamp(0.0, 1.0));
    }

    void Function()? cancelImageUpload;
    void Function()? cancelEmbroideryUpload;
    void publishCancelAction() {
      if (cancelImageUpload == null && cancelEmbroideryUpload == null) {
        onCancelAvailable?.call(null);
        return;
      }
      onCancelAvailable?.call(() {
        cancelImageUpload?.call();
        cancelEmbroideryUpload?.call();
      });
    }

    // Upload both files concurrently and report their combined byte progress.
    final uploadResults = await Future.wait<_UploadOutcome>(
      <Future<_UploadOutcome>>[
        _uploadImage(
          bytes: designImageBytes,
          extension: imageExt,
          // Keep the preview public while allowing the owning designer to clean it up.
          permissions: <String>[
            Permission.read(Role.any()),
            Permission.delete(Role.user(designerId)),
          ],
          onProgress: (progress) {
            imageProgress = progress;
            reportProgress();
          },
          onCancelAvailable: (cancel) {
            cancelImageUpload = cancel;
            publishCancelAction();
          },
        ),
        _uploadEmbroidery(
          bytes: embroideryFileBytes,
          fileName: embroideryFileName.trim().isNotEmpty
              ? embroideryFileName.trim()
              : 'embroidery.$embroideryExt',
          // Admin read access is granted server-side after both uploads succeed.
          permissions: <String>[
            Permission.read(Role.user(designerId)),
            Permission.delete(Role.user(designerId)),
          ],
          onProgress: (progress) {
            embroideryProgress = progress;
            reportProgress();
          },
          onCancelAvailable: (cancel) {
            cancelEmbroideryUpload = cancel;
            publishCancelAction();
          },
        ),
      ],
    );

    onCancelAvailable?.call(() {});
    final imageResult = uploadResults[0];
    final embroideryResult = uploadResults[1];

    if (!imageResult.isSuccess || !embroideryResult.isSuccess) {
      debugPrint(
        'DESIGN PERFORMANCE: parallel uploads FAILED '
        'imageMs=${imageResult.elapsed.inMilliseconds} '
        'embroideryMs=${embroideryResult.elapsed.inMilliseconds}',
      );
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

    try {
      final grantAccess = _adminFileAccessGrantOverride;
      if (grantAccess != null) {
        await grantAccess(
          fileId: embroideryResult.fileId!,
          designerId: designerId,
        );
      } else {
        await _grantAdminReadAccess(
          fileId: embroideryResult.fileId!,
          designerId: designerId,
        );
      }
    } catch (error, stackTrace) {
      debugPrint(
        'DESIGN PERFORMANCE: admin permission grant FAILED '
        'fileId=${embroideryResult.fileId} error=$error',
      );
      await _rollbackUploadedFiles(<String>[
        imageResult.fileId!,
        embroideryResult.fileId!,
      ]);
      Error.throwWithStackTrace(error, stackTrace);
    }

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
    required List<String> permissions,
    void Function(double progress)? onProgress,
    void Function(void Function()?)? onCancelAvailable,
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
        permissions: permissions,
        onProgress: onProgress,
        onCancelAvailable: onCancelAvailable,
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
        'elapsedMs=${stopwatch.elapsedMilliseconds} '
        'errorType=${error.runtimeType} error=$error',
      );
      return _UploadOutcome.failure(error, stackTrace, stopwatch.elapsed);
    }
  }

  Future<_UploadOutcome> _uploadEmbroidery({
    required Uint8List bytes,
    required String fileName,
    required List<String> permissions,
    void Function(double progress)? onProgress,
    void Function(void Function()?)? onCancelAvailable,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint(
      'DESIGN PERFORMANCE: embroidery START '
      'bytes=${bytes.length} contentType=application/octet-stream',
    );

    try {
      final fileId = await _storageDataSource.uploadFile(
        bytes: bytes,
        fileName: fileName,
        contentType: 'application/octet-stream',
        permissions: permissions,
        onProgress: onProgress,
        onCancelAvailable: onCancelAvailable,
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
        'elapsedMs=${stopwatch.elapsedMilliseconds} '
        'errorType=${error.runtimeType} error=$error',
      );
      return _UploadOutcome.failure(error, stackTrace, stopwatch.elapsed);
    }
  }

  Future<void> _grantAdminReadAccess({
    required String fileId,
    required String designerId,
  }) async {
    final execution = await Functions(AppwriteService.client).createExecution(
      functionId: AppwriteConfig.adminUserControlFunctionId,
      body: jsonEncode(<String, dynamic>{
        'action': 'grant_design_admin_file_access',
        'fileId': fileId,
        'designerId': designerId,
      }),
      xasync: false,
    );

    final responseBody = execution.responseBody.trim();
    if (responseBody.isEmpty) {
      throw StateError('خدمة صلاحيات ملفات التصميم أعادت استجابة فارغة.');
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is! Map || decoded['success'] != true) {
      throw StateError(
        decoded is Map
            ? decoded['error']?.toString() ?? 'تعذر منح صلاحية الإدارة للملف.'
            : 'استجابة غير صالحة من خدمة صلاحيات ملفات التصميم.',
      );
    }
  }

  Future<void> _rollbackUploadedFiles(List<String> fileIds) async {
    if (fileIds.isEmpty) {
      return;
    }
    debugPrint('DESIGN PERFORMANCE: rollback START count=${fileIds.length}');
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
  Future<DesignerDesignModel?> getDesign({required String designId}) {
    return _databaseDataSource.getDesign(designId: designId);
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
    await _databaseDataSource.deleteDesign(designId: designId);
    for (final path in <String?>[imagePath, embroideryPath]) {
      final fileId = path?.trim() ?? '';
      if (fileId.isNotEmpty) {
        try {
          await _storageDataSource.deleteFile(fileId: fileId);
        } catch (error) {
          debugPrint('DESIGN DELETE FILE WARNING: fileId=$fileId error=$error');
        }
      }
    }
  }

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
