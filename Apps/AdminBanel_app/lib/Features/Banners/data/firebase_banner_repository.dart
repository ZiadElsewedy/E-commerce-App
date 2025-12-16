import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/banner_entity.dart';
import '../domain/repositories/banner_repository.dart';

/// Firebase Banner Repository - Data Layer
/// Implements banner repository using Cloud Firestore
class FirebaseBannerRepository implements BannerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'banners';

  @override
  Future<List<BannerEntity>> getAllBanners() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('priority', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BannerEntity.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch banners: ${e.toString()}');
    }
  }

  @override
  Future<List<BannerEntity>> getActiveBanners() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('priority', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BannerEntity.fromJson({...doc.data(), 'id': doc.id}))
          .where((banner) => !banner.isExpired)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active banners: ${e.toString()}');
    }
  }

  @override
  Future<BannerEntity?> getBannerById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return BannerEntity.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to fetch banner: ${e.toString()}');
    }
  }

  @override
  Future<void> createBanner(BannerEntity banner) async {
    try {
      final data = banner.toJson();
      data.remove('id'); // Remove ID as Firestore will generate it
      await _firestore.collection(_collection).add(data);
    } catch (e) {
      throw Exception('Failed to create banner: ${e.toString()}');
    }
  }

  @override
  Future<void> updateBanner(BannerEntity banner) async {
    try {
      final data = banner.toJson();
      data.remove('id');
      await _firestore.collection(_collection).doc(banner.id).update(data);
    } catch (e) {
      throw Exception('Failed to update banner: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteBanner(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete banner: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleBannerStatus(String id, bool isActive) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({'isActive': isActive});
    } catch (e) {
      throw Exception('Failed to toggle banner status: ${e.toString()}');
    }
  }

  @override
  Stream<List<BannerEntity>> watchBanners() {
    return _firestore
        .collection(_collection)
        .orderBy('priority', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BannerEntity.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}

