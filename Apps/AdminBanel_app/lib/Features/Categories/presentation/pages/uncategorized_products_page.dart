import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Products/presentation/cubit/products_cubit.dart';
import '../../../Products/presentation/cubit/products_states.dart';
import '../../../Products/domain/entities/product_entity.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_states.dart';
import '../../domain/entities/category_entity.dart';

/// Uncategorized Products Page
/// View and manage products that haven't been assigned to a category
class UncategorizedProductsPage extends StatefulWidget {
  const UncategorizedProductsPage({super.key});

  @override
  State<UncategorizedProductsPage> createState() => _UncategorizedProductsPageState();
}

class _UncategorizedProductsPageState extends State<UncategorizedProductsPage> {
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
          'Uncategorized Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductsCubit>().fetchAllProducts();
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state is ProductsLoading || state is ProductsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductsError) {
            return _buildErrorState(state.errorMessage);
          }

          if (state is ProductsLoaded) {
            final uncategorizedProducts = state.products
                .where((p) =>
                    p.categoryId == 'uncategorized' ||
                    p.categoryId.isEmpty)
                .toList();

            if (uncategorizedProducts.isEmpty) {
              return _buildEmptyState();
            }

            return _buildProductsList(uncategorizedProducts);
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 100, color: Colors.green[400]),
          const SizedBox(height: 20),
          Text(
            'All Products Categorized!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Great job! All products have been assigned to categories.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<ProductEntity> products) {
    return Column(
      children: [
        // Info Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.orange.withValues(alpha: 0.1),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Products without categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      '${products.length} product(s) need to be assigned',
                      style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Products List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    child: const Icon(Icons.inventory_2, color: Colors.orange),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\$${product.price.toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      Text(
                        'Stock: ${product.stockQuantity}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton.icon(
                    onPressed: () => _showAssignCategoryDialog(product),
                    icon: const Icon(Icons.category, size: 16),
                    label: const Text('Assign'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 100, color: Colors.red[300]),
          const SizedBox(height: 20),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => context.read<ProductsCubit>().fetchAllProducts(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignCategoryDialog(ProductEntity product) {
    showDialog(
      context: context,
      builder: (dialogContext) => _AssignCategoryDialog(
        product: product,
        onCategoryAssigned: () {
          context.read<ProductsCubit>().fetchAllProducts();
          context.read<CategoriesCubit>().fetchAllCategories();
        },
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
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load categories',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<CategoriesCubit>()
                                    .fetchActiveCategories();
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
                              Icon(
                                Icons.category_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No categories available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
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

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected
                              ? Colors.teal.withValues(alpha: 0.1)
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
                                  : Colors.teal.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.category,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.teal,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '${category.productCount} products',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.teal,
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
      final productName = widget.product.name;
      final categoryName = _selectedCategory!.name;
      final productsCubit = context.read<ProductsCubit>();
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(dialogContext);
      
      final updatedProduct = widget.product.copyWith(
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        updatedAt: DateTime.now(),
      );

      productsCubit.updateProduct(updatedProduct);
      
      // Update category product count
      await _updateCategoryCount(_selectedCategory!.id);
      
      widget.onCategoryAssigned();
      navigator.pop();

      messenger.showSnackBar(
        SnackBar(
          content: Text('$productName assigned to $categoryName'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _updateCategoryCount(String categoryId) async {
    if (!mounted) return;
    
    final productsCubit = context.read<ProductsCubit>();
    final categoriesCubit = context.read<CategoriesCubit>();
    
    // Wait for product update to complete
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    // Fetch latest products
    await productsCubit.fetchAllProducts();
    
    final state = productsCubit.state;
    if (state is ProductsLoaded) {
      // Update category count
      final categoryProductCount = state.products
          .where((p) => p.categoryId == categoryId)
          .length;
      await categoriesCubit.updateProductCount(categoryId, categoryProductCount);
    }
    
    if (!mounted) return;
    
    // Refresh categories
    await categoriesCubit.fetchAllCategories();
  }
}

