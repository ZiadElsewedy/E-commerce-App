import '../../domain/entities/banner_entity.dart';

/// Banners States - For BLoC pattern
/// Represents different states of banners management
abstract class BannersState {}

/// Initial state
class BannersInitial extends BannersState {}

/// Loading state
class BannersLoading extends BannersState {}

/// Banners loaded successfully
class BannersLoaded extends BannersState {
  final List<BannerEntity> banners;
  
  BannersLoaded(this.banners);
}

/// Banner created successfully
class BannerCreated extends BannersState {
  final BannerEntity banner;
  final String message;
  
  BannerCreated(this.banner, this.message);
}

/// Banner updated successfully
class BannerUpdated extends BannersState {
  final BannerEntity banner;
  final String message;
  
  BannerUpdated(this.banner, this.message);
}

/// Banner deleted successfully
class BannerDeleted extends BannersState {
  final String bannerId;
  final String message;
  
  BannerDeleted(this.bannerId, this.message);
}

/// Error state
class BannersError extends BannersState {
  final String errorMessage;
  
  BannersError(this.errorMessage);
}

/// Empty state (no banners found)
class BannersEmpty extends BannersState {}

