import 'package:trace_raffine/core/appwrite/appwrite_database_constants.dart';
import 'package:trace_raffine/core/appwrite/appwrite_database_service.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppwriteDatabaseService _databaseService;

  CategoryRepositoryImpl(this._databaseService);

  @override
  Future<List<Category>> getCategories() async {
    final response = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.categoriesCollectionId,
    );

    return response.documents
        .map((doc) => CategoryModel.fromJson({...doc.data, r'$id': doc.$id}))
        .toList();
  }

  @override
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final doc = await _databaseService.getDocument(
        collectionId: AppwriteDatabaseConstants.categoriesCollectionId,
        documentId: categoryId,
      );

      return CategoryModel.fromJson({...doc.data, r'$id': doc.$id});
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Category> createCategory(Category category) async {
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      iconUrl: category.iconUrl,
      sortOrder: category.sortOrder,
      isActive: category.isActive,
    );

    final documentId = model.id != null && model.id!.isNotEmpty
        ? model.id
        : null;

    final doc = await _databaseService.createDocument(
      collectionId: AppwriteDatabaseConstants.categoriesCollectionId,
      data: {
        'name': model.name,
        'slug': model.slug,
        'icon_url': model.iconUrl,
        'sort_order': model.sortOrder,
        'is_active': model.isActive,
      },
      documentId: documentId,
    );

    return CategoryModel.fromJson({...doc.data, r'$id': doc.$id});
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final doc = await _databaseService.updateDocument(
      collectionId: AppwriteDatabaseConstants.categoriesCollectionId,
      documentId: category.id!,
      data: {
        'name': category.name,
        'slug': category.slug,
        'icon_url': category.iconUrl,
        'sort_order': category.sortOrder,
        'is_active': category.isActive,
      },
    );

    return CategoryModel.fromJson({...doc.data, r'$id': doc.$id});
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _databaseService.deleteDocument(
      collectionId: AppwriteDatabaseConstants.categoriesCollectionId,
      documentId: categoryId,
    );
  }
}
