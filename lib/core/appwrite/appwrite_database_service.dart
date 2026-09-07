// ignore_for_file: deprecated_member_use
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

import 'appwrite_service.dart';
import 'appwrite_database_constants.dart';

class AppwriteDatabaseService {
  AppwriteDatabaseService({Databases? databases})
    : _databases = databases ?? AppwriteService.databases;

  final Databases _databases;

  Future<Document> createDocument({
    required String collectionId,
    required Map<String, dynamic> data,
    String? documentId,
    List<String>? permissions,
  }) async {

    final document = await _databases.createDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: collectionId,
      documentId: documentId ?? ID.unique(),
      data: data,
      permissions: permissions,
    );

    return document;
  }

  Future<Document> getDocument({
    required String collectionId,
    required String documentId,
  }) {
    return _databases.getDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }

  Future<Document> updateDocument({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return _databases.updateDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: collectionId,
      documentId: documentId,
      data: data,
    );
  }

  Future<void> deleteDocument({
    required String collectionId,
    required String documentId,
  }) {
    return _databases.deleteDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }

  Future<DocumentList> listDocuments({
    required String collectionId,
    List<String>? queries,
  }) {
    return _databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: collectionId,
      queries: queries,
    );
  }
}
