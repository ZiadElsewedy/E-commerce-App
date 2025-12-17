import '../../domain/entities/category_entity.dart';

/// Categories States - For BLoC pattern
/// Represents different states of categories management
abstract class CategoriesState {}

/// Initial state
class CategoriesInitial extends CategoriesState {}

/// Loading state
class CategoriesLoading extends CategoriesState {}

/// Categories loaded successfully
class CategoriesLoaded extends CategoriesState {
  final List<CategoryEntity> categories;
  
  CategoriesLoaded(this.categories);
}

/// Category created successfully
class CategoryCreated extends CategoriesState {
  final CategoryEntity category;
  final String message;
  
  CategoryCreated(this.category, this.message);
}

/// Category updated successfully
class CategoryUpdated extends CategoriesState {
  final CategoryEntity category;
  final String message;
  
  CategoryUpdated(this.category, this.message);
}

/// Category deleted successfully
class CategoryDeleted extends CategoriesState {
  final String categoryId;
  final String message;
  
  CategoryDeleted(this.categoryId, this.message);
}

/// Error state
class CategoriesError extends CategoriesState {
  final String errorMessage;
  
  CategoriesError(this.errorMessage);
}

/// Empty state (no categories found)
class CategoriesEmpty extends CategoriesState {}

