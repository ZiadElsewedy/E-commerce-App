import 'package:flutter/material.dart';
import '../../domain/entities/product_variant_entity.dart';

/// Variant Selector Widget
/// Allows user to select product size/variant
class VariantSelector extends StatelessWidget {
  final List<ProductVariantEntity> variants;
  final ProductVariantEntity? selectedVariant;
  final Function(ProductVariantEntity) onVariantSelected;

  const VariantSelector({
    super.key,
    required this.variants,
    this.selectedVariant,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Size',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (selectedVariant != null) ...[
              const SizedBox(width: 8),
              Text(
                '(${selectedVariant!.size})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: variants.map((variant) {
            final isSelected = selectedVariant?.size == variant.size;
            final isAvailable = variant.isAvailable;

            return GestureDetector(
              onTap: isAvailable
                  ? () => onVariantSelected(variant)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? (isSelected ? Colors.grey[800] : Colors.white)
                      : Colors.grey[100],
                  border: Border.all(
                    color: isAvailable
                        ? (isSelected ? Colors.grey[800]! : Colors.grey[300]!)
                        : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      variant.size,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isAvailable
                            ? (isSelected ? Colors.white : Colors.black87)
                            : Colors.grey[400],
                        decoration: isAvailable
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                    if (!isAvailable)
                      Text(
                        'Out',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[400],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (selectedVariant != null && selectedVariant!.isLowStock)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Only ${selectedVariant!.quantity} left in stock!',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

