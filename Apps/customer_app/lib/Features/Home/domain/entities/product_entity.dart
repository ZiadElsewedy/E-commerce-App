/// Product Entity - Customer App
/// Represents a product in the customer-facing app
class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String categoryId;
  final String categoryName;
  final List<String> imageUrls;
  final int stockQuantity;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final Map<String, dynamic>? specifications;
  final List<String>? tags;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrls,
    required this.stockQuantity,
    required this.isActive,
    this.isFeatured = false,
    required this.createdAt,
    this.specifications,
    this.tags,
  });

  /// Create entity from JSON
  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>).cast<String>(),
      stockQuantity: json['stockQuantity'] as int,
      isActive: json['isActive'] as bool,
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      specifications: json['specifications'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Get the current selling price (considers discount)
  double get currentPrice => discountPrice ?? price;

  /// Check if product is on sale
  bool get isOnSale => discountPrice != null && discountPrice! < price;

  /// Calculate discount percentage
  double? get discountPercentage {
    if (!isOnSale) return null;
    return ((price - discountPrice!) / price) * 100;
  }

  /// Check if product is in stock
  bool get isInStock => stockQuantity > 0;

  /// Check if product is low in stock (less than 10 items)
  bool get isLowStock => stockQuantity > 0 && stockQuantity < 10;
}

