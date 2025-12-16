import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/product_entity.dart';
import '../domain/repositories/product_repository.dart';

/// Firebase Product Repository - Data Layer
/// Implements product repository using Cloud Firestore
class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'products';

  @override
  Future<List<ProductEntity>> getAllProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductEntity>> getActiveProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active products: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductEntity>> getFeaturedProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isFeatured', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured products: ${e.toString()}');
    }
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return ProductEntity.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to fetch product: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      // Note: For better search, consider using Algolia or similar service
      // This is a basic implementation
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final searchLower = query.toLowerCase();
      return snapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .where((product) =>
              product.name.toLowerCase().contains(searchLower) ||
              product.description.toLowerCase().contains(searchLower) ||
              (product.tags?.any((tag) => tag.toLowerCase().contains(searchLower)) ?? false))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductEntity>> getLowStockProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('stockQuantity', isGreaterThan: 0)
          .where('stockQuantity', isLessThan: 10)
          .get();

      return snapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch low stock products: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductEntity>> getOutOfStockProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('stockQuantity', isEqualTo: 0)
          .get();

      return snapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch out of stock products: ${e.toString()}');
    }
  }

  @override
  Future<void> createProduct(ProductEntity product) async {
    try {
      final data = product.toJson();
      data.remove('id');
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection(_collection).add(data);
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    try {
      final data = product.toJson();
      data.remove('id');
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection(_collection).doc(product.id).update(data);
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleProductStatus(String id, bool isActive) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({
            'isActive': isActive,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to toggle product status: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleFeaturedStatus(String id, bool isFeatured) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({
            'isFeatured': isFeatured,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to toggle featured status: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStock(String id, int quantity) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({
            'stockQuantity': quantity,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to update stock: ${e.toString()}');
    }
  }

  @override
  Stream<List<ProductEntity>> watchProducts() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}

