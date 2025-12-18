import '../entities/banner_entity.dart';

/// Banner Repository Interface - Domain Layer
/// Defines the contract for banner data operations
abstract class BannerRepository {
  /// Get all banners
  Future<List<BannerEntity>> getAllBanners();

  /// Get active banners only
  Future<List<BannerEntity>> getActiveBanners();

  /// Get current banners (active and within date range)
  Future<List<BannerEntity>> getCurrentBanners();

  /// Get banner by ID
  Future<BannerEntity?> getBannerById(String id);

  /// Get banners by type
  Future<List<BannerEntity>> getBannersByType(BannerType type);

  /// Create new banner
  Future<void> createBanner(BannerEntity banner);

  /// Update existing banner
  Future<void> updateBanner(BannerEntity banner);

  /// Delete banner
  Future<void> deleteBanner(String id);

  /// Toggle banner active status
  Future<void> toggleBannerStatus(String id, bool isActive);

  /// Stream of all banners (real-time updates)
  Stream<List<BannerEntity>> watchBanners();
}

