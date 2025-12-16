import '../../domain/entities/product_entity.dart';

/// Products States - For BLoC pattern
/// Represents different states of products management
abstract class ProductsState {}

/// Initial state
class ProductsInitial extends ProductsState {}

/// Loading state
class ProductsLoading extends ProductsState {}

/// Products loaded successfully
class ProductsLoaded extends ProductsState {
  final List<ProductEntity> products;
  
  ProductsLoaded(this.products);
}

/// Product created successfully
class ProductCreated extends ProductsState {
  final ProductEntity product;
  final String message;
  
  ProductCreated(this.product, this.message);
}

/// Product updated successfully
class ProductUpdated extends ProductsState {
  final ProductEntity product;
  final String message;
  
  ProductUpdated(this.product, this.message);
}

/// Product deleted successfully
class ProductDeleted extends ProductsState {
  final String productId;
  final String message;
  
  ProductDeleted(this.productId, this.message);
}

/// Error state
class ProductsError extends ProductsState {
  final String errorMessage;
  
  ProductsError(this.errorMessage);
}

/// Empty state (no products found)
class ProductsEmpty extends ProductsState {}

