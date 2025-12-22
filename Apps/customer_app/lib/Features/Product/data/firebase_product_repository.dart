import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/product_entity.dart';

/// Firebase Product Repository
/// Handles fetching product details from Firebase
class FirebaseProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch product by ID
  Future<ProductEntity> fetchProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();

      if (!doc.exists) {
        throw Exception('Product not found');
      }

      return ProductEntity.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  /// Fetch related products (same category)
  Future<List<ProductEntity>> fetchRelatedProducts(
    String categoryId,
    String currentProductId, {
    int limit = 6,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .limit(limit + 1) // Get one extra to exclude current
          .get();

      return querySnapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .where((product) => product.id != currentProductId)
          .take(limit)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch related products: $e');
    }
  }
}

