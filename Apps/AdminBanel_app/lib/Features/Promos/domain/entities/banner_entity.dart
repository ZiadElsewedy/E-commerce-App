/// Banner Entity - Domain Layer
/// Represents a promotional banner in the e-commerce app
class BannerEntity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final BannerType type;
  final String? actionUrl; // Link or deeplink when banner is clicked
  final String? productId; // Link to specific product
  final String? categoryId; // Link to specific category
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final int priority; // Higher priority shows first
  final DateTime createdAt;
  final DateTime? updatedAt;

  BannerEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    this.actionUrl,
    this.productId,
    this.categoryId,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    this.priority = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert entity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name,
      'actionUrl': actionUrl,
      'productId': productId,
      'categoryId': categoryId,
      'isActive': isActive,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create entity from JSON
  factory BannerEntity.fromJson(Map<String, dynamic> json) {
    // Parse dates with fallbacks for old data
    DateTime parseDate(dynamic dateValue, DateTime fallback) {
      if (dateValue == null) return fallback;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return fallback;
        }
      }
      if (dateValue is DateTime) return dateValue;
      return fallback;
    }

    DateTime? parseDateOptional(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return null;
        }
      }
      if (dateValue is DateTime) return dateValue;
      return null;
    }

    return BannerEntity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Banner',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      type: json['type'] != null
          ? BannerType.values.firstWhere(
              (e) => e.name == json['type'],
              orElse: () => BannerType.main,
            )
          : BannerType.main,
      actionUrl: json['actionUrl'] as String?,
      productId: json['productId'] as String?,
      categoryId: json['categoryId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      startDate: parseDate(json['startDate'], DateTime.now()),
      endDate: parseDate(
        json['endDate'] ?? json['expiresAt'], // Support old 'expiresAt' field
        DateTime.now().add(const Duration(days: 30)),
      ),
      priority: json['priority'] as int? ?? 0,
      createdAt: parseDate(json['createdAt'], DateTime.now()),
      updatedAt: parseDateOptional(json['updatedAt']),
    );
  }

  /// Create copy with modifications
  BannerEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    BannerType? type,
    String? actionUrl,
    String? productId,
    String? categoryId,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      actionUrl: actionUrl ?? this.actionUrl,
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if banner is currently active (within date range)
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Check if banner is expired
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  /// Check if banner hasn't started yet
  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }

  /// Get status badge text
  String get statusText {
    if (isCurrentlyActive) return 'Active';
    if (isUpcoming) return 'Upcoming';
    if (isExpired) return 'Expired';
    return 'Inactive';
  }
}

/// Banner type
enum BannerType {
  main, // Main hero banner
  secondary, // Secondary promotional banner
  category, // Category-specific banner
  product, // Product-specific banner
  seasonal, // Seasonal/Holiday banner
}

