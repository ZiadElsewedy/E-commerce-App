import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_states.dart';
import '../../domain/entities/product_entity.dart';
import '../../../Categories/presentation/cubit/categories_cubit.dart';
import '../../../Categories/presentation/cubit/categories_states.dart';
import '../../../Categories/domain/entities/category_entity.dart';
import '../widgets/product_form_sheet.dart';
import '../widgets/product_card_widget.dart';

/// صفحة إدارة المنتجات الحديثة
class ProductsManagementPageModern extends StatefulWidget {
  const ProductsManagementPageModern({super.key});

  @override
  State<ProductsManagementPageModern> createState() => _ProductsManagementPageModernState();
}

class _ProductsManagementPageModernState extends State<ProductsManagementPageModern> {
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().fetchAllProducts();
    context.read<CategoriesCubit>().fetchActiveCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterChips(),
          Expanded(
            child: BlocConsumer<ProductsCubit, ProductsState>(
              listener: _handleStateChanges,
              builder: (context, state) {
                if (state is ProductsLoading || state is ProductsInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductsEmpty) {
                  return _buildEmptyState();
                } else if (state is ProductsLoaded) {
                  return _buildProductsGrid(state.products);
                } else if (state is ProductsError) {
                  return _buildErrorState(state.errorMessage);
                }
                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductSheet,
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'ADD NEW PRODUCT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// رأس الصفحة
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your product inventory',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderActions(),
        ],
      ),
    );
  }

  /// أزرار في رأس الصفحة
  Widget _buildHeaderActions() {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.filter_list_outlined,
          onPressed: _showFilterSheet,
          tooltip: 'Filter',
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.refresh,
          onPressed: () => context.read<ProductsCubit>().fetchAllProducts(),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 20, color: const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  /// فلاتر المنتجات
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All Products', 'all', Icons.inventory_2_outlined),
            _buildFilterChip('Active', 'active', Icons.check_circle_outline),
            _buildFilterChip('Featured', 'featured', Icons.star_outline),
            _buildFilterChip('Low Stock', 'low_stock', Icons.warning_amber_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _currentFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() => _currentFilter = value);
          _applyFilter(value);
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF2563EB),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF475569),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
    );
  }

  /// شبكة المنتجات
  Widget _buildProductsGrid(List products) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(),
        childAspectRatio: 0.75,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCardWidget(
          product: products[index],
          onEdit: () => _showEditProductSheet(products[index]),
          onDelete: () => _showDeleteConfirmation(products[index]),
          onToggleActive: () => _toggleProductActive(products[index]),
          onToggleFeatured: () => _toggleProductFeatured(products[index]),
          onAssignCategory: () => _showAssignCategorySheet(products[index]),
        );
      },
    );
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 5;
    if (width > 1100) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  /// حالة فارغة
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first product',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddProductSheet,
            icon: const Icon(Icons.add),
            label: const Text('Add New Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  /// حالة الخطأ
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error Loading Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.read<ProductsCubit>().fetchAllProducts(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// معالجة تغييرات الحالة
  void _handleStateChanges(BuildContext context, ProductsState state) {
    if (state is ProductCreated) {
      _showSnackBar(state.message, Colors.green);
    } else if (state is ProductsError) {
      _showSnackBar(state.errorMessage, Colors.red);
    } else if (state is ProductDeleted) {
      _showSnackBar(state.message, Colors.orange);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// عرض نموذج إضافة منتج
  void _showAddProductSheet() {
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

  /// عرض نموذج تعديل منتج
  void _showEditProductSheet(ProductEntity product) {
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

  /// عرض نموذج الفلاتر
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption(ctx, 'All Products', Icons.all_inclusive, 'all'),
            _buildFilterOption(ctx, 'Active Products', Icons.check_circle, 'active'),
            _buildFilterOption(ctx, 'Featured Products', Icons.star, 'featured'),
            _buildFilterOption(ctx, 'Low Stock', Icons.warning, 'low_stock'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext ctx,
    String title,
    IconData icon,
    String value,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2563EB)),
      title: Text(title),
      onTap: () {
        Navigator.pop(ctx);
        setState(() => _currentFilter = value);
        _applyFilter(value);
      },
    );
  }

  /// تطبيق الفلتر
  void _applyFilter(String filter) {
    switch (filter) {
      case 'all':
        context.read<ProductsCubit>().fetchAllProducts();
        break;
      case 'active':
        context.read<ProductsCubit>().fetchActiveProducts();
        break;
      case 'featured':
        context.read<ProductsCubit>().fetchFeaturedProducts();
        break;
      case 'low_stock':
        context.read<ProductsCubit>().fetchLowStockProducts();
        break;
    }
  }

  /// تبديل حالة المنتج
  void _toggleProductActive(ProductEntity product) {
    context.read<ProductsCubit>().updateProduct(
          product.copyWith(isActive: !product.isActive),
        );
  }

  /// تبديل حالة مميز
  void _toggleProductFeatured(ProductEntity product) {
    context.read<ProductsCubit>().updateProduct(
          product.copyWith(isFeatured: !product.isFeatured),
        );
  }

  /// عرض تأكيد الحذف
  void _showDeleteConfirmation(ProductEntity product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Text('Delete Product'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"?\n\nThis action cannot be undone.',
        ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// عرض نموذج تعيين الفئة
  void _showAssignCategorySheet(ProductEntity product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AssignCategorySheet(
        product: product,
        onCategoryAssigned: () {
          context.read<ProductsCubit>().fetchAllProducts();
          context.read<CategoriesCubit>().fetchAllCategories();
        },
      ),
    );
  }
}

/// نموذج تعيين الفئة
class _AssignCategorySheet extends StatefulWidget {
  final ProductEntity product;
  final VoidCallback onCategoryAssigned;

  const _AssignCategorySheet({
    required this.product,
    required this.onCategoryAssigned,
  });

  @override
  State<_AssignCategorySheet> createState() => _AssignCategorySheetState();
}

class _AssignCategorySheetState extends State<_AssignCategorySheet> {
  CategoryEntity? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildCategoriesList(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Flexible(
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

          if (state is CategoriesLoaded) {
            final categories = state.categories;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory?.id == category.id;
                return _buildCategoryTile(category, isSelected);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCategoryTile(CategoryEntity category, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => setState(() => _selectedCategory = category),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.category,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${category.productCount} products',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2563EB),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
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
            onPressed: _selectedCategory == null ? null : _assignCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _assignCategory() {
    if (_selectedCategory != null) {
      final updatedProduct = widget.product.copyWith(
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        updatedAt: DateTime.now(),
      );

      context.read<ProductsCubit>().updateProduct(updatedProduct);
      widget.onCategoryAssigned();
      Navigator.pop(context);
    }
  }
}

