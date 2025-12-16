import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_states.dart';
import '../../domain/entities/category_entity.dart';

/// Category Selector Widget
/// Dropdown for selecting a category when creating/editing products
class CategorySelector extends StatefulWidget {
  final String? initialCategoryId;
  final String? initialCategoryName;
  final Function(String categoryId, String categoryName) onCategorySelected;
  final String? labelText;
  final bool isRequired;

  const CategorySelector({
    super.key,
    this.initialCategoryId,
    this.initialCategoryName,
    required this.onCategorySelected,
    this.labelText,
    this.isRequired = true,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  CategoryEntity? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Load categories when widget initializes
    context.read<CategoriesCubit>().fetchActiveCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is CategoriesError) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Failed to load categories',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CategoriesCubit>().fetchActiveCategories();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is CategoriesEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No categories found',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please create a category first before adding products.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Close the current dialog and navigate to categories page
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/categories');
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Category'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is CategoriesLoaded) {
          final categories = state.categories;

          // Set initial category if provided
          if (_selectedCategory == null &&
              widget.initialCategoryId != null &&
              widget.initialCategoryName != null) {
            _selectedCategory = categories.firstWhere(
              (cat) => cat.id == widget.initialCategoryId,
              orElse: () => categories.first,
            );
          }

          return DropdownButtonFormField<CategoryEntity>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: widget.labelText ?? 'Select Category',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            hint: const Text('Choose a category'),
            items: categories.map((category) {
              return DropdownMenuItem<CategoryEntity>(
                value: category,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${category.productCount} products',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            validator: widget.isRequired
                ? (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  }
                : null,
            onChanged: (CategoryEntity? newCategory) {
              if (newCategory != null) {
                setState(() {
                  _selectedCategory = newCategory;
                });
                widget.onCategorySelected(newCategory.id, newCategory.name);
              }
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

