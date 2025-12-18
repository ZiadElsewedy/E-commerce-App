import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../domain/entities/promo_entity.dart';
import '../../../../Database/service/image_picker_service.dart';
import '../../../../Database/service/cloudinary_service.dart';

/// Promo Form Sheet - Add/Edit Promo
/// Modern form with optional image upload functionality
class PromoFormSheet extends StatefulWidget {
  final PromoEntity? promo;
  final Function(PromoEntity) onSubmit;

  const PromoFormSheet({
    super.key,
    this.promo,
    required this.onSubmit,
  });

  @override
  State<PromoFormSheet> createState() => _PromoFormSheetState();
}

class _PromoFormSheetState extends State<PromoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _discountController;
  late TextEditingController _priorityController;

  bool _isEdit = false;
  bool _isActive = true;
  bool _isSubmitting = false;
  dynamic _selectedImageFile;
  String? _previewImageUrl;
  PromoType _selectedType = PromoType.percentage;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _isEdit = widget.promo != null;
    _isActive = widget.promo?.isActive ?? true;
    _selectedType = widget.promo?.type ?? PromoType.percentage;
    _startDate = widget.promo?.startDate ?? DateTime.now();
    _endDate = widget.promo?.endDate ?? DateTime.now().add(const Duration(days: 7));

    _titleController = TextEditingController(text: widget.promo?.title ?? '');
    _descController = TextEditingController(text: widget.promo?.description ?? '');
    _discountController = TextEditingController(
      text: widget.promo?.discountValue.toString() ?? '',
    );
    _priorityController = TextEditingController(
      text: widget.promo?.priority.toString() ?? '0',
    );
    _previewImageUrl = widget.promo?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _discountController.dispose();
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
                    _buildTypeAndDiscountRow(),
                    const SizedBox(height: 16),
                    _buildPriorityField(),
                    const SizedBox(height: 16),
                    _buildDateRangePickers(),
                    const SizedBox(height: 16),
                    _buildActiveSwitch(),
                    const SizedBox(height: 100),
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
                  _isEdit ? 'Edit Promo' : 'Add New Promo',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEdit ? 'Update promo information' : 'Create promotional offer',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Promo Image',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Optional',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_previewImageUrl != null || _selectedImageFile != null)
          _buildImagePreview()
        else
          _buildImagePlaceholder(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _selectImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Select Image (Optional)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF10B981)),
                  foregroundColor: const Color(0xFF10B981),
                ),
              ),
            ),
            if (_selectedImageFile != null || _previewImageUrl != null) ...[
              const SizedBox(width: 12),
              IconButton(
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() {
                          _selectedImageFile = null;
                          _previewImageUrl = null;
                        }),
                icon: const Icon(Icons.delete_outline),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _selectedImageFile != null
          ? kIsWeb
              ? Image.memory(
                  _selectedImageFile as Uint8List,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  _selectedImageFile as File,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
          : _previewImageUrl != null
              ? Image.network(
                  _previewImageUrl!,
                  height: 180,
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
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 8),
            Text(
              'No promo image',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image, size: 40, color: Colors.red),
            SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      height: 180,
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
      decoration: InputDecoration(
        labelText: 'Promo Title *',
        hintText: 'e.g., Black Friday Sale',
        prefixIcon: const Icon(Icons.local_offer),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter promo title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descController,
      enabled: !_isSubmitting,
      decoration: InputDecoration(
        labelText: 'Description *',
        hintText: 'Promo description',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
      maxLines: 2,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter description';
        }
        return null;
      },
    );
  }

  Widget _buildTypeAndDiscountRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<PromoType>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Discount Type *',
              prefixIcon: const Icon(Icons.discount),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
            items: PromoType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getPromoTypeLabel(type)),
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
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _discountController,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: _selectedType == PromoType.percentage ? 'Percentage *' : 'Amount *',
              hintText: _selectedType == PromoType.percentage ? '0-100' : '0.00',
              prefixIcon: Icon(
                _selectedType == PromoType.percentage ? Icons.percent : Icons.attach_money,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter value';
              }
              final discount = double.tryParse(value);
              if (discount == null) {
                return 'Invalid';
              }
              if (_selectedType == PromoType.percentage && discount > 100) {
                return 'Max 100%';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityField() {
    return TextFormField(
      controller: _priorityController,
      enabled: !_isSubmitting,
      decoration: InputDecoration(
        labelText: 'Priority',
        hintText: '0',
        prefixIcon: const Icon(Icons.star),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        helperText: 'Higher priority promos show first',
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
          'Promo Period',
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
                  'Active Promo',
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
                backgroundColor: const Color(0xFF10B981),
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
                  : Text(_isEdit ? 'Update Promo' : 'Create Promo'),
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
          _previewImageUrl = null;
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl = _previewImageUrl;

      // Upload new image if selected
      if (_selectedImageFile != null) {
        final cloudinaryService = CloudinaryService();
        imageUrl = await cloudinaryService.uploadImage(
          imageFile: _selectedImageFile!,
          folder: 'promos',
        );
      }

      final promo = PromoEntity(
        id: widget.promo?.id ?? '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: imageUrl,
        type: _selectedType,
        discountValue: double.parse(_discountController.text.trim()),
        isActive: _isActive,
        startDate: _startDate,
        endDate: _endDate,
        priority: int.tryParse(_priorityController.text.trim()) ?? 0,
      );

      widget.onSubmit(promo);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save promo: $e'),
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

  String _getPromoTypeLabel(PromoType type) {
    switch (type) {
      case PromoType.percentage:
        return 'Percentage';
      case PromoType.fixed:
        return 'Fixed Amount';
      case PromoType.buyOneGetOne:
        return 'BOGO';
      case PromoType.freeShipping:
        return 'Free Shipping';
    }
  }
}

