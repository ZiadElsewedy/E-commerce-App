import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/coupon_entity.dart';
import '../domain/repositories/coupon_repository.dart';

/// Firebase Coupon Repository - Data Layer
/// Implements coupon repository using Cloud Firestore
class FirebaseCouponRepository implements CouponRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'coupons';

  @override
  Future<List<CouponEntity>> getAllCoupons() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CouponEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch coupons: ${e.toString()}');
    }
  }

  @override
  Future<List<CouponEntity>> getActiveCoupons() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => CouponEntity.fromJson({...doc.data(), 'id': doc.id}))
          .where((coupon) => coupon.isValid)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active coupons: ${e.toString()}');
    }
  }

  @override
  Future<CouponEntity?> getCouponById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return CouponEntity.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to fetch coupon: ${e.toString()}');
    }
  }

  @override
  Future<CouponEntity?> getCouponByCode(String code) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('code', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return CouponEntity.fromJson({...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
    } catch (e) {
      throw Exception('Failed to fetch coupon by code: ${e.toString()}');
    }
  }

  @override
  Future<void> createCoupon(CouponEntity coupon) async {
    try {
      // Check if code already exists
      final existing = await getCouponByCode(coupon.code);
      if (existing != null) {
        throw Exception('Coupon code already exists');
      }

      final data = coupon.toJson();
      data['code'] = data['code'].toString().toUpperCase(); // Ensure uppercase
      data.remove('id');
      await _firestore.collection(_collection).add(data);
    } catch (e) {
      throw Exception('Failed to create coupon: ${e.toString()}');
    }
  }

  @override
  Future<void> updateCoupon(CouponEntity coupon) async {
    try {
      final data = coupon.toJson();
      data['code'] = data['code'].toString().toUpperCase();
      data.remove('id');
      await _firestore.collection(_collection).doc(coupon.id).update(data);
    } catch (e) {
      throw Exception('Failed to update coupon: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCoupon(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete coupon: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleCouponStatus(String id, bool isActive) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({'isActive': isActive});
    } catch (e) {
      throw Exception('Failed to toggle coupon status: ${e.toString()}');
    }
  }

  @override
  Future<void> incrementUsageCount(String id) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({'usageCount': FieldValue.increment(1)});
    } catch (e) {
      throw Exception('Failed to increment usage count: ${e.toString()}');
    }
  }

  @override
  Future<bool> validateCoupon(String code, double orderAmount) async {
    try {
      final coupon = await getCouponByCode(code);
      if (coupon == null) return false;
      if (!coupon.isValid) return false;
      if (coupon.minPurchaseAmount != null && orderAmount < coupon.minPurchaseAmount!) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<CouponEntity>> watchCoupons() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CouponEntity.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}

