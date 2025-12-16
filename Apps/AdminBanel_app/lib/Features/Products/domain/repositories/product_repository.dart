import '../entities/product_entity.dart';

/// Product Repository Interface - Domain Layer
/// Defines the contract for product data operations
abstract class ProductRepository {
  /// Get all products
  Future<List<ProductEntity>> getAllProducts();

  /// Get active products only
  Future<List<ProductEntity>> getActiveProducts();

  /// Get featured products
  Future<List<ProductEntity>> getFeaturedProducts();

  /// Get product by ID
  Future<ProductEntity?> getProductById(String id);

  /// Get products by category
  Future<List<ProductEntity>> getProductsByCategory(String categoryId);

  /// Search products by name
  Future<List<ProductEntity>> searchProducts(String query);

  /// Get low stock products
  Future<List<ProductEntity>> getLowStockProducts();

  /// Get out of stock products
  Future<List<ProductEntity>> getOutOfStockProducts();

  /// Create new product
  Future<void> createProduct(ProductEntity product);

  /// Update existing product
  Future<void> updateProduct(ProductEntity product);

  /// Delete product
  Future<void> deleteProduct(String id);

  /// Toggle product active status
  Future<void> toggleProductStatus(String id, bool isActive);

  /// Toggle product featured status
  Future<void> toggleFeaturedStatus(String id, bool isFeatured);

  /// Update product stock
  Future<void> updateStock(String id, int quantity);

  /// Stream of all products (real-time updates)
  Stream<List<ProductEntity>> watchProducts();
}

