import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/promo_entity.dart';
import '../domain/repositories/promo_repository.dart';

/// Firebase Promo Repository - Data Layer
/// Implements promo repository using Cloud Firestore
class FirebasePromoRepository implements PromoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'promos';

  @override
  Future<List<PromoEntity>> getAllPromos() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('priority', descending: true)
          .orderBy('startDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PromoEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch promos: ${e.toString()}');
    }
  }

  @override
  Future<List<PromoEntity>> getActivePromos() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => PromoEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active promos: ${e.toString()}');
    }
  }

  @override
  Future<List<PromoEntity>> getCurrentPromos() async {
    try {
      // Simplified query to avoid composite index requirement
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      // Filter and sort in memory
      return snapshot.docs
          .map((doc) => PromoEntity.fromJson({...doc.data(), 'id': doc.id}))
          .where((promo) => promo.isCurrentlyActive)
          .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));
    } catch (e) {
      throw Exception('Failed to fetch current promos: ${e.toString()}');
    }
  }

  @override
  Future<PromoEntity?> getPromoById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return PromoEntity.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to fetch promo: ${e.toString()}');
    }
  }

  @override
  Future<List<PromoEntity>> getPromosByProductId(String productId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('productIds', arrayContains: productId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => PromoEntity.fromJson({...doc.data(), 'id': doc.id}))
          .where((promo) => promo.isCurrentlyActive)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch promos by product: ${e.toString()}');
    }
  }

  @override
  Future<List<PromoEntity>> getPromosByCategoryId(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('categoryIds', arrayContains: categoryId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => PromoEntity.fromJson({...doc.data(), 'id': doc.id}))
          .where((promo) => promo.isCurrentlyActive)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch promos by category: ${e.toString()}');
    }
  }

  @override
  Future<void> createPromo(PromoEntity promo) async {
    try {
      final data = promo.toJson();
      data.remove('id');
      await _firestore.collection(_collection).add(data);
    } catch (e) {
      throw Exception('Failed to create promo: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePromo(PromoEntity promo) async {
    try {
      final data = promo.toJson();
      data.remove('id');
      await _firestore.collection(_collection).doc(promo.id).update(data);
    } catch (e) {
      throw Exception('Failed to update promo: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePromo(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete promo: ${e.toString()}');
    }
  }

  @override
  Future<void> togglePromoStatus(String id, bool isActive) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({'isActive': isActive});
    } catch (e) {
      throw Exception('Failed to toggle promo status: ${e.toString()}');
    }
  }

  @override
  Stream<List<PromoEntity>> watchPromos() {
    return _firestore
        .collection(_collection)
        .orderBy('priority', descending: true)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PromoEntity.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}

