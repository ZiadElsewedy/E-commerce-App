import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/product_variant_entity.dart';

/// ويدجت إدارة مقاسات المنتج
/// Widget for managing product size variants
class SizeVariantsManager extends StatefulWidget {
  final List<ProductVariantEntity> initialVariants;
  final Function(List<ProductVariantEntity>) onVariantsChanged;
  final bool enabled;

  const SizeVariantsManager({
    super.key,
    required this.initialVariants,
    required this.onVariantsChanged,
    this.enabled = true,
  });

  @override
  State<SizeVariantsManager> createState() => _SizeVariantsManagerState();
}

class _SizeVariantsManagerState extends State<SizeVariantsManager> {
  late List<ProductVariantEntity> _variants;
  final List<String> _commonSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];

  @override
  void initState() {
    super.initState();
    _variants = List.from(widget.initialVariants);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.straighten, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Size Variants',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (widget.enabled)
              ElevatedButton.icon(
                onPressed: _showAddVariantDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Size'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_variants.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.straighten, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No sizes added yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Click "Add Size" to start',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _variants.length,
            itemBuilder: (context, index) {
              final variant = _variants[index];
              return _buildVariantCard(variant, index);
            },
          ),
      ],
    );
  }

  Widget _buildVariantCard(ProductVariantEntity variant, int index) {
    Color quantityColor;
    if (variant.quantity == 0) {
      quantityColor = Colors.red;
    } else if (variant.quantity < 10) {
      quantityColor = Colors.orange;
    } else {
      quantityColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Size Badge
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[200]!, width: 2),
              ),
              child: Center(
                child: Text(
                  variant.size,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Quantity Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Size ${variant.size}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.inventory_2, size: 16, color: quantityColor),
                      const SizedBox(width: 4),
                      Text(
                        'Stock: ${variant.quantity}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: quantityColor,
                        ),
                      ),
                    ],
                  ),
                  if (variant.sku != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'SKU: ${variant.sku}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Actions
            if (widget.enabled)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditVariantDialog(variant, index),
                    tooltip: 'Edit',
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _removeVariant(index),
                    tooltip: 'Delete',
                    color: Colors.red,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showAddVariantDialog() {
    _showVariantDialog(null, -1);
  }

  void _showEditVariantDialog(ProductVariantEntity variant, int index) {
    _showVariantDialog(variant, index);
  }

  void _showVariantDialog(ProductVariantEntity? variant, int index) {
    final isEdit = variant != null;
    final sizeController = TextEditingController(text: variant?.size ?? '');
    final quantityController = TextEditingController(
      text: variant?.quantity.toString() ?? '',
    );
    final skuController = TextEditingController(text: variant?.sku ?? '');
    String? selectedSize = variant?.size;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                isEdit ? Icons.edit : Icons.add_circle,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(isEdit ? 'Edit Size' : 'Add New Size'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select or Enter Size',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Common Sizes Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _commonSizes.map((size) {
                      final isSelected = selectedSize == size;
                      final alreadyExists = _variants.any(
                        (v) => v.size == size && (!isEdit || variant.size != size),
                      );
                      
                      return FilterChip(
                        label: Text(size),
                        selected: isSelected,
                        onSelected: alreadyExists ? null : (selected) {
                          setState(() {
                            if (selected) {
                              selectedSize = size;
                              sizeController.text = size;
                            }
                          });
                        },
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue,
                        disabledColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: alreadyExists
                              ? Colors.grey[400]
                              : (isSelected ? Colors.blue[900] : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Custom Size Input
                  TextFormField(
                    controller: sizeController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Size *',
                      hintText: 'e.g., 42, Large, Free Size',
                      prefixIcon: Icon(Icons.straighten),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      setState(() {
                        selectedSize = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Quantity Input
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      hintText: '0',
                      prefixIcon: Icon(Icons.inventory),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  
                  // SKU Input (Optional)
                  TextFormField(
                    controller: skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU (Optional)',
                      hintText: 'e.g., SHIRT-M-001',
                      prefixIcon: Icon(Icons.qr_code),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final size = sizeController.text.trim();
                final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
                final sku = skuController.text.trim();

                if (size.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a size'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Check for duplicate size (excluding current when editing)
                final isDuplicate = _variants.any(
                  (v) => v.size.toLowerCase() == size.toLowerCase() &&
                      (!isEdit || variant.size.toLowerCase() != size.toLowerCase()),
                );

                if (isDuplicate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Size "$size" already exists'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final newVariant = ProductVariantEntity(
                  size: size,
                  quantity: quantity,
                  sku: sku.isEmpty ? null : sku,
                );

                if (isEdit && index >= 0) {
                  _updateVariant(index, newVariant);
                } else {
                  _addVariant(newVariant);
                }

                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _addVariant(ProductVariantEntity variant) {
    setState(() {
      _variants.add(variant);
      widget.onVariantsChanged(_variants);
    });
  }

  void _updateVariant(int index, ProductVariantEntity variant) {
    setState(() {
      _variants[index] = variant;
      widget.onVariantsChanged(_variants);
    });
  }

  void _removeVariant(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Size'),
        content: Text(
          'Are you sure you want to remove size "${_variants[index].size}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _variants.removeAt(index);
                widget.onVariantsChanged(_variants);
              });
              Navigator.pop(dialogContext);
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
}

