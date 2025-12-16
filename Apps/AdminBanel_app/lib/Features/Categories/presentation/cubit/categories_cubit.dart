import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import 'categories_states.dart';

/// Categories Cubit - State Management
/// Manages categories state and business logic
class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoryRepository categoryRepository;

  CategoriesCubit({required this.categoryRepository}) : super(CategoriesInitial());

  /// Fetch all categories
  Future<void> fetchAllCategories() async {
    emit(CategoriesLoading());
    try {
      final categories = await categoryRepository.getAllCategories();
      if (categories.isEmpty) {
        emit(CategoriesEmpty());
      } else {
        emit(CategoriesLoaded(categories));
      }
    } catch (e) {
      emit(CategoriesError('Failed to fetch categories: ${e.toString()}'));
    }
  }

  /// Fetch active categories only
  Future<void> fetchActiveCategories() async {
    emit(CategoriesLoading());
    try {
      final categories = await categoryRepository.getActiveCategories();
      if (categories.isEmpty) {
        emit(CategoriesEmpty());
      } else {
        emit(CategoriesLoaded(categories));
      }
    } catch (e) {
      emit(CategoriesError('Failed to fetch active categories: ${e.toString()}'));
    }
  }

  /// Get category by ID
  Future<void> getCategoryById(String id) async {
    emit(CategoriesLoading());
    try {
      final category = await categoryRepository.getCategoryById(id);
      if (category == null) {
        emit(CategoriesError('Category not found'));
      } else {
        emit(CategoriesLoaded([category]));
      }
    } catch (e) {
      emit(CategoriesError('Failed to fetch category: ${e.toString()}'));
    }
  }

  /// Create new category
  Future<void> createCategory(CategoryEntity category) async {
    emit(CategoriesLoading());
    try {
      await categoryRepository.createCategory(category);
      emit(CategoryCreated(category, 'Category created successfully'));
      await fetchAllCategories(); // Refresh list
    } catch (e) {
      emit(CategoriesError('Failed to create category: ${e.toString()}'));
    }
  }

  /// Update existing category
  Future<void> updateCategory(CategoryEntity category) async {
    emit(CategoriesLoading());
    try {
      await categoryRepository.updateCategory(category);
      emit(CategoryUpdated(category, 'Category updated successfully'));
      await fetchAllCategories(); // Refresh list
    } catch (e) {
      emit(CategoriesError('Failed to update category: ${e.toString()}'));
    }
  }

  /// Delete category
  Future<void> deleteCategory(String categoryId) async {
    emit(CategoriesLoading());
    try {
      await categoryRepository.deleteCategory(categoryId);
      emit(CategoryDeleted(categoryId, 'Category deleted successfully'));
      await fetchAllCategories(); // Refresh list
    } catch (e) {
      emit(CategoriesError('Failed to delete category: ${e.toString()}'));
    }
  }

  /// Toggle category active status
  Future<void> toggleCategoryStatus(String categoryId, bool isActive) async {
    try {
      await categoryRepository.toggleCategoryStatus(categoryId, isActive);
      await fetchAllCategories(); // Refresh list
    } catch (e) {
      emit(CategoriesError('Failed to toggle category status: ${e.toString()}'));
    }
  }

  /// Update product count
  Future<void> updateProductCount(String categoryId, int count) async {
    try {
      await categoryRepository.updateProductCount(categoryId, count);
    } catch (e) {
      emit(CategoriesError('Failed to update product count: ${e.toString()}'));
    }
  }
}

