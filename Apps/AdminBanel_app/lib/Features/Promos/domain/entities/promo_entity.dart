/// Promo Entity - Domain Layer
/// Represents a promotional offer in the e-commerce app
class PromoEntity {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final PromoType type;
  final double discountValue;
  final List<String>? productIds; // Specific products on promo
  final List<String>? categoryIds; // Specific categories on promo
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final int priority;

  PromoEntity({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.type,
    required this.discountValue,
    this.productIds,
    this.categoryIds,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    this.priority = 0,
  });

  /// Convert entity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name,
      'discountValue': discountValue,
      'productIds': productIds,
      'categoryIds': categoryIds,
      'isActive': isActive,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'priority': priority,
    };
  }

  /// Create entity from JSON
  factory PromoEntity.fromJson(Map<String, dynamic> json) {
    return PromoEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      type: PromoType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PromoType.percentage,
      ),
      discountValue: (json['discountValue'] as num).toDouble(),
      productIds: (json['productIds'] as List<dynamic>?)?.cast<String>(),
      categoryIds: (json['categoryIds'] as List<dynamic>?)?.cast<String>(),
      isActive: json['isActive'] as bool,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      priority: json['priority'] as int? ?? 0,
    );
  }

  /// Create copy with modifications
  PromoEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    PromoType? type,
    double? discountValue,
    List<String>? productIds,
    List<String>? categoryIds,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    int? priority,
  }) {
    return PromoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      discountValue: discountValue ?? this.discountValue,
      productIds: productIds ?? this.productIds,
      categoryIds: categoryIds ?? this.categoryIds,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
    );
  }

  /// Check if promo is currently active (within date range)
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Check if promo is expired
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  /// Check if promo hasn't started yet
  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }
}

/// Promo discount type
enum PromoType {
  percentage, // e.g., 30% off
  fixed, // e.g., $50 off
  buyOneGetOne, // BOGO offer
  freeShipping, // Free shipping offer
}

