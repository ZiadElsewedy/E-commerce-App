import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_states.dart';
import '../../domain/entities/product_entity.dart';
import 'product_detail_page.dart';
import '../widgets/product_list_item.dart';
import '../widgets/product_form_sheet.dart';
import '../../../Categories/presentation/cubit/categories_cubit.dart';
import '../../../Categories/presentation/cubit/categories_states.dart';
import '../../../Categories/domain/entities/category_entity.dart';
import 'package:shared_ui/app_theme.dart';

/// Products Management Page
/// Admin page for managing products (CRUD operations)
class ProductsManagementPage extends StatefulWidget {
  const ProductsManagementPage({super.key});

  @override
  State<ProductsManagementPage> createState() => _ProductsManagementPageState();
}

class _ProductsManagementPageState extends State<ProductsManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().fetchAllProducts();
    context.read<CategoriesCubit>().fetchActiveCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Manage Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProductsCubit>().fetchAllProducts(),
          ),
        ],
      ),
      body: BlocConsumer<ProductsCubit, ProductsState>(
        listener: (context, state) {
          if (state is ProductCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is ProductsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
            );
          } else if (state is ProductDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.orange),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductsLoading || state is ProductsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductsEmpty) {
            return _buildEmptyState();
          } else if (state is ProductsLoaded) {
            return _buildProductsList(state.products);
          } else if (state is ProductsError) {
            return _buildErrorState(state.errorMessage);
          }
          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(),
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: Text(AppTheme.isMobile(context) ? 'Add' : 'Add Product'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No Products Found',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),
          Text(
            'Start by adding your first product',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showAddProductDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add New Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductListItem(
          product: product,
          onTap: () => _navigateToProductDetail(product),
          onMenuAction: (value) => _handleMenuAction(value, product),
        );
      },
    );
  }

  void _navigateToProductDetail(ProductEntity product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ProductsCubit>(),
          child: ProductDetailPage(product: product),
        ),
      ),
    );
  }

  void _handleMenuAction(String value, ProductEntity product) {
    if (value == 'view') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<ProductsCubit>(),
            child: ProductDetailPage(product: product),
          ),
        ),
      );
    } else if (value == 'edit') {
      _showEditProductDialog(product);
    } else if (value == 'toggle') {
      context.read<ProductsCubit>().updateProduct(product.copyWith(isActive: !product.isActive));
    } else if (value == 'delete') {
      _showDeleteConfirmation(product);
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 100, color: Colors.red[300]),
          const SizedBox(height: 20),
          Text('Error', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red[700])),
          const SizedBox(height: 10),
          Text(error, style: TextStyle(fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => context.read<ProductsCubit>().fetchAllProducts(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Products'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<ProductsCubit>().fetchAllProducts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Active Products'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<ProductsCubit>().fetchActiveProducts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Featured Products'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<ProductsCubit>().fetchFeaturedProducts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Low Stock'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<ProductsCubit>().fetchLowStockProducts();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFormSheet(
        onSubmit: (product) {
          context.read<ProductsCubit>().createProduct(product);
        },
      ),
    );
  }

  void _showEditProductDialog(ProductEntity product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFormSheet(
        product: product,
        onSubmit: (updatedProduct) {
          context.read<ProductsCubit>().updateProduct(updatedProduct);
        },
      ),
    );
  }

  void _showDeleteConfirmation(ProductEntity product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProductsCubit>().deleteProduct(product.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

}

/// Dialog to assign a category to a product
class _AssignCategoryDialog extends StatefulWidget {
  final ProductEntity product;
  final VoidCallback onCategoryAssigned;

  const _AssignCategoryDialog({
    required this.product,
    required this.onCategoryAssigned,
  });

  @override
  State<_AssignCategoryDialog> createState() => _AssignCategoryDialogState();
}

class _AssignCategoryDialogState extends State<_AssignCategoryDialog> {
  CategoryEntity? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.9 : 500.0;

    return Dialog(
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assign Category',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Current Category Info
            if (widget.product.categoryId != 'uncategorized' && 
                widget.product.categoryId.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.blue.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Current: ${widget.product.categoryName}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Categories List
            Flexible(
              child: BlocBuilder<CategoriesCubit, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is CategoriesError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load categories',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<CategoriesCubit>().fetchActiveCategories();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is CategoriesLoaded) {
                    final categories = state.categories;

                    if (categories.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No categories available',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Please create a category first',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = _selectedCategory?.id == category.id;
                        final isCurrent = widget.product.categoryId == category.id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected
                              ? Colors.teal.withValues(alpha: 0.1)
                              : isCurrent
                                  ? Colors.blue.withValues(alpha: 0.05)
                                  : null,
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? Colors.teal
                                  : isCurrent
                                      ? Colors.blue.withValues(alpha: 0.2)
                                      : Colors.teal.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.category,
                                color: isSelected
                                    ? Colors.white
                                    : isCurrent
                                        ? Colors.blue
                                        : Colors.teal,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: isSelected || isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '${category.productCount} products',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.teal)
                                : isCurrent
                                    ? const Text(
                                        'Current',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    : null,
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _selectedCategory == null
                        ? null
                        : () => _assignCategory(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Assign'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _assignCategory(BuildContext dialogContext) async {
    if (_selectedCategory != null) {
      final oldCategoryId = widget.product.categoryId;
      final productName = widget.product.name;
      final categoryName = _selectedCategory!.name;
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(dialogContext);
      
      final updatedProduct = widget.product.copyWith(
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        updatedAt: DateTime.now(),
      );

      // Update the product
      context.read<ProductsCubit>().updateProduct(updatedProduct);
      
      // Update product counts for both old and new categories
      await _updateCategoryCounts(oldCategoryId, _selectedCategory!.id);
      
      widget.onCategoryAssigned();
      
      if (!mounted) return;
      navigator.pop();

      messenger.showSnackBar(
        SnackBar(
          content: Text('$productName assigned to $categoryName'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _updateCategoryCounts(String oldCategoryId, String newCategoryId) async {
    if (!mounted) return;
    
    final productsCubit = context.read<ProductsCubit>();
    final categoriesCubit = context.read<CategoriesCubit>();
    
    // Wait a moment for the product update to complete
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    // Fetch latest products
    await productsCubit.fetchAllProducts();
    
    final state = productsCubit.state;
    if (state is ProductsLoaded) {
      // Update new category count
      if (newCategoryId != 'uncategorized' && newCategoryId.isNotEmpty) {
        final newCategoryProductCount = state.products
            .where((p) => p.categoryId == newCategoryId)
            .length;
        await categoriesCubit.updateProductCount(newCategoryId, newCategoryProductCount);
      }
      
      // Update old category count if it was a real category
      if (oldCategoryId != 'uncategorized' && 
          oldCategoryId.isNotEmpty && 
          oldCategoryId != newCategoryId) {
        final oldCategoryProductCount = state.products
            .where((p) => p.categoryId == oldCategoryId)
            .length;
        await categoriesCubit.updateProductCount(oldCategoryId, oldCategoryProductCount);
      }
    }
  }
}
