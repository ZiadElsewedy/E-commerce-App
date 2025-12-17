import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';

/// بطاقة المنتج الحديثة
class ProductCardWidget extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleFeatured;
  final VoidCallback onAssignCategory;

  const ProductCardWidget({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onToggleFeatured,
    required this.onAssignCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildTitle(),
                  const SizedBox(height: 4),
                  _buildPrice(),
                  const Spacer(),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// صورة المنتج
  Widget _buildImage() {
    return Stack(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            image: product.imageUrls.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(product.imageUrls.first),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: product.imageUrls.isEmpty
              ? const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Color(0xFF94A3B8),
                  ),
                )
              : null,
        ),
        Positioned(
          top: 12,
          right: 12,
          child: _buildMoreMenu(),
        ),
        if (product.isFeatured)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Featured',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!product.isActive)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.black54,
              ),
              child: const Text(
                'INACTIVE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// قائمة الخيارات
  Widget _buildMoreMenu() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(Icons.more_vert, size: 18),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 40),
      itemBuilder: (context) => [
        _buildMenuItem(
          'Edit',
          Icons.edit_outlined,
          'edit',
        ),
        _buildMenuItem(
          product.isActive ? 'Deactivate' : 'Activate',
          product.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          'toggle_active',
        ),
        _buildMenuItem(
          product.isFeatured ? 'Unfeature' : 'Feature',
          Icons.star_outline,
          'toggle_featured',
        ),
        _buildMenuItem(
          'Assign Category',
          Icons.category_outlined,
          'assign_category',
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          'Delete',
          Icons.delete_outline,
          'delete',
          color: Colors.red,
        ),
      ],
      onSelected: _handleMenuSelection,
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String label,
    IconData icon,
    String value, {
    Color? color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? const Color(0xFF475569)),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: color ?? const Color(0xFF1E293B),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'edit':
        onEdit();
        break;
      case 'toggle_active':
        onToggleActive();
        break;
      case 'toggle_featured':
        onToggleFeatured();
        break;
      case 'assign_category':
        onAssignCategory();
        break;
      case 'delete':
        onDelete();
        break;
    }
  }

  /// رأس البطاقة
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getCategoryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              product.categoryName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getCategoryColor(),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStockColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2,
                size: 12,
                color: _getStockColor(),
              ),
              const SizedBox(width: 4),
              Text(
                '${product.stockQuantity}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getStockColor(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// عنوان المنتج
  Widget _buildTitle() {
    return Text(
      product.name,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// السعر
  Widget _buildPrice() {
    return Text(
      '\$${product.price.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2563EB),
      ),
    );
  }

  /// تذييل البطاقة
  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    if (product.categoryId == 'uncategorized' || product.categoryId.isEmpty) {
      return Colors.orange;
    }
    return const Color(0xFF10B981);
  }

  Color _getStockColor() {
    if (product.stockQuantity == 0) {
      return Colors.red;
    } else if (product.stockQuantity < 10) {
      return Colors.orange;
    }
    return const Color(0xFF10B981);
  }
}

