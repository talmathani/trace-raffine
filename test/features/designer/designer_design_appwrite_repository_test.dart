import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trace_raffine/core/storage/providers/storage_provider.dart';
import 'package:trace_raffine/features/designer/data/datasources/appwrite/designer_design_appwrite_datasource.dart';
import 'package:trace_raffine/features/designer/data/datasources/appwrite/designer_design_storage_appwrite_datasource.dart';
import 'package:trace_raffine/features/designer/data/repositories/designer_design_appwrite_repository.dart';

class _RecordingStorageProvider implements StorageProvider {
  final Map<String, List<String>> permissionsByFileName = {};
  final List<String> deletedFileIds = [];

  @override
  Future<String> uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    List<String>? permissions,
    void Function(double progress)? onProgress,
    void Function(void Function()?)? onCancelAvailable,
  }) async {
    permissionsByFileName[fileName] = List<String>.of(permissions ?? const []);
    onProgress?.call(1);
    return fileName.startsWith('design.') ? 'preview-file' : 'embroidery-file';
  }

  @override
  String getFileView({required String fileId}) => 'test://$fileId';

  @override
  Future<void> deleteFile({required String fileId}) async {
    deletedFileIds.add(fileId);
  }
}

class _RecordingDesignDataSource implements DesignerDesignAppwriteDataSource {
  int createCalls = 0;

  @override
  Future<String> createDesign({
    required String designId,
    required Map<String, dynamic> data,
  }) async {
    createCalls++;
    return 'design-document';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('DesignerDesignAppwriteRepositoryImpl upload permissions', () {
    test('keeps preview public-readable and grants designer delete on both files', () async {
      final storage = _RecordingStorageProvider();
      final database = _RecordingDesignDataSource();
      Map<String, String>? granted;
      final repository = DesignerDesignAppwriteRepositoryImpl(
        databaseDataSource: database,
        storageDataSource: DesignerDesignStorageAppwriteDataSource(
          storageProvider: storage,
        ),
        adminFileAccessGrant: ({required fileId, required designerId}) async {
          granted = {'fileId': fileId, 'designerId': designerId};
        },
      );

      final result = await repository.createDesign(
        designerId: 'designer-123',
        title: 'Test design',
        category: 'embroidery',
        description: 'Test',
        price: 10,
        fileExtension: 'dst',
        designImageBytes: Uint8List.fromList([1, 2, 3]),
        designImageName: 'preview.png',
        embroideryFileBytes: Uint8List.fromList([4, 5, 6]),
        embroideryFileName: 'stitch.dst',
      );

      expect(result, 'design-document');
      expect(storage.permissionsByFileName['design.png'], [
        Permission.read(Role.any()),
        Permission.delete(Role.user('designer-123')),
      ]);
      expect(storage.permissionsByFileName['stitch.dst'], [
        Permission.read(Role.user('designer-123')),
        Permission.delete(Role.user('designer-123')),
      ]);
      expect(granted, {
        'fileId': 'embroidery-file',
        'designerId': 'designer-123',
      });
      expect(database.createCalls, 1);
    });

    test('rolls back both uploaded files if granting admin read fails', () async {
      final storage = _RecordingStorageProvider();
      final database = _RecordingDesignDataSource();
      final repository = DesignerDesignAppwriteRepositoryImpl(
        databaseDataSource: database,
        storageDataSource: DesignerDesignStorageAppwriteDataSource(
          storageProvider: storage,
        ),
        adminFileAccessGrant: ({required fileId, required designerId}) async {
          throw StateError('simulated permission-grant failure');
        },
      );

      await expectLater(
        repository.createDesign(
          designerId: 'designer-123',
          title: 'Test design',
          category: 'embroidery',
          description: 'Test',
          price: 10,
          fileExtension: 'dst',
          designImageBytes: Uint8List.fromList([1, 2, 3]),
          designImageName: 'preview.png',
          embroideryFileBytes: Uint8List.fromList([4, 5, 6]),
          embroideryFileName: 'stitch.dst',
        ),
        throwsA(isA<StateError>()),
      );

      expect(storage.deletedFileIds, containsAll(['preview-file', 'embroidery-file']));
      expect(database.createCalls, 0);
    });
  });
}
