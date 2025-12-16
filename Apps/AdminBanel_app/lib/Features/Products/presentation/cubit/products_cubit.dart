import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import 'products_states.dart';

/// Products Cubit - State Management
/// Manages products state and business logic
class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository productRepository;

  ProductsCubit({required this.productRepository}) : super(ProductsInitial());

  /// Fetch all products
  Future<void> fetchAllProducts() async {
    emit(ProductsLoading());
    try {
      final products = await productRepository.getAllProducts();
      if (products.isEmpty) {
        emit(ProductsEmpty());
      } else {
        emit(ProductsLoaded(products));
      }
    } catch (e) {
      emit(ProductsError('Failed to fetch products: ${e.toString()}'));
    }
  }

  /// Fetch active products only
  Future<void> fetchActiveProducts() async {
    emit(ProductsLoading());
    try {
      final products = await productRepository.getActiveProducts();
      if (products.isEmpty) {
        emit(ProductsEmpty());
      } else {
        emit(ProductsLoaded(products));
      }
    } catch (e) {
      emit(ProductsError('Failed to fetch active products: ${e.toString()}'));
    }
  }

  /// Fetch featured products
  Future<void> fetchFeaturedProducts() async {
    emit(ProductsLoading());
    try {
      final products = await productRepository.getFeaturedProducts();
      if (products.isEmpty) {
        emit(ProductsEmpty());
      } else {
        emit(ProductsLoaded(products));
      }
    } catch (e) {
      emit(ProductsError('Failed to fetch featured products: ${e.toString()}'));
    }
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    emit(ProductsLoading());
    try {
      final products = await productRepository.searchProducts(query);
      if (products.isEmpty) {
        emit(ProductsEmpty());
      } else {
        emit(ProductsLoaded(products));
      }
    } catch (e) {
      emit(ProductsError('Failed to search products: ${e.toString()}'));
    }
  }

  /// Get low stock products
  Future<void> fetchLowStockProducts() async {
    emit(ProductsLoading());
    try {
      final products = await productRepository.getLowStockProducts();
      if (products.isEmpty) {
        emit(ProductsEmpty());
      } else {
        emit(ProductsLoaded(products));
      }
    } catch (e) {
      emit(ProductsError('Failed to fetch low stock products: ${e.toString()}'));
    }
  }

  /// Create new product
  Future<void> createProduct(ProductEntity product) async {
    emit(ProductsLoading());
    try {
      await productRepository.createProduct(product);
      emit(ProductCreated(product, 'Product created successfully'));
      await fetchAllProducts(); // Refresh list
    } catch (e) {
      emit(ProductsError('Failed to create product: ${e.toString()}'));
    }
  }

  /// Update existing product
  Future<void> updateProduct(ProductEntity product) async {
    emit(ProductsLoading());
    try {
      await productRepository.updateProduct(product);
      emit(ProductUpdated(product, 'Product updated successfully'));
      await fetchAllProducts(); // Refresh list
    } catch (e) {
      emit(ProductsError('Failed to update product: ${e.toString()}'));
    }
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    emit(ProductsLoading());
    try {
      await productRepository.deleteProduct(productId);
      emit(ProductDeleted(productId, 'Product deleted successfully'));
      await fetchAllProducts(); // Refresh list
    } catch (e) {
      emit(ProductsError('Failed to delete product: ${e.toString()}'));
    }
  }

  /// Toggle product active status
  Future<void> toggleProductStatus(String productId, bool isActive) async {
    try {
      await productRepository.toggleProductStatus(productId, isActive);
      await fetchAllProducts(); // Refresh list
    } catch (e) {
      emit(ProductsError('Failed to toggle product status: ${e.toString()}'));
    }
  }

  /// Toggle product featured status
  Future<void> toggleFeaturedStatus(String productId, bool isFeatured) async {
    try {
      await productRepository.toggleFeaturedStatus(productId, isFeatured);
      await fetchAllProducts(); // Refresh list
    } catch (e) {
      emit(ProductsError('Failed to toggle featured status: ${e.toString()}'));
    }
  }

  /// Update product stock
  Future<void> updateStock(String productId, int quantity) async {
    try {
      await productRepository.updateStock(productId, quantity);
      await fetchAllProducts(); // Refresh list
    } catch (e) {
      emit(ProductsError('Failed to update stock: ${e.toString()}'));
    }
  }
}

