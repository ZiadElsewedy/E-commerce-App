import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/banner_repository.dart';
import 'banners_states.dart';

/// Banners Cubit - State Management
/// Manages banners state and business logic
class BannersCubit extends Cubit<BannersState> {
  final BannerRepository bannerRepository;

  BannersCubit({required this.bannerRepository}) : super(BannersInitial());

  /// Fetch all banners
  Future<void> fetchAllBanners() async {
    emit(BannersLoading());
    try {
      final banners = await bannerRepository.getAllBanners();
      if (banners.isEmpty) {
        emit(BannersEmpty());
      } else {
        emit(BannersLoaded(banners));
      }
    } catch (e) {
      emit(BannersError('Failed to fetch banners: ${e.toString()}'));
    }
  }

  /// Fetch active banners only
  Future<void> fetchActiveBanners() async {
    emit(BannersLoading());
    try {
      final banners = await bannerRepository.getActiveBanners();
      if (banners.isEmpty) {
        emit(BannersEmpty());
      } else {
        emit(BannersLoaded(banners));
      }
    } catch (e) {
      emit(BannersError('Failed to fetch active banners: ${e.toString()}'));
    }
  }

  /// Get banner by ID
  Future<void> getBannerById(String id) async {
    emit(BannersLoading());
    try {
      final banner = await bannerRepository.getBannerById(id);
      if (banner == null) {
        emit(BannersError('Banner not found'));
      } else {
        emit(BannersLoaded([banner]));
      }
    } catch (e) {
      emit(BannersError('Failed to fetch banner: ${e.toString()}'));
    }
  }

  /// Create new banner
  Future<void> createBanner(BannerEntity banner) async {
    emit(BannersLoading());
    try {
      await bannerRepository.createBanner(banner);
      emit(BannerCreated(banner, 'Banner created successfully'));
      await fetchAllBanners(); // Refresh list
    } catch (e) {
      emit(BannersError('Failed to create banner: ${e.toString()}'));
    }
  }

  /// Update existing banner
  Future<void> updateBanner(BannerEntity banner) async {
    emit(BannersLoading());
    try {
      await bannerRepository.updateBanner(banner);
      emit(BannerUpdated(banner, 'Banner updated successfully'));
      await fetchAllBanners(); // Refresh list
    } catch (e) {
      emit(BannersError('Failed to update banner: ${e.toString()}'));
    }
  }

  /// Delete banner
  Future<void> deleteBanner(String bannerId) async {
    emit(BannersLoading());
    try {
      await bannerRepository.deleteBanner(bannerId);
      emit(BannerDeleted(bannerId, 'Banner deleted successfully'));
      await fetchAllBanners(); // Refresh list
    } catch (e) {
      emit(BannersError('Failed to delete banner: ${e.toString()}'));
    }
  }

  /// Toggle banner active status
  Future<void> toggleBannerStatus(String bannerId, bool isActive) async {
    try {
      await bannerRepository.toggleBannerStatus(bannerId, isActive);
      await fetchAllBanners(); // Refresh list
    } catch (e) {
      emit(BannersError('Failed to toggle banner status: ${e.toString()}'));
    }
  }
}

