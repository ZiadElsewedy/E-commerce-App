import '../entities/promo_entity.dart';

/// Promo Repository Interface - Domain Layer
/// Defines the contract for promo data operations
abstract class PromoRepository {
  /// Get all promos
  Future<List<PromoEntity>> getAllPromos();

  /// Get active promos only
  Future<List<PromoEntity>> getActivePromos();

  /// Get current promos (active and within date range)
  Future<List<PromoEntity>> getCurrentPromos();

  /// Get promo by ID
  Future<PromoEntity?> getPromoById(String id);

  /// Get promos by product ID
  Future<List<PromoEntity>> getPromosByProductId(String productId);

  /// Get promos by category ID
  Future<List<PromoEntity>> getPromosByCategoryId(String categoryId);

  /// Create new promo
  Future<void> createPromo(PromoEntity promo);

  /// Update existing promo
  Future<void> updatePromo(PromoEntity promo);

  /// Delete promo
  Future<void> deletePromo(String id);

  /// Toggle promo active status
  Future<void> togglePromoStatus(String id, bool isActive);

  /// Stream of all promos (real-time updates)
  Stream<List<PromoEntity>> watchPromos();
}

