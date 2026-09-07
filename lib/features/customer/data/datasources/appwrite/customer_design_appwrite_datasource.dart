import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

import '../../../../../core/appwrite/appwrite_database_constants.dart';
import '../../../../../core/appwrite/appwrite_database_service.dart';

class CustomerDesignAppwriteDataSource {
  CustomerDesignAppwriteDataSource({
    AppwriteDatabaseService? databaseService,
  }) : _databaseService = databaseService ?? AppwriteDatabaseService();

  final AppwriteDatabaseService _databaseService;

  Stream<DocumentList> watchApprovedDesigns({String? category}) {
    final normalizedCategory = category?.trim();

    final queries = <String>[
      Query.equal('status', 'published'),
      Query.orderDesc(r'$createdAt'),
      Query.limit(24),
    ];

    if (normalizedCategory != null && normalizedCategory.isNotEmpty) {
      queries.add(Query.equal('category_id', normalizedCategory));
    }

    return Stream.fromFuture(
      _databaseService
          .listDocuments(
            collectionId: AppwriteDatabaseConstants.designsCollectionId,
            queries: queries,
          )
          .then(_resolveImageData),
    );
  }

  Future<DocumentList> _resolveImageData(DocumentList documents) async {
    final resolvedDocuments = await Future.wait(
      documents.documents.map(_resolveDocument),
    );

    return DocumentList(
      total: documents.total,
      documents: resolvedDocuments,
    );
  }

  Future<Document> _resolveDocument(Document document) async {
    final data = Map<String, dynamic>.from(document.data);

    final coverImageFileId = _nullableString(
      data['cover_image_url'],
    );

    data['designImagePath'] = coverImageFileId;
    data['designImageBytes'] = null;

    return Document(
      $id: document.$id,
      $collectionId: document.$collectionId,
      $databaseId: document.$databaseId,
      $createdAt: document.$createdAt,
      $updatedAt: document.$updatedAt,
      $sequence: document.$sequence,
      $permissions: document.$permissions,
      data: data,
    );
  }
  Future<Document> getDesign({
    required String designId,
  }) async {
    final document = await _databaseService.getDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
    );

    return _resolveDocument(document);
  }
  String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final valueString = value.toString().trim();

    if (valueString.isEmpty) {
      return null;
    }

    return valueString;
  }
}











