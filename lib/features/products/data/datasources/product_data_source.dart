// ignore_for_file: deprecated_member_use

import 'package:appwrite/appwrite.dart';

import 'package:trace_raffine/core/appwrite/appwrite_config.dart';
import 'package:trace_raffine/core/appwrite/appwrite_database_constants.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

class ProductDataSource {
  final Databases databases;

  ProductDataSource(this.databases);

  factory ProductDataSource.create() {
    final client = AppwriteConfig.createClient();
    return ProductDataSource(Databases(client));
  }

  ProductModel _toModel(
    Map<String, dynamic> data, {
    bool exposeDesignerId = false,
  }) {
    final publicData = Map<String, dynamic>.from(data)
      ..remove('file_key')
      ..remove('embroideryFilePath')
      ..remove('embroideryFileUrl');

    if (!exposeDesignerId) {
      publicData.remove('designer_id');
      publicData['designer_id'] = '';
    }

    return ProductModel.fromJson(publicData);
  }

  Future<List<ProductModel>> getProducts({
    int limit = 20,
    int offset = 0,
    String? categoryId,
  }) async {
    final queries = <String>[
      Query.equal('status', 'published'),
      if (categoryId != null && categoryId.trim().isNotEmpty)
        Query.equal('category_id', categoryId.trim()),
      Query.orderDesc(r'$createdAt'),
      Query.limit(limit),
      Query.offset(offset),
    ];

    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.productsCollection,
      queries: queries,
    );

    return response.documents
        .map((doc) => _toModel({...doc.data, r'$id': doc.$id}))
        .toList(growable: false);
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await databases.getDocument(
        databaseId: AppwriteDatabaseConstants.databaseId,
        collectionId: AppwriteDatabaseConstants.productsCollection,
        documentId: id,
      );

      final status = doc.data['status']?.toString().toLowerCase();
      if (status != 'published') return null;
      return _toModel({...doc.data, r'$id': doc.$id});
    } on AppwriteException catch (e) {
      if (e.code == 404) return null;
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByDesigner(String designerId) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.productsCollection,
      queries: [
        Query.equal('designer_id', designerId),
        Query.orderDesc(r'$createdAt'),
      ],
    );

    return response.documents
        .map(
          (doc) =>
              _toModel({...doc.data, r'$id': doc.$id}, exposeDesignerId: true),
        )
        .toList(growable: false);
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.productsCollection,
      queries: [
        Query.equal('status', 'published'),
        Query.search('title', query),
      ],
    );

    return response.documents
        .map((doc) => _toModel({...doc.data, r'$id': doc.$id}))
        .toList(growable: false);
  }

  Future<ProductModel> createProduct(Product product) async {
    final doc = await databases.createDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.productsCollection,
      documentId: product.id != null && product.id!.isNotEmpty
          ? product.id!
          : ID.unique(),
      data: product.toJson(),
    );

    return _toModel({...doc.data, r'$id': doc.$id});
  }

  Future<ProductModel> updateProduct(Product product) async {
    if (product.id == null || product.id!.isEmpty) {
      throw ArgumentError('Product ID is required for update.');
    }

    final doc = await databases.updateDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.productsCollection,
      documentId: product.id!,
      data: product.toJson(),
    );

    return _toModel({...doc.data, r'$id': doc.$id});
  }

  Future<void> deleteProduct(String id) async {
    await databases.deleteDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.productsCollection,
      documentId: id,
    );
  }
}
