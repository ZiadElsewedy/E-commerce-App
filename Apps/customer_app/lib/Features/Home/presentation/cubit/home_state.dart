import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

/// Home State
abstract class HomeState {}

/// Initial state
class HomeInitial extends HomeState {}

/// Loading state
class HomeLoading extends HomeState {}

/// Loaded state with all data
class HomeLoaded extends HomeState {
  final List<BannerEntity> banners;
  final List<CategoryEntity> categories;
  final List<ProductEntity> featuredProducts;
  final List<ProductEntity> dealsProducts;
  final List<ProductEntity> newArrivals;

  HomeLoaded({
    required this.banners,
    required this.categories,
    required this.featuredProducts,
    required this.dealsProducts,
    required this.newArrivals,
  });
}

/// Error state
class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}

