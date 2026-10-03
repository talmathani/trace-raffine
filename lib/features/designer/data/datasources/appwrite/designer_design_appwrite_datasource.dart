import 'package:appwrite/appwrite.dart';
import 'package:trace_raffine/core/appwrite/appwrite_database_constants.dart';
import 'package:trace_raffine/core/appwrite/appwrite_database_service.dart';
import 'package:trace_raffine/core/auth/current_user_service.dart';
import '../../../domain/models/designer_design_model.dart';

class DesignerDesignAppwriteDataSource {
  final AppwriteDatabaseService _databaseService;

  DesignerDesignAppwriteDataSource({AppwriteDatabaseService? databaseService})
    : _databaseService = databaseService ?? AppwriteDatabaseService();

  Future<String> createDesign({
    required String designId,
    required Map<String, dynamic> data,
  }) async {
    final currentUserId = await CurrentUserService.userId;
    final designerId = data['designer_id']?.toString().trim() ?? '';
    if (currentUserId == null ||
        designerId.isEmpty ||
        designerId != currentUserId) {
      throw AppwriteException('Designer ownership validation failed', 403);
    }

    final document = await _databaseService.createDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
      data: data,
      permissions: [
        Permission.read(Role.user(data['designer_id']?.toString() ?? '')),
        Permission.update(Role.user(data['designer_id']?.toString() ?? '')),
        Permission.delete(Role.user(data['designer_id']?.toString() ?? '')),
      ],
    );
    return document.$id;
  }

  Future<DesignerDesignModel?> getDesign({required String designId}) async {
    try {
      final document = await _databaseService.getDocument(
        collectionId: AppwriteDatabaseConstants.designsCollectionId,
        documentId: designId,
      );
      await _requireOwner(document.data);
      return DesignerDesignModel.fromAppwrite(document.$id, document.data);
    } on AppwriteException catch (error) {
      if (error.code == 404) return null;
      rethrow;
    }
  }

  Future<void> updateDesign({
    required String designId,
    required Map<String, dynamic> data,
  }) async {
    final current = await _databaseService.getDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
    );
    await _requireOwner(current.data);
    final requestedDesignerId = data['designer_id']?.toString().trim();
    if (requestedDesignerId != null &&
        requestedDesignerId != (await CurrentUserService.userId)) {
      throw AppwriteException('Designer ownership validation failed', 403);
    }
    await _databaseService.updateDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
      data: data,
    );
  }

  Future<void> deleteDesign({required String designId}) async {
    final current = await _databaseService.getDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
    );
    await _requireOwner(current.data);
    await _databaseService.deleteDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
    );
  }

  Future<void> _requireOwner(Map<String, dynamic> data) async {
    final currentUserId = await CurrentUserService.userId;
    final ownerId = data['designer_id']?.toString().trim();
    if (currentUserId == null || ownerId == null || ownerId != currentUserId) {
      throw AppwriteException('Designer ownership validation failed', 403);
    }
  }

  Stream<List<DesignerDesignModel>> watchDesignerDesigns({
    required String designerId,
  }) async* {
    final currentUserId = await CurrentUserService.userId;
    if (currentUserId == null || currentUserId != designerId) {
      throw AppwriteException('Designer ownership validation failed', 403);
    }

    final documentList = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      queries: [Query.equal('designer_id', designerId)],
    );

    yield documentList.documents
        .map((doc) => DesignerDesignModel.fromAppwrite(doc.$id, doc.data))
        .toList(growable: false);
  }
}
