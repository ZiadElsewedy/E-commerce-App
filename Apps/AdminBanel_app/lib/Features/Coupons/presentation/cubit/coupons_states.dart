import '../../domain/entities/coupon_entity.dart';

/// Coupons States - For BLoC pattern
/// Represents different states of coupons management
abstract class CouponsState {}

/// Initial state
class CouponsInitial extends CouponsState {}

/// Loading state
class CouponsLoading extends CouponsState {}

/// Coupons loaded successfully
class CouponsLoaded extends CouponsState {
  final List<CouponEntity> coupons;
  
  CouponsLoaded(this.coupons);
}

/// Coupon created successfully
class CouponCreated extends CouponsState {
  final CouponEntity coupon;
  final String message;
  
  CouponCreated(this.coupon, this.message);
}

/// Coupon updated successfully
class CouponUpdated extends CouponsState {
  final CouponEntity coupon;
  final String message;
  
  CouponUpdated(this.coupon, this.message);
}

/// Coupon deleted successfully
class CouponDeleted extends CouponsState {
  final String couponId;
  final String message;
  
  CouponDeleted(this.couponId, this.message);
}

/// Coupon validated successfully
class CouponValidated extends CouponsState {
  final bool isValid;
  final String message;
  
  CouponValidated(this.isValid, this.message);
}

/// Error state
class CouponsError extends CouponsState {
  final String errorMessage;
  
  CouponsError(this.errorMessage);
}

/// Empty state (no coupons found)
class CouponsEmpty extends CouponsState {}

