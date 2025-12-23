import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../data/datasources/catalog_remote_datasource.dart';
import '../../../Product/presentation/pages/product_details_page.dart';
import '../../../Product/presentation/cubit/product_cubit.dart';
import '../../../Product/data/firebase_product_repository.dart';
import '../widgets/catalog_product_card.dart';
import '../../../Cart/presentation/cubit/cart_cubit.dart';
import '../../../Wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../../Home/domain/entities/product_entity.dart' as HomeProduct;

/// Category Products Page - Presentation Layer
/// صفحة منتجات الفئة في طبقة العرض
class CategoryProductsPage extends StatefulWidget {
  final CategoryEntity category;

  const CategoryProductsPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  late final CatalogRepositoryImpl _repository;
  List<ProductEntity> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = CatalogRepositoryImpl(
      dataSource: CatalogRemoteDataSource(),
    );
    _loadProducts();
  }

  /// Load products for category
  /// تحميل منتجات الفئة
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _repository.getProductsByCategory(widget.category.id);
      setState(() {
        _products = products;
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
        title: Text(widget.category.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!.replaceAll('Exception: ', ''),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadProducts,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 64),
                          const SizedBox(height: 16),
                          const Text('No products found'),
                          ElevatedButton(
                            onPressed: _loadProducts,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
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
                              SnackBar(content: Text('${product.name} added to cart')),
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

