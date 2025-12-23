import 'package:flutter/material.dart';
import '../../../Home/presentation/widgets/product_card.dart';
import '../../../Home/domain/entities/product_entity.dart' as HomeProduct;
import '../../domain/entities/product_entity.dart' as CatalogProduct;

/// Catalog Product Card Adapter
/// محول بطاقة منتج الكتالوج
class CatalogProductCard extends StatelessWidget {
  final CatalogProduct.ProductEntity product;
  final Function()? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleWishlist;
  final bool isInWishlist;

  const CatalogProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onToggleWishlist,
    this.isInWishlist = false,
  });

  /// Convert Catalog ProductEntity to Home ProductEntity
  /// تحويل كيان منتج الكتالوج إلى كيان منتج الرئيسية
  HomeProduct.ProductEntity get _homeProduct {
    return HomeProduct.ProductEntity(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.oldPrice ?? product.price,
      discountPrice: product.isOnSale ? product.price : null,
      categoryId: product.categoryId,
      categoryName: '', // Not available in Catalog entity
      imageUrls: product.imageUrls,
      stockQuantity: product.stock,
      isActive: product.isActive,
      isFeatured: false,
      createdAt: product.createdAt.toDate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProductCard(
      product: _homeProduct,
      onTap: onTap,
      onAddToCart: onAddToCart,
      onToggleWishlist: onToggleWishlist,
      isInWishlist: isInWishlist,
    );
  }
}

