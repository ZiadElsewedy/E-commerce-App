import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/firebase_home_repository.dart';
import 'home_state.dart';

/// Home Cubit
/// Manages home screen state and data fetching
class HomeCubit extends Cubit<HomeState> {
  final FirebaseHomeRepository repository;

  HomeCubit({required this.repository}) : super(HomeInitial());

  /// Fetch all home screen data
  Future<void> fetchHomeData() async {
    try {
      emit(HomeLoading());

      // Fetch all data in parallel
      final banners = await repository.fetchActiveBanners();
      final categories = await repository.fetchCategories();
      final featuredProducts = await repository.fetchFeaturedProducts(limit: 10);
      final dealsProducts = await repository.fetchDealsProducts(limit: 10);
      final newArrivals = await repository.fetchNewArrivals(limit: 10);

      emit(HomeLoaded(
        banners: banners,
        categories: categories,
        featuredProducts: featuredProducts,
        dealsProducts: dealsProducts,
        newArrivals: newArrivals,
      ));
    } catch (e) {
      emit(HomeError('Failed to load home data: $e'));
    }
  }

  /// Refresh home data
  Future<void> refreshHomeData() async {
    await fetchHomeData();
  }
}

