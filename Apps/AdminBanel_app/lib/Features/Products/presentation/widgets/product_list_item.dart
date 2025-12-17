import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';

class ProductListItem extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final Function(String) onMenuAction;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onTap,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildProductImage(),
              const SizedBox(width: 16),
              Expanded(child: _buildProductInfo()),
              _buildPopupMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: product.imageUrls.isNotEmpty
          ? Image.network(
              product.imageUrls.first,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder();
              },
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (product.isFeatured)
              const Icon(Icons.star, color: Colors.amber, size: 18),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStockColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                product.hasVariants 
                    ? 'Total: ${product.totalStock}' 
                    : 'Stock: ${product.stockQuantity}',
                style: TextStyle(
                  fontSize: 11,
                  color: _getStockColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (product.hasVariants) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.straighten, size: 10, color: Colors.purple),
                    const SizedBox(width: 2),
                    Text(
                      '${product.variants?.length ?? 0} sizes',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                product.categoryName,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: onMenuAction,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 20),
              SizedBox(width: 8),
              Text('View Details'),
            ],
          ),
        ),
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(
          value: 'toggle',
          child: Text(product.isActive ? 'Deactivate' : 'Activate'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Color _getStockColor() {
    if (product.stockQuantity == 0) return Colors.red;
    if (product.stockQuantity < 10) return Colors.orange;
    return Colors.green;
  }
}

