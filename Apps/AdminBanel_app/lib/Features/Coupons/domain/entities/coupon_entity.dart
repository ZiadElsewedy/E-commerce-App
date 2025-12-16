/// Coupon Entity - Domain Layer
/// Represents a discount coupon in the e-commerce app
class CouponEntity {
  final String id;
  final String code;
  final String description;
  final CouponType type;
  final double discountValue; // Percentage or fixed amount
  final double? minPurchaseAmount;
  final double? maxDiscountAmount;
  final int? usageLimit;
  final int usageCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;

  CouponEntity({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.discountValue,
    this.minPurchaseAmount,
    this.maxDiscountAmount,
    this.usageLimit,
    this.usageCount = 0,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
  });

  /// Convert entity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'type': type.name,
      'discountValue': discountValue,
      'minPurchaseAmount': minPurchaseAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// Create entity from JSON
  factory CouponEntity.fromJson(Map<String, dynamic> json) {
    return CouponEntity(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      type: CouponType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CouponType.percentage,
      ),
      discountValue: (json['discountValue'] as num).toDouble(),
      minPurchaseAmount: json['minPurchaseAmount'] != null
          ? (json['minPurchaseAmount'] as num).toDouble()
          : null,
      maxDiscountAmount: json['maxDiscountAmount'] != null
          ? (json['maxDiscountAmount'] as num).toDouble()
          : null,
      usageLimit: json['usageLimit'] as int?,
      usageCount: json['usageCount'] as int? ?? 0,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  /// Create copy with modifications
  CouponEntity copyWith({
    String? id,
    String? code,
    String? description,
    CouponType? type,
    double? discountValue,
    double? minPurchaseAmount,
    double? maxDiscountAmount,
    int? usageLimit,
    int? usageCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return CouponEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      type: type ?? this.type,
      discountValue: discountValue ?? this.discountValue,
      minPurchaseAmount: minPurchaseAmount ?? this.minPurchaseAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Check if coupon is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if coupon has reached usage limit
  bool get isUsageLimitReached {
    if (usageLimit == null) return false;
    return usageCount >= usageLimit!;
  }

  /// Check if coupon is valid
  bool get isValid {
    return isActive && !isExpired && !isUsageLimitReached;
  }
}

/// Coupon discount type
enum CouponType {
  percentage, // e.g., 20% off
  fixed, // e.g., $10 off
}

