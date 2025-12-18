import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/product_entity.dart';
import '../domain/entities/category_entity.dart';
import '../domain/entities/banner_entity.dart';

/// Firebase Home Repository
/// Handles fetching all home screen data from Firebase
class FirebaseHomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch active banners sorted by priority
  Future<List<BannerEntity>> fetchActiveBanners() async {
    try {
      final querySnapshot = await _firestore
          .collection('banners')
          .where('isActive', isEqualTo: true)
          .orderBy('priority', descending: true)
          .get();

      final banners = querySnapshot.docs
          .map((doc) => BannerEntity.fromJson({...doc.data(), 'id': doc.id}))
          .where((banner) => banner.isCurrentlyActive)
          .toList();

      return banners;
    } catch (e) {
      throw Exception('Failed to fetch banners: $e');
    }
  }

  /// Fetch active categories
  Future<List<CategoryEntity>> fetchCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Fetch featured products
  Future<List<ProductEntity>> fetchFeaturedProducts({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  /// Fetch products by category
  Future<List<ProductEntity>> fetchProductsByCategory(
    String categoryId, {
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  /// Fetch products on sale
  Future<List<ProductEntity>> fetchDealsProducts({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit * 2) // Fetch more to filter
          .get();

      // Filter products with discounts
      final deals = querySnapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .where((product) => product.isOnSale)
          .take(limit)
          .toList();

      return deals;
    } catch (e) {
      throw Exception('Failed to fetch deals: $e');
    }
  }

  /// Fetch new arrivals (recent products)
  Future<List<ProductEntity>> fetchNewArrivals({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch new arrivals: $e');
    }
  }

  /// Fetch all products
  Future<List<ProductEntity>> fetchAllProducts({int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
}

