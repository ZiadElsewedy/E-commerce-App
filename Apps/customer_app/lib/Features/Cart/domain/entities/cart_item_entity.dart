/// Cart Item Entity - Domain Layer
/// كيان عنصر السلة في طبقة النطاق
class CartItemEntity {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final int qty;
  final String categoryId;

  CartItemEntity({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.qty,
    required this.categoryId,
  });

  /// Parse from Firestore document
  /// تحويل من مستند Firestore
  factory CartItemEntity.fromJson(Map<String, dynamic> json) {
    return CartItemEntity(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      qty: (json['qty'] as int?) ?? 1,
      categoryId: json['categoryId'] as String? ?? '',
    );
  }

  /// Convert to JSON for Firestore
  /// تحويل إلى JSON لـ Firestore
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'qty': qty,
      'categoryId': categoryId,
    };
  }

  /// Calculate line total
  /// حساب الإجمالي للعنصر
  double get lineTotal => price * qty;

  CartItemEntity copyWith({
    String? productId,
    String? name,
    String? imageUrl,
    double? price,
    int? qty,
    String? categoryId,
  }) {
    return CartItemEntity(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
