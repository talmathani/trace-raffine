import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../models/category_model.dart';

class CategoryDataSource {
  final Databases databases;

  CategoryDataSource(this.databases);

  factory CategoryDataSource.create() {
    final client = AppwriteConfig.createClient();
    return CategoryDataSource(Databases(client));
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.categoriesCollection,
      queries: [
        Query.equal('is_active', true),
        Query.orderAsc('sort_order'),
      ],
    );
    return response.documents.map((doc) => CategoryModel.fromJson(doc.data)).toList();
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final doc = await databases.getDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.categoriesCollection,
      documentId: id,
    );
    return CategoryModel.fromJson(doc.data);
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    final doc = await databases.createDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.categoriesCollection,
      documentId: ID.unique(),
      data: category.toJson(),
    );
    return CategoryModel.fromJson(doc.data);
  }

  Future<CategoryModel> updateCategory(CategoryModel category) async {
    final doc = await databases.updateDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.categoriesCollection,
      documentId: category.id!,
      data: category.toJson(),
    );
    return CategoryModel.fromJson(doc.data);
  }

  Future<void> deleteCategory(String id) async {
    await databases.deleteDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.categoriesCollection,
      documentId: id,
    );
  }
}
