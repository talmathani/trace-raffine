import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_data_source.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDataSource dataSource;

  CategoryRepositoryImpl(this.dataSource);

  @override
  Future<List<Category>> getCategories() async {
    final models = await dataSource.getCategories();
    return models.cast<Category>();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    return await dataSource.getCategoryById(id);
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
    return dataSource.createCategory(model);
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      iconUrl: category.iconUrl,
      sortOrder: category.sortOrder,
      isActive: category.isActive,
    );
    return dataSource.updateCategory(model);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await dataSource.deleteCategory(id);
  }
}
