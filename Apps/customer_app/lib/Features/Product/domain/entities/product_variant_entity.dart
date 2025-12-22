/// Product Variant Entity - Customer App
/// Represents size/variant options for a product
class ProductVariantEntity {
  final String size;
  final int quantity;
  final String? sku;

  ProductVariantEntity({
    required this.size,
    required this.quantity,
    this.sku,
  });

  /// Create entity from JSON
  factory ProductVariantEntity.fromJson(Map<String, dynamic> json) {
    return ProductVariantEntity(
      size: json['size'] as String,
      quantity: json['quantity'] as int,
      sku: json['sku'] as String?,
    );
  }

  /// Check if variant is available
  bool get isAvailable => quantity > 0;

  /// Check if variant is low in stock
  bool get isLowStock => quantity > 0 && quantity < 10;
}

