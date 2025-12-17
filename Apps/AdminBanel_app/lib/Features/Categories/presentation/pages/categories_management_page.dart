import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_states.dart';
import '../../domain/entities/category_entity.dart';
import 'category_products_page.dart';
import 'uncategorized_products_page.dart';

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
        title: const Text(
          'Manage Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
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
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CategoriesCubit>().fetchAllCategories();
            },
          ),
        ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog();
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No Categories Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create your first product category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              _showAddCategoryDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
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

  Widget _buildCategoriesList(List<CategoryEntity> categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CategoryProductsPage(category: category),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withValues(alpha: 0.1),
              child: const Icon(Icons.category, color: Colors.teal),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.description),
                const SizedBox(height: 4),
                Text(
                  '${category.productCount} products',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (category.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'view') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CategoryProductsPage(category: category),
                        ),
                      );
                    } else if (value == 'edit') {
                      _showEditCategoryDialog(category);
                    } else if (value == 'toggle') {
                      context.read<CategoriesCubit>().toggleCategoryStatus(
                            category.id,
                            !category.isActive,
                          );
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(category);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2, size: 20, color: Colors.teal),
                          SizedBox(width: 8),
                          Text('View Products'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            category.isActive ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(category.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
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
          Icon(
            Icons.error_outline,
            size: 100,
            color: Colors.red[300],
          ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CategoriesCubit>().fetchAllCategories();
            },
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

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Category'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g., Electronics',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Category description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final category = CategoryEntity(
                  id: '', // Will be generated by Firestore
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  isActive: true,
                  createdAt: DateTime.now(),
                );
                context.read<CategoriesCubit>().createCategory(category);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(CategoryEntity category) {
    final nameController = TextEditingController(text: category.name);
    final descController = TextEditingController(text: category.description);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Category'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final updatedCategory = category.copyWith(
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  updatedAt: DateTime.now(),
                );
                context.read<CategoriesCubit>().updateCategory(updatedCategory);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
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

