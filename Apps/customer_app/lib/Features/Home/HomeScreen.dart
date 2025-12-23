// home screen for the app
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/cubit/home_cubit.dart';
import 'presentation/cubit/home_state.dart';
import 'presentation/widgets/banner_carousel.dart';
import 'presentation/widgets/category_list.dart';
import 'presentation/widgets/product_card.dart';
import 'presentation/widgets/product_grid_item.dart';
import '../Cart/presentation/cubit/cart_cubit.dart';
import '../Cart/presentation/cubit/cart_state.dart';
import '../Wishlist/presentation/cubit/wishlist_cubit.dart';
import 'domain/entities/product_entity.dart';
import '../Product/presentation/pages/product_details_page.dart';
import '../Product/presentation/cubit/product_cubit.dart';
import '../Product/data/firebase_product_repository.dart';
import '../Profile/Presentation/pages/profile_page.dart';
import '../Cart/presentation/pages/cart_page.dart';
import '../Wishlist/presentation/pages/wishlist_page.dart';
import '../Catalog/presentation/pages/search_page.dart';
import '../Catalog/presentation/pages/category_products_page.dart';
import '../Catalog/domain/entities/category_entity.dart' as CatalogCategory;
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch home data on init
    context.read<HomeCubit>().fetchHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.storefront_rounded,
              color: Colors.grey[800],
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'E-Shop',
              style: TextStyle(
                color: Colors.grey[900],
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
            icon: Icon(Icons.search, color: Colors.grey[800]),
          ),
          BlocBuilder<WishlistCubit, WishlistState>(
            builder: (context, wishlistState) {
              final hasItems = wishlistState.items.isNotEmpty;
              return IconButton(
                onPressed: _navigateToWishlist,
                icon: Icon(
                  hasItems ? Icons.favorite : Icons.favorite_border,
                  color: hasItems ? Colors.red : Colors.grey[800],
                ),
              );
            },
          ),
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              final count = cartState.totalItems;
              return IconButton(
                onPressed: _navigateToCart,
            icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text(count.toString()),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.grey[800],
                  ),
            ),
              );
            },
          ),
          IconButton(
            onPressed: () {
              _navigateToProfile();
            },
            icon: Icon(Icons.person_outline, color: Colors.grey[800]),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return _buildErrorView(state.message);
          }

          if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().refreshHomeData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Search Bar
                    _buildSearchBar(),
                    
                    const SizedBox(height: 20),
                    
                    // Banners Carousel
                    if (state.banners.isNotEmpty)
                      BannerCarousel(
                        banners: state.banners,
                        onBannerTap: (banner) {
                          // TODO: Handle banner tap
                        },
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Categories
                    if (state.categories.isNotEmpty)
                      CategoryList(
                        categories: state.categories,
                        onCategoryTap: (homeCategory) {
                          // Convert Home CategoryEntity to Catalog CategoryEntity
                          // تحويل كيان فئة الرئيسية إلى كيان فئة الكتالوج
                          final catalogCategory = CatalogCategory.CategoryEntity(
                            id: homeCategory.id,
                            name: homeCategory.name,
                            imageUrl: homeCategory.imageUrl ?? '',
                            createdAt: Timestamp.fromDate(homeCategory.createdAt),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryProductsPage(
                                category: catalogCategory,
                              ),
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Deals Section
                    if (state.dealsProducts.isNotEmpty) ...[
                      _buildSectionHeader(
                        title: '⚡ Flash Deals',
                        subtitle: 'Limited time offers',
                        onViewAll: () {
                          // TODO: Navigate to all deals
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildProductGrid(state.dealsProducts),
                      const SizedBox(height: 24),
                    ],
                    
                    // Featured Products
                    if (state.featuredProducts.isNotEmpty) ...[
                      _buildSectionHeader(
                        title: 'Featured Products',
                        subtitle: 'Handpicked for you',
                        onViewAll: () {
                          // TODO: Navigate to featured products
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildProductGrid(state.featuredProducts),
                      const SizedBox(height: 24),
                    ],
                    
                    // New Arrivals
                    if (state.newArrivals.isNotEmpty) ...[
                      _buildSectionHeader(
                        title: 'New Arrivals',
                        subtitle: 'Just landed',
                        onViewAll: () {
                          // TODO: Navigate to new arrivals
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildProductGrid(state.newArrivals),
                      const SizedBox(height: 24),
                    ],
                    
                    // Bottom Padding
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchPage(),
            ),
          );
        },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
              Icon(Icons.search, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Text(
              'Search for products...',
              style: TextStyle(
                color: Colors.grey[500],
                  fontSize: 14,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader({
    required String title,
    String? subtitle,
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Product Grid - Square Cards (2 columns)
  Widget _buildProductGrid(List products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index] as ProductEntity;
        return _buildProductGridItem(product);
      },
    );
  }

  // Build product grid item
  Widget _buildProductGridItem(ProductEntity product) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, wishlistState) {
        final isInWishlist = wishlistState.contains(product);

        return ProductGridItem(
          product: product,
          isInWishlist: isInWishlist,
          onTap: () => _navigateToProduct(product.id),
        );
      },
    );
  }

  // Navigate to Product Details
  void _navigateToProduct(String productId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ProductCubit(
            repository: FirebaseProductRepository(),
          ),
          child: ProductDetailsPage(productId: productId),
        ),
      ),
    );
  }

  // Navigate to Profile
  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  void _navigateToCart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CartPage(),
      ),
    );
  }

  void _navigateToWishlist() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WishlistPage(),
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, wishlistState) {
        final isInWishlist = wishlistState.contains(product);

        return ProductCard(
          product: product,
          isInWishlist: isInWishlist,
          onTap: () => _navigateToProduct(product.id),
          onAddToCart: () {
            context.read<CartCubit>().addHomeProduct(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} added to cart'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onToggleWishlist: () {
            context.read<WishlistCubit>().toggle(product);
          },
        );
      },
    );
  }

  // Error View
  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<HomeCubit>().fetchHomeData();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}