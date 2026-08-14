import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

import '../../../../../core/appwrite/appwrite_database_constants.dart';
import '../../../../../core/appwrite/appwrite_database_service.dart';

class CustomerDesignAppwriteDataSource {
  CustomerDesignAppwriteDataSource({AppwriteDatabaseService? databaseService})
    : _databaseService = databaseService ?? AppwriteDatabaseService();

  final AppwriteDatabaseService _databaseService;

  Stream<DocumentList> watchApprovedDesigns({String? category}) {
    final normalizedCategory = category?.trim();

    final queries = <String>[
      Query.equal('status', 'approved'),
      Query.orderDesc(r'$createdAt'),
    ];

    if (normalizedCategory != null && normalizedCategory.isNotEmpty) {
      queries.add(Query.equal('category', normalizedCategory));
    }

    return Stream.fromFuture(
      _databaseService.listDocuments(
        collectionId: AppwriteDatabaseConstants.designsCollectionId,
        queries: queries,
      ),
    );
  }

  Future<Document> getDesign({required String designId}) {
    return _databaseService.getDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
    );
  }
}
