import 'package:cloud_firestore/cloud_firestore.dart';

/// Product Entity - Domain Layer
/// كيان المنتج في طبقة النطاق
class ProductEntity {
  final String id;
  final String name;
  final String description;
  final List<String> imageUrls;
  final double price;
  final double? oldPrice;
  final String categoryId;
  final String? brand;
  final int stock;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final Timestamp createdAt;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.price,
    this.oldPrice,
    required this.categoryId,
    this.brand,
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.isActive,
    required this.createdAt,
  });

  /// Parse Timestamp safely from Firestore
  /// تحليل Timestamp بأمان من Firestore
  static Timestamp _parseTimestamp(dynamic value) {
    if (value == null) return Timestamp.now();
    if (value is Timestamp) return value;
    if (value is DateTime) return Timestamp.fromDate(value);
    if (value is String) {
      try {
        return Timestamp.fromDate(DateTime.parse(value));
      } catch (e) {
        return Timestamp.now();
      }
    }
    return Timestamp.now();
  }

  /// Parse from Firestore document
  /// تحويل من مستند Firestore
  factory ProductEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductEntity(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrls: (data['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (data['oldPrice'] as num?)?.toDouble(),
      categoryId: data['categoryId'] as String? ?? '',
      brand: data['brand'] as String?,
      stock: (data['stock'] as int?) ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as int?) ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: ProductEntity._parseTimestamp(data['createdAt']),
    );
  }

  /// Convert to JSON for Firestore
  /// تحويل إلى JSON لـ Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrls': imageUrls,
      'price': price,
      if (oldPrice != null) 'oldPrice': oldPrice,
      'categoryId': categoryId,
      if (brand != null) 'brand': brand,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  /// Check if product is in stock
  /// التحقق من توفر المنتج
  bool get isInStock => stock > 0;

  /// Check if product is on sale
  /// التحقق من وجود خصم
  bool get isOnSale => oldPrice != null && oldPrice! > price;

  /// Get current selling price
  /// الحصول على سعر البيع الحالي
  double get currentPrice => price;
}

