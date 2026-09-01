import 'package:appwrite/appwrite.dart';
import '../../../../../core/appwrite/appwrite_database_constants.dart';
import '../../../../../core/appwrite/appwrite_database_service.dart';
import '../../../domain/models/designer_design_model.dart';

class DesignerDesignAppwriteDataSource {
  final AppwriteDatabaseService _databaseService;

  DesignerDesignAppwriteDataSource({AppwriteDatabaseService? databaseService})
    : _databaseService = databaseService ?? AppwriteDatabaseService();

  Future<String> createDesign({
    required String designId,
    required Map<String, dynamic> data,
  }) async {
    final document = await _databaseService.createDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
      data: data,
    );
    return document.$id;
  }

  Stream<List<DesignerDesignModel>> watchDesignerDesigns({required String designerId}) async* {
    while (true) {
      final documentList = await _databaseService.listDocuments(
        collectionId: AppwriteDatabaseConstants.designsCollectionId,
        queries: [Query.equal('designer_id', designerId)],
      );

      yield documentList.documents
          .map((doc) => DesignerDesignModel.fromAppwrite(doc.$id, doc.data))
          .toList(growable: false);

      await Future.delayed(const Duration(seconds: 5));
    }
  }
}
