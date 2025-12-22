import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/firebase_product_repository.dart';
import 'product_state.dart';

/// Product Cubit
/// Manages product details state and data fetching
class ProductCubit extends Cubit<ProductState> {
  final FirebaseProductRepository repository;

  ProductCubit({required this.repository}) : super(ProductInitial());

  /// Fetch product details by ID
  Future<void> fetchProductDetails(String productId) async {
    try {
      emit(ProductLoading());

      // Fetch product details
      final product = await repository.fetchProductById(productId);

      // Fetch related products
      final relatedProducts = await repository.fetchRelatedProducts(
        product.categoryId,
        productId,
        limit: 6,
      );

      emit(ProductLoaded(
        product: product,
        relatedProducts: relatedProducts,
      ));
    } catch (e) {
      emit(ProductError('Failed to load product: $e'));
    }
  }

  /// Refresh product details
  Future<void> refreshProduct(String productId) async {
    await fetchProductDetails(productId);
  }
}

