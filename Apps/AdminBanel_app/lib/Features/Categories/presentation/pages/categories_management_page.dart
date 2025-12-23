import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_states.dart';
import '../../domain/entities/category_entity.dart';
import 'category_products_page.dart';
import 'uncategorized_products_page.dart';
import '../widgets/category_form_sheet.dart';
import '../widgets/category_card_widget.dart';

/// Categories Management Page
/// Admin page for managing product categories (CRUD operations)
class CategoriesManagementPage extends StatefulWidget {
  const CategoriesManagementPage({super.key});

  @override
  State<CategoriesManagementPage> createState() => _CategoriesManagementPageState();
}

class _CategoriesManagementPageState extends State<CategoriesManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().fetchAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.category_outlined, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Category Management',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UncategorizedProductsPage(),
                ),
              );
            },
            tooltip: 'Uncategorized Products',
            color: Colors.white70,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions();
            },
            tooltip: 'Filter Categories',
            color: Colors.white70,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CategoriesCubit>().fetchAllCategories();
            },
            tooltip: 'Refresh Categories',
            color: Colors.white70,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white24,
          ),
        ),
      ),
      body: BlocConsumer<CategoriesCubit, CategoriesState>(
        listener: (context, state) {
          if (state is CategoryCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CategoriesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CategoryDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoriesLoading || state is CategoriesInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoriesEmpty) {
            return _buildEmptyState();
          } else if (state is CategoriesLoaded) {
            return _buildCategoriesList(state.categories);
          } else if (state is CategoriesError) {
            return _buildErrorState(state.errorMessage);
          }
          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddCategorySheet();
        },
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_outlined,
                size: 80,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Categories Yet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start organizing your products by creating your first category. This will help customers find products more easily.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _showAddCategorySheet();
              },
              icon: const Icon(Icons.add),
              label: const Text('Create First Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(List<CategoryEntity> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive column count based on screen width
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth >= 1400) {
          crossAxisCount = 5; // Extra large screens
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4; // Large screens
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 3; // Medium screens
          childAspectRatio = 0.7;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2; // Small tablets/small screens
          childAspectRatio = 0.65;
        } else {
          crossAxisCount = 1; // Mobile
          childAspectRatio = 0.6;
        }

        return GridView.builder(
          padding: EdgeInsets.all(constraints.maxWidth >= 600 ? 24 : 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: constraints.maxWidth >= 600 ? 20 : 16,
            mainAxisSpacing: constraints.maxWidth >= 600 ? 20 : 16,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCardWidget(
              category: category,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CategoryProductsPage(category: category),
                  ),
                );
              },
              onEdit: () => _showEditCategorySheet(category),
              onDelete: () => _showDeleteConfirmation(category),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something Went Wrong',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CategoriesCubit>().fetchAllCategories();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Categories'),
              onTap: () {
                Navigator.pop(context);
                this.context.read<CategoriesCubit>().fetchAllCategories();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Active Categories'),
              onTap: () {
                Navigator.pop(context);
                this.context.read<CategoriesCubit>().fetchActiveCategories();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryFormSheet(
        onSubmit: (category) {
          this.context.read<CategoriesCubit>().createCategory(category);
        },
      ),
    );
  }

  void _showEditCategorySheet(CategoryEntity category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryFormSheet(
        category: category,
        onSubmit: (updatedCategory) {
          this.context.read<CategoriesCubit>().updateCategory(updatedCategory);
        },
      ),
    );
  }

  void _showDeleteConfirmation(CategoryEntity category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\n'
          '${category.productCount > 0 ? 'This category has ${category.productCount} products. Please move or delete them first.' : 'This action cannot be undone.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          if (category.productCount == 0)
            ElevatedButton(
              onPressed: () {
                context.read<CategoriesCubit>().deleteCategory(category.id);
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
}

