import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

/// Catalog Remote Data Source - Data Layer
/// مصدر بيانات الكتالوج البعيد في طبقة البيانات
class CatalogRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all active categories
  /// جلب جميع الفئات النشطة
  Future<List<CategoryEntity>> getCategories() async {
    try {
      QuerySnapshot snapshot;
      try {
        // Try with orderBy first (if createdAt is Timestamp)
        snapshot = await _firestore
            .collection('categories')
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: false)
            .get();
      } catch (e) {
        // If orderBy fails (e.g., createdAt is String), fetch without orderBy
        snapshot = await _firestore
            .collection('categories')
            .where('isActive', isEqualTo: true)
            .get();
      }

      final categories = snapshot.docs
          .map((doc) => CategoryEntity.fromFirestore(doc))
          .toList();
      
      // Sort manually if needed
      categories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      return categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Fetch products by category
  /// جلب المنتجات حسب الفئة
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    try {
      QuerySnapshot snapshot;
      try {
        // Try with orderBy first (if createdAt is Timestamp)
        snapshot = await _firestore
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If orderBy fails (e.g., createdAt is String), fetch without orderBy
        snapshot = await _firestore
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .where('isActive', isEqualTo: true)
            .get();
      }

      final products = snapshot.docs
          .map((doc) => ProductEntity.fromFirestore(doc))
          .toList();
      
      // Sort manually if needed
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return products;
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  /// Search products by name
  /// البحث عن المنتجات بالاسم
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      final lowerQuery = query.toLowerCase();
      return snapshot.docs
          .map((doc) => ProductEntity.fromFirestore(doc))
          .where((product) =>
              product.name.toLowerCase().contains(lowerQuery) ||
              product.description.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  /// Get product by ID
  /// الحصول على منتج بالمعرف
  Future<ProductEntity?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) return null;
      return ProductEntity.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  /// Get all active products
  /// الحصول على جميع المنتجات النشطة
  Future<List<ProductEntity>> getAllProducts({int limit = 50}) async {
    try {
      QuerySnapshot snapshot;
      try {
        // Try with orderBy first (if createdAt is Timestamp)
        snapshot = await _firestore
            .collection('products')
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      } catch (e) {
        // If orderBy fails (e.g., createdAt is String), fetch without orderBy
        snapshot = await _firestore
            .collection('products')
            .where('isActive', isEqualTo: true)
            .limit(limit)
            .get();
      }

      final products = snapshot.docs
          .map((doc) => ProductEntity.fromFirestore(doc))
          .toList();
      
      // Sort manually if needed
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return products;
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
}

