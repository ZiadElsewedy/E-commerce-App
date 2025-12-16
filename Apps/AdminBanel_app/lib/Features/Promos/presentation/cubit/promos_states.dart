import '../../domain/entities/promo_entity.dart';

/// Promos States - For BLoC pattern
/// Represents different states of promos management
abstract class PromosState {}

/// Initial state
class PromosInitial extends PromosState {}

/// Loading state
class PromosLoading extends PromosState {}

/// Promos loaded successfully
class PromosLoaded extends PromosState {
  final List<PromoEntity> promos;
  
  PromosLoaded(this.promos);
}

/// Promo created successfully
class PromoCreated extends PromosState {
  final PromoEntity promo;
  final String message;
  
  PromoCreated(this.promo, this.message);
}

/// Promo updated successfully
class PromoUpdated extends PromosState {
  final PromoEntity promo;
  final String message;
  
  PromoUpdated(this.promo, this.message);
}

/// Promo deleted successfully
class PromoDeleted extends PromosState {
  final String promoId;
  final String message;
  
  PromoDeleted(this.promoId, this.message);
}

/// Error state
class PromosError extends PromosState {
  final String errorMessage;
  
  PromosError(this.errorMessage);
}

/// Empty state (no promos found)
class PromosEmpty extends PromosState {}

