import '../../domain/entities/product_entity.dart';

/// Product State
abstract class ProductState {}

/// Initial state
class ProductInitial extends ProductState {}

/// Loading state
class ProductLoading extends ProductState {}

/// Loaded state with product details
class ProductLoaded extends ProductState {
  final ProductEntity product;
  final List<ProductEntity> relatedProducts;

  ProductLoaded({
    required this.product,
    required this.relatedProducts,
  });
}

/// Error state
class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}

