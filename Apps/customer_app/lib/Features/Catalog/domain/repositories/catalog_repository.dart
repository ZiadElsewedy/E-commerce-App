import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

/// Catalog Repository Interface - Domain Layer
/// واجهة مستودع الكتالوج في طبقة النطاق
abstract class CatalogRepository {
  /// Fetch all active categories
  /// جلب جميع الفئات النشطة
  Future<List<CategoryEntity>> getCategories();

  /// Fetch products by category
  /// جلب المنتجات حسب الفئة
  Future<List<ProductEntity>> getProductsByCategory(String categoryId);

  /// Search products by name
  /// البحث عن المنتجات بالاسم
  Future<List<ProductEntity>> searchProducts(String query);

  /// Get product by ID
  /// الحصول على منتج بالمعرف
  Future<ProductEntity?> getProductById(String productId);

  /// Get all active products
  /// الحصول على جميع المنتجات النشطة
  Future<List<ProductEntity>> getAllProducts({int limit = 50});
}

