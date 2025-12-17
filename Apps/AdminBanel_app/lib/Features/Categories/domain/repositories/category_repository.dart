import '../entities/category_entity.dart';

/// Category Repository Interface - Domain Layer
/// Defines the contract for category data operations
abstract class CategoryRepository {
  /// Get all categories
  Future<List<CategoryEntity>> getAllCategories();

  /// Get active categories only
  Future<List<CategoryEntity>> getActiveCategories();

  /// Get category by ID
  Future<CategoryEntity?> getCategoryById(String id);

  /// Get category by name
  Future<CategoryEntity?> getCategoryByName(String name);

  /// Create new category
  Future<void> createCategory(CategoryEntity category);

  /// Update existing category
  Future<void> updateCategory(CategoryEntity category);

  /// Delete category
  Future<void> deleteCategory(String id);

  /// Toggle category active status
  Future<void> toggleCategoryStatus(String id, bool isActive);

  /// Update product count for category
  Future<void> updateProductCount(String categoryId, int count);

  /// Stream of all categories (real-time updates)
  Stream<List<CategoryEntity>> watchCategories();
}

