import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/banner_entity.dart';
import '../../../../Database/service/image_picker_service.dart';
import '../../../../Database/service/cloudinary_service.dart';
import '../../../Categories/domain/entities/category_entity.dart';
import '../../../Categories/presentation/cubit/categories_cubit.dart';
import '../../../Categories/presentation/cubit/categories_states.dart';

/// Banner Form Sheet - Add/Edit Banner
/// Modern form with image upload functionality
class BannerFormSheet extends StatefulWidget {
  final BannerEntity? banner;
  final Function(BannerEntity) onSubmit;

  const BannerFormSheet({
    super.key,
    this.banner,
    required this.onSubmit,
  });

  @override
  State<BannerFormSheet> createState() => _BannerFormSheetState();
}

class _BannerFormSheetState extends State<BannerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _actionUrlController;
  late TextEditingController _priorityController;

  bool _isEdit = false;
  bool _isActive = true;
  bool _isSubmitting = false;
  dynamic _selectedImageFile;
  String? _previewImageUrl;
  BannerType _selectedType = BannerType.main;
  CategoryEntity? _selectedCategory;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    _isEdit = widget.banner != null;
    _isActive = widget.banner?.isActive ?? true;
    _selectedType = widget.banner?.type ?? BannerType.main;
    _startDate = widget.banner?.startDate ?? DateTime.now();
    _endDate = widget.banner?.endDate ?? DateTime.now().add(const Duration(days: 30));

    _titleController = TextEditingController(text: widget.banner?.title ?? '');
    _descController = TextEditingController(text: widget.banner?.description ?? '');
    _actionUrlController = TextEditingController(text: widget.banner?.actionUrl ?? '');
    _priorityController = TextEditingController(
      text: widget.banner?.priority.toString() ?? '0',
    );
    _previewImageUrl = widget.banner?.imageUrl;
    
    // Fetch categories and pre-select if editing
    Future.microtask(() async {
      await context.read<CategoriesCubit>().fetchActiveCategories();
      
      // If editing and has categoryId, find and select the category
      if (_isEdit && widget.banner?.categoryId != null) {
        final state = context.read<CategoriesCubit>().state;
        if (state is CategoriesLoaded) {
          try {
            _selectedCategory = state.categories.firstWhere(
              (cat) => cat.id == widget.banner!.categoryId,
            );
            setState(() {});
          } catch (e) {
            // Category not found or inactive, leave as null
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _actionUrlController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    _buildTitleField(),
                    const SizedBox(height: 16),
                    _buildDescriptionField(),
                    const SizedBox(height: 16),
                    _buildTypeDropdown(),
                    const SizedBox(height: 16),
                    _buildActionUrlField(),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),
                    _buildPriorityField(),
                    const SizedBox(height: 16),
                    _buildDateRangePickers(),
                    const SizedBox(height: 16),
                    _buildActiveSwitch(),
                    const SizedBox(height: 200), // Extra padding for bottom buttons
                  ],
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
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
                Text(
                  _isEdit ? 'Edit Banner' : 'Add New Banner',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEdit ? 'Update banner information' : 'Create promotional banner',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.grey.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Banner Image',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red.shade400, Colors.red.shade600],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'REQUIRED',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Recommended: 1920x600px',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_previewImageUrl != null || _selectedImageFile != null)
            _buildImagePreview()
          else
            _buildImagePlaceholder(),
          const SizedBox(height: 16),
          Row(
            children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _selectImage,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 22),
              label: const Text(
                'Choose Banner Image',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ),
              if (_selectedImageFile != null || _previewImageUrl != null) ...[
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => setState(() {
                              _selectedImageFile = null;
                              _previewImageUrl = null;
                            }),
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red.shade700,
                    iconSize: 22,
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 5, // Banner aspect ratio
        child: _selectedImageFile != null
            ? kIsWeb
                ? Image.memory(
                    _selectedImageFile as Uint8List,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    _selectedImageFile as File,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
            : _previewImageUrl != null
                ? Image.network(
                    _previewImageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorImage();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildLoadingImage();
                    },
                  )
                : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Click "Choose Banner Image" to upload',
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PNG, JPG up to 10MB',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image, size: 48, color: Colors.red),
            SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      enabled: !_isSubmitting,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: 'Banner Title',
        hintText: 'e.g., Summer Sale 2024',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.title, color: Colors.grey.shade700, size: 20),
        ),
        suffixIcon: Icon(Icons.edit, color: Colors.grey.shade400, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter banner title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descController,
      enabled: !_isSubmitting,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Brief description of the banner',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.description, color: Colors.grey.shade700, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter description';
        }
        return null;
      },
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<BannerType>(
        value: _selectedType,
        decoration: InputDecoration(
          labelText: 'Banner Type',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.category, color: Colors.grey.shade700, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        items: BannerType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getTypeColor(type),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getBannerTypeLabel(type),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: _isSubmitting
            ? null
            : (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
      ),
    );
  }

  Color _getTypeColor(BannerType type) {
    switch (type) {
      case BannerType.main:
        return Colors.grey.shade800;
      case BannerType.secondary:
        return Colors.grey.shade700;
      case BannerType.category:
        return Colors.grey.shade600;
      case BannerType.product:
        return Colors.grey.shade500;
      case BannerType.seasonal:
        return Colors.grey.shade900;
    }
  }

  Widget _buildActionUrlField() {
    return TextFormField(
      controller: _actionUrlController,
      enabled: !_isSubmitting,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: 'Action URL (Optional)',
        hintText: 'https://example.com/promo',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.link, color: Colors.grey.shade700, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        helperText: 'Link to open when banner is clicked',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      keyboardType: TextInputType.url,
    );
  }

  Widget _buildCategoryDropdown() {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading categories...'),
              ],
            ),
          );
        }

        if (state is CategoriesLoaded) {
          final categories = state.categories;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Target Category (Optional)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a category if this banner is category-specific',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CategoryEntity>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Target Category (Optional)',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.category_outlined, color: Colors.grey.shade700, size: 20),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade700, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  helperText: 'Assign to category-specific',
                ),
                hint: const Text('No category (All products)'),
                items: [
                  const DropdownMenuItem<CategoryEntity>(
                    value: null,
                    child: Text('No category (All products)'),
                  ),
                  ...categories.map((category) {
                    final displayText = category.productCount > 0
                        ? '${category.name} (${category.productCount} products)'
                        : category.name;
                    return DropdownMenuItem<CategoryEntity>(
                      value: category,
                      child: Text(
                        displayText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        setState(() => _selectedCategory = value);
                      },
              ),
              if (_selectedCategory != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Banner will be associated with "${_selectedCategory!.name}" category',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        }

        if (state is CategoriesError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to load categories',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<CategoriesCubit>().fetchActiveCategories();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Default empty state
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Text('No categories available (optional)'),
        );
      },
    );
  }

  Widget _buildPriorityField() {
    return TextFormField(
      controller: _priorityController,
      enabled: !_isSubmitting,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: 'Priority',
        hintText: '0',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.star_outline, color: Colors.grey.shade700, size: 20),
        ),
        suffixIcon: Icon(Icons.arrow_upward, color: Colors.grey.shade400, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        helperText: 'Higher priority banners show first',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildDateRangePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Display Period',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDatePickerCard(
                label: 'Start Date',
                date: _startDate,
                icon: Icons.calendar_today,
                onTap: _selectStartDate,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward, color: Color(0xFF94A3B8)),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDatePickerCard(
                label: 'End Date',
                date: _endDate,
                icon: Icons.event,
                onTap: _selectEndDate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePickerCard({
    required String label,
    required DateTime date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isSubmitting ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility, color: Color(0xFF64748B)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Banner',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Visible to customers',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: _isSubmitting ? null : (value) => setState(() => _isActive = value),
            activeColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_isEdit ? 'Update Banner' : 'Create Banner'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    try {
      final imageFile = await ImagePickerService.pickImage();
      if (imageFile != null) {
        setState(() {
          _selectedImageFile = imageFile;
          _previewImageUrl = null; // Clear URL preview when new file selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate image
    if (_selectedImageFile == null && _previewImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a banner image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String imageUrl = _previewImageUrl ?? '';

      // Upload new image if selected
      if (_selectedImageFile != null) {
        final cloudinaryService = CloudinaryService();
        imageUrl = await cloudinaryService.uploadImage(
          imageFile: _selectedImageFile!,
          folder: 'banners',
        );
      }

      final banner = BannerEntity(
        id: widget.banner?.id ?? '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: imageUrl,
        type: _selectedType,
        actionUrl: _actionUrlController.text.trim().isEmpty
            ? null
            : _actionUrlController.text.trim(),
        categoryId: _selectedCategory?.id,
        isActive: _isActive,
        startDate: _startDate,
        endDate: _endDate,
        priority: int.tryParse(_priorityController.text.trim()) ?? 0,
        createdAt: widget.banner?.createdAt ?? DateTime.now(),
        updatedAt: _isEdit ? DateTime.now() : null,
      );

      widget.onSubmit(banner);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save banner: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getBannerTypeLabel(BannerType type) {
    switch (type) {
      case BannerType.main:
        return 'Main Hero Banner';
      case BannerType.secondary:
        return 'Secondary Promotional';
      case BannerType.category:
        return 'Category Banner';
      case BannerType.product:
        return 'Product Banner';
      case BannerType.seasonal:
        return 'Seasonal/Holiday';
    }
  }
}

