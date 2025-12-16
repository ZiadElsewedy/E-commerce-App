import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/promo_entity.dart';
import '../../domain/repositories/promo_repository.dart';
import 'promos_states.dart';

/// Promos Cubit - State Management
/// Manages promos state and business logic
class PromosCubit extends Cubit<PromosState> {
  final PromoRepository promoRepository;

  PromosCubit({required this.promoRepository}) : super(PromosInitial());

  /// Fetch all promos
  Future<void> fetchAllPromos() async {
    emit(PromosLoading());
    try {
      final promos = await promoRepository.getAllPromos();
      if (promos.isEmpty) {
        emit(PromosEmpty());
      } else {
        emit(PromosLoaded(promos));
      }
    } catch (e) {
      emit(PromosError('Failed to fetch promos: ${e.toString()}'));
    }
  }

  /// Fetch active promos only
  Future<void> fetchActivePromos() async {
    emit(PromosLoading());
    try {
      final promos = await promoRepository.getActivePromos();
      if (promos.isEmpty) {
        emit(PromosEmpty());
      } else {
        emit(PromosLoaded(promos));
      }
    } catch (e) {
      emit(PromosError('Failed to fetch active promos: ${e.toString()}'));
    }
  }

  /// Fetch current promos (active and within date range)
  Future<void> fetchCurrentPromos() async {
    emit(PromosLoading());
    try {
      final promos = await promoRepository.getCurrentPromos();
      if (promos.isEmpty) {
        emit(PromosEmpty());
      } else {
        emit(PromosLoaded(promos));
      }
    } catch (e) {
      emit(PromosError('Failed to fetch current promos: ${e.toString()}'));
    }
  }

  /// Get promos by product ID
  Future<void> fetchPromosByProductId(String productId) async {
    emit(PromosLoading());
    try {
      final promos = await promoRepository.getPromosByProductId(productId);
      if (promos.isEmpty) {
        emit(PromosEmpty());
      } else {
        emit(PromosLoaded(promos));
      }
    } catch (e) {
      emit(PromosError('Failed to fetch promos by product: ${e.toString()}'));
    }
  }

  /// Get promos by category ID
  Future<void> fetchPromosByCategoryId(String categoryId) async {
    emit(PromosLoading());
    try {
      final promos = await promoRepository.getPromosByCategoryId(categoryId);
      if (promos.isEmpty) {
        emit(PromosEmpty());
      } else {
        emit(PromosLoaded(promos));
      }
    } catch (e) {
      emit(PromosError('Failed to fetch promos by category: ${e.toString()}'));
    }
  }

  /// Create new promo
  Future<void> createPromo(PromoEntity promo) async {
    emit(PromosLoading());
    try {
      await promoRepository.createPromo(promo);
      emit(PromoCreated(promo, 'Promo created successfully'));
      await fetchAllPromos(); // Refresh list
    } catch (e) {
      emit(PromosError('Failed to create promo: ${e.toString()}'));
    }
  }

  /// Update existing promo
  Future<void> updatePromo(PromoEntity promo) async {
    emit(PromosLoading());
    try {
      await promoRepository.updatePromo(promo);
      emit(PromoUpdated(promo, 'Promo updated successfully'));
      await fetchAllPromos(); // Refresh list
    } catch (e) {
      emit(PromosError('Failed to update promo: ${e.toString()}'));
    }
  }

  /// Delete promo
  Future<void> deletePromo(String promoId) async {
    emit(PromosLoading());
    try {
      await promoRepository.deletePromo(promoId);
      emit(PromoDeleted(promoId, 'Promo deleted successfully'));
      await fetchAllPromos(); // Refresh list
    } catch (e) {
      emit(PromosError('Failed to delete promo: ${e.toString()}'));
    }
  }

  /// Toggle promo active status
  Future<void> togglePromoStatus(String promoId, bool isActive) async {
    try {
      await promoRepository.togglePromoStatus(promoId, isActive);
      await fetchAllPromos(); // Refresh list
    } catch (e) {
      emit(PromosError('Failed to toggle promo status: ${e.toString()}'));
    }
  }
}

