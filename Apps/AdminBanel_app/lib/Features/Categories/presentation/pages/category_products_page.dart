import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Products/presentation/cubit/products_cubit.dart';
import '../../../Products/presentation/cubit/products_states.dart';
import '../../../Products/domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../cubit/categories_cubit.dart';

/// Category Products Page
/// View and manage products assigned to a specific category
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
  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Products',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.category.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAssignProductDialog(),
            tooltip: 'Assign Products',
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
            final categoryProducts = state.products
                .where((p) => p.categoryId == widget.category.id)
                .toList();

            if (categoryProducts.isEmpty) {
              return _buildEmptyState();
            }

            return _buildProductsList(categoryProducts);
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
          Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No Products in This Category',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Assign products to ${widget.category.name}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showAssignProductDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Assign Products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<ProductEntity> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withValues(alpha: 0.1),
              child: const Icon(Icons.inventory_2, color: Colors.teal),
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.star, color: Colors.amber, size: 16),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: 'Remove from category',
                  onPressed: () => _confirmRemoveProduct(product),
                ),
              ],
            ),
          ),
        );
      },
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
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignProductDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _AssignProductDialog(
        category: widget.category,
        onProductsAssigned: () {
          context.read<ProductsCubit>().fetchAllProducts();
          context.read<CategoriesCubit>().fetchAllCategories();
        },
      ),
    );
  }

  void _confirmRemoveProduct(ProductEntity product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Product'),
        content: Text(
          'Remove "${product.name}" from "${widget.category.name}"?\n\n'
          'The product will be moved to "Uncategorized".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final productName = product.name;
              final categoryName = widget.category.name;
              final productsCubit = context.read<ProductsCubit>();
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(dialogContext);
              
              final updatedProduct = product.copyWith(
                categoryId: 'uncategorized',
                categoryName: 'Uncategorized',
                updatedAt: DateTime.now(),
              );
              productsCubit.updateProduct(updatedProduct);
              
              // Update category product count
              await _updateCategoryCount();
              
              navigator.pop();
              
              messenger.showSnackBar(
                SnackBar(
                  content: Text('$productName removed from $categoryName'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCategoryCount() async {
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
          .where((p) => p.categoryId == widget.category.id)
          .length;
      await categoriesCubit.updateProductCount(widget.category.id, categoryProductCount);
    }
    
    if (!mounted) return;
    
    // Refresh categories
    await categoriesCubit.fetchAllCategories();
  }
}

/// Dialog to assign products to a category
class _AssignProductDialog extends StatefulWidget {
  final CategoryEntity category;
  final VoidCallback onProductsAssigned;

  const _AssignProductDialog({
    required this.category,
    required this.onProductsAssigned,
  });

  @override
  State<_AssignProductDialog> createState() => _AssignProductDialogState();
}

class _AssignProductDialogState extends State<_AssignProductDialog> {
  final Set<String> _selectedProductIds = {};
  bool _showOnlyUncategorized = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.9 : 600.0;

    return Dialog(
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                          'Assign Products',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'to ${widget.category.name}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
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

            // Filter Toggle
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _showOnlyUncategorized
                          ? 'Showing uncategorized products'
                          : 'Showing all products',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Switch(
                    value: _showOnlyUncategorized,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyUncategorized = value;
                        _selectedProductIds.clear();
                      });
                    },
                    activeTrackColor: Colors.teal.withValues(alpha: 0.5),
                    thumbColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => states.contains(WidgetState.selected) ? Colors.teal : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Products List
            Flexible(
              child: BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is ProductsLoaded) {
                    final availableProducts = state.products.where((p) {
                      if (_showOnlyUncategorized) {
                        return p.categoryId == 'uncategorized' ||
                            p.categoryId.isEmpty;
                      } else {
                        return p.categoryId != widget.category.id;
                      }
                    }).toList();

                    if (availableProducts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _showOnlyUncategorized
                                    ? 'No uncategorized products'
                                    : 'No available products',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: availableProducts.length,
                      itemBuilder: (context, index) {
                        final product = availableProducts[index];
                        final isSelected =
                            _selectedProductIds.contains(product.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedProductIds.add(product.id);
                                } else {
                                  _selectedProductIds.remove(product.id);
                                }
                              });
                            },
                            title: Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('\$${product.price.toStringAsFixed(2)}'),
                                Text(
                                  'Current: ${product.categoryName}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            secondary: CircleAvatar(
                              backgroundColor: Colors.teal.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.inventory_2,
                                color: Colors.teal,
                                size: 20,
                              ),
                            ),
                            activeColor: Colors.teal,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedProductIds.length} selected',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _selectedProductIds.isEmpty
                            ? null
                            : () => _assignProducts(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Assign'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _assignProducts(BuildContext dialogContext) async {
    if (!mounted) return;
    
    final productsCubit = context.read<ProductsCubit>();
    final categoriesCubit = context.read<CategoriesCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(dialogContext);
    final productCount = _selectedProductIds.length;
    final categoryName = widget.category.name;
    final state = productsCubit.state;

    if (state is ProductsLoaded) {
      // Collect old category IDs to update their counts later
      final oldCategoryIds = <String>{};
      
      for (final productId in _selectedProductIds) {
        final product = state.products.firstWhere((p) => p.id == productId);
        oldCategoryIds.add(product.categoryId);
        
        final updatedProduct = product.copyWith(
          categoryId: widget.category.id,
          categoryName: widget.category.name,
          updatedAt: DateTime.now(),
        );
        productsCubit.updateProduct(updatedProduct);
      }

      // Wait for updates to complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Fetch latest products
      await productsCubit.fetchAllProducts();
      
      final updatedState = productsCubit.state;
      if (updatedState is ProductsLoaded) {
        // Update new category count
        final newCategoryProductCount = updatedState.products
            .where((p) => p.categoryId == widget.category.id)
            .length;
        await categoriesCubit.updateProductCount(widget.category.id, newCategoryProductCount);
        
        // Update old categories' counts
        for (final oldCategoryId in oldCategoryIds) {
          if (oldCategoryId != 'uncategorized' && 
              oldCategoryId.isNotEmpty && 
              oldCategoryId != widget.category.id) {
            final oldCategoryProductCount = updatedState.products
                .where((p) => p.categoryId == oldCategoryId)
                .length;
            await categoriesCubit.updateProductCount(oldCategoryId, oldCategoryProductCount);
          }
        }
      }

      if (!mounted) return;

      widget.onProductsAssigned();
      navigator.pop();

      messenger.showSnackBar(
        SnackBar(
          content: Text('$productCount product(s) assigned to $categoryName'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

