import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/entities/product_entity.dart';
import '../../../Product/presentation/pages/product_details_page.dart';
import '../../../Product/presentation/cubit/product_cubit.dart';
import '../../../Product/data/firebase_product_repository.dart';
import '../widgets/catalog_product_card.dart';
import '../../../Home/domain/entities/product_entity.dart' as HomeProduct;
import '../../../Cart/presentation/cubit/cart_cubit.dart';
import '../../../Wishlist/presentation/cubit/wishlist_cubit.dart';

/// Search Page - Presentation Layer
/// صفحة البحث في طبقة العرض
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductEntity> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Perform search
  /// تنفيذ البحث
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = context.read<CatalogRepository>();
      final products = await repository.searchProducts(query);
      setState(() {
        _results = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search for products...',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      ElevatedButton(
                        onPressed: () => _performSearch(_searchController.text),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Start typing to search'
                                : 'No products found',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final product = _results[index];
                        final cartCubit = context.read<CartCubit>();
                        final wishlistCubit = context.read<WishlistCubit>();
                        final isInWishlist = wishlistCubit.state.containsId(product.id);

                        return CatalogProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => ProductCubit(
                                    repository: FirebaseProductRepository(),
                                  ),
                                  child: ProductDetailsPage(productId: product.id),
                                ),
                              ),
                            );
                          },
                          onAddToCart: () {
                            cartCubit.addProduct(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                              ),
                            );
                          },
                          onToggleWishlist: () {
                            // Convert to Home ProductEntity for wishlist
                            final homeProduct = HomeProduct.ProductEntity(
                              id: product.id,
                              name: product.name,
                              description: product.description,
                              price: product.oldPrice ?? product.price,
                              discountPrice: product.isOnSale ? product.price : null,
                              categoryId: product.categoryId,
                              categoryName: '',
                              imageUrls: product.imageUrls,
                              stockQuantity: product.stock,
                              isActive: product.isActive,
                              createdAt: product.createdAt.toDate(),
                            );
                            wishlistCubit.toggle(homeProduct);
                          },
                          isInWishlist: isInWishlist,
                        );
                      },
                    ),
    );
  }
}

