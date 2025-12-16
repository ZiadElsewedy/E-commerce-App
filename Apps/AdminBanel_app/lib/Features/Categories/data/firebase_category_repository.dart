import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/category_entity.dart';
import '../domain/repositories/category_repository.dart';

/// Firebase Category Repository - Data Layer
/// Implements category repository using Cloud Firestore
class FirebaseCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'categories';

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => CategoryEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  @override
  Future<List<CategoryEntity>> getActiveCategories() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => CategoryEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active categories: ${e.toString()}');
    }
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return CategoryEntity.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to fetch category: ${e.toString()}');
    }
  }

  @override
  Future<CategoryEntity?> getCategoryByName(String name) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return CategoryEntity.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id
      });
    } catch (e) {
      throw Exception('Failed to fetch category by name: ${e.toString()}');
    }
  }

  @override
  Future<void> createCategory(CategoryEntity category) async {
    try {
      // Check if category name already exists
      final existing = await getCategoryByName(category.name);
      if (existing != null) {
        throw Exception('Category with this name already exists');
      }

      final data = category.toJson();
      data.remove('id');
      data['createdAt'] = DateTime.now().toIso8601String();
      await _firestore.collection(_collection).add(data);
    } catch (e) {
      throw Exception('Failed to create category: ${e.toString()}');
    }
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    try {
      final data = category.toJson();
      data.remove('id');
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection(_collection).doc(category.id).update(data);
    } catch (e) {
      throw Exception('Failed to update category: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      // Check if category has products
      final category = await getCategoryById(id);
      if (category != null && category.productCount > 0) {
        throw Exception('Cannot delete category with products. Please move or delete products first.');
      }
      
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete category: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleCategoryStatus(String id, bool isActive) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({
            'isActive': isActive,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to toggle category status: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProductCount(String categoryId, int count) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(categoryId)
          .update({
            'productCount': count,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to update product count: ${e.toString()}');
    }
  }

  @override
  Stream<List<CategoryEntity>> watchCategories() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryEntity.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}

