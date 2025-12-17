import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/coupon_entity.dart';
import '../../domain/repositories/coupon_repository.dart';
import 'coupons_states.dart';

/// Coupons Cubit - State Management
/// Manages coupons state and business logic
class CouponsCubit extends Cubit<CouponsState> {
  final CouponRepository couponRepository;

  CouponsCubit({required this.couponRepository}) : super(CouponsInitial());

  /// Fetch all coupons
  Future<void> fetchAllCoupons() async {
    emit(CouponsLoading());
    try {
      final coupons = await couponRepository.getAllCoupons();
      if (coupons.isEmpty) {
        emit(CouponsEmpty());
      } else {
        emit(CouponsLoaded(coupons));
      }
    } catch (e) {
      emit(CouponsError('Failed to fetch coupons: ${e.toString()}'));
    }
  }

  /// Fetch active coupons only
  Future<void> fetchActiveCoupons() async {
    emit(CouponsLoading());
    try {
      final coupons = await couponRepository.getActiveCoupons();
      if (coupons.isEmpty) {
        emit(CouponsEmpty());
      } else {
        emit(CouponsLoaded(coupons));
      }
    } catch (e) {
      emit(CouponsError('Failed to fetch active coupons: ${e.toString()}'));
    }
  }

  /// Get coupon by ID
  Future<void> getCouponById(String id) async {
    emit(CouponsLoading());
    try {
      final coupon = await couponRepository.getCouponById(id);
      if (coupon == null) {
        emit(CouponsError('Coupon not found'));
      } else {
        emit(CouponsLoaded([coupon]));
      }
    } catch (e) {
      emit(CouponsError('Failed to fetch coupon: ${e.toString()}'));
    }
  }

  /// Get coupon by code
  Future<void> getCouponByCode(String code) async {
    emit(CouponsLoading());
    try {
      final coupon = await couponRepository.getCouponByCode(code);
      if (coupon == null) {
        emit(CouponsError('Coupon code not found'));
      } else {
        emit(CouponsLoaded([coupon]));
      }
    } catch (e) {
      emit(CouponsError('Failed to fetch coupon: ${e.toString()}'));
    }
  }

  /// Create new coupon
  Future<void> createCoupon(CouponEntity coupon) async {
    emit(CouponsLoading());
    try {
      await couponRepository.createCoupon(coupon);
      emit(CouponCreated(coupon, 'Coupon created successfully'));
      await fetchAllCoupons(); // Refresh list
    } catch (e) {
      emit(CouponsError('Failed to create coupon: ${e.toString()}'));
    }
  }

  /// Update existing coupon
  Future<void> updateCoupon(CouponEntity coupon) async {
    emit(CouponsLoading());
    try {
      await couponRepository.updateCoupon(coupon);
      emit(CouponUpdated(coupon, 'Coupon updated successfully'));
      await fetchAllCoupons(); // Refresh list
    } catch (e) {
      emit(CouponsError('Failed to update coupon: ${e.toString()}'));
    }
  }

  /// Delete coupon
  Future<void> deleteCoupon(String couponId) async {
    emit(CouponsLoading());
    try {
      await couponRepository.deleteCoupon(couponId);
      emit(CouponDeleted(couponId, 'Coupon deleted successfully'));
      await fetchAllCoupons(); // Refresh list
    } catch (e) {
      emit(CouponsError('Failed to delete coupon: ${e.toString()}'));
    }
  }

  /// Toggle coupon active status
  Future<void> toggleCouponStatus(String couponId, bool isActive) async {
    try {
      await couponRepository.toggleCouponStatus(couponId, isActive);
      await fetchAllCoupons(); // Refresh list
    } catch (e) {
      emit(CouponsError('Failed to toggle coupon status: ${e.toString()}'));
    }
  }

  /// Validate coupon code
  Future<void> validateCoupon(String code, double orderAmount) async {
    emit(CouponsLoading());
    try {
      final isValid = await couponRepository.validateCoupon(code, orderAmount);
      if (isValid) {
        emit(CouponValidated(true, 'Coupon is valid'));
      } else {
        emit(CouponValidated(false, 'Coupon is invalid or cannot be applied'));
      }
    } catch (e) {
      emit(CouponsError('Failed to validate coupon: ${e.toString()}'));
    }
  }

  /// Increment coupon usage count
  Future<void> incrementUsageCount(String couponId) async {
    try {
      await couponRepository.incrementUsageCount(couponId);
      await fetchAllCoupons(); // Refresh list
    } catch (e) {
      emit(CouponsError('Failed to increment usage count: ${e.toString()}'));
    }
  }
}

