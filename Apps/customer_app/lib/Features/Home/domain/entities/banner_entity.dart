/// Banner Entity - Customer App
/// Represents a promotional banner
class BannerEntity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final BannerType type;
  final String? actionUrl;
  final String? productId;
  final String? categoryId;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final int priority;

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
  });

  /// Create entity from JSON
  factory BannerEntity.fromJson(Map<String, dynamic> json) {
    // Parse dates with fallbacks
    DateTime parseDate(dynamic dateValue, DateTime fallback) {
      if (dateValue == null) return fallback;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return fallback;
        }
      }
      return fallback;
    }

    return BannerEntity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Banner',
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
        json['endDate'] ?? json['expiresAt'],
        DateTime.now().add(const Duration(days: 30)),
      ),
      priority: json['priority'] as int? ?? 0,
    );
  }

  /// Check if banner is currently active
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
}

/// Banner type
enum BannerType {
  main,
  secondary,
  category,
  product,
  seasonal,
}

