/// نموذج متغيرات المنتج (المقاسات والكميات)
/// Product Variant Entity - Represents size variants with quantities
class ProductVariantEntity {
  final String size;
  final int quantity;
  final String? sku; // اختياري: كود المنتج لهذا المقاس

  ProductVariantEntity({
    required this.size,
    required this.quantity,
    this.sku,
  });

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'quantity': quantity,
      if (sku != null) 'sku': sku,
    };
  }

  /// إنشاء من JSON
  factory ProductVariantEntity.fromJson(Map<String, dynamic> json) {
    return ProductVariantEntity(
      size: json['size'] as String,
      quantity: json['quantity'] as int,
      sku: json['sku'] as String?,
    );
  }

  /// نسخ مع تعديلات
  ProductVariantEntity copyWith({
    String? size,
    int? quantity,
    String? sku,
  }) {
    return ProductVariantEntity(
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      sku: sku ?? this.sku,
    );
  }

  /// التحقق من توفر الكمية
  bool get isAvailable => quantity > 0;

  /// التحقق من قلة المخزون
  bool get isLowStock => quantity > 0 && quantity < 10;
}

