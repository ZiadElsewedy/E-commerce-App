import '../entities/coupon_entity.dart';

/// Coupon Repository Interface - Domain Layer
/// Defines the contract for coupon data operations
abstract class CouponRepository {
  /// Get all coupons
  Future<List<CouponEntity>> getAllCoupons();

  /// Get active coupons only
  Future<List<CouponEntity>> getActiveCoupons();

  /// Get coupon by ID
  Future<CouponEntity?> getCouponById(String id);

  /// Get coupon by code
  Future<CouponEntity?> getCouponByCode(String code);

  /// Create new coupon
  Future<void> createCoupon(CouponEntity coupon);

  /// Update existing coupon
  Future<void> updateCoupon(CouponEntity coupon);

  /// Delete coupon
  Future<void> deleteCoupon(String id);

  /// Toggle coupon active status
  Future<void> toggleCouponStatus(String id, bool isActive);

  /// Increment coupon usage count
  Future<void> incrementUsageCount(String id);

  /// Validate coupon code
  Future<bool> validateCoupon(String code, double orderAmount);

  /// Stream of all coupons (real-time updates)
  Stream<List<CouponEntity>> watchCoupons();
}

