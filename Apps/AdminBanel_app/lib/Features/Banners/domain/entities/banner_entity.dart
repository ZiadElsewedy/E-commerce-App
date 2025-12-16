/// Banner Entity - Domain Layer
/// Represents a promotional banner in the e-commerce app
class BannerEntity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? linkUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int priority; // Higher priority banners show first

  BannerEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.linkUrl,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
    this.priority = 0,
  });

  /// Convert entity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'priority': priority,
    };
  }

  /// Create entity from JSON
  factory BannerEntity.fromJson(Map<String, dynamic> json) {
    return BannerEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      linkUrl: json['linkUrl'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      priority: json['priority'] as int? ?? 0,
    );
  }

  /// Create copy with modifications
  BannerEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? linkUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? priority,
  }) {
    return BannerEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      priority: priority ?? this.priority,
    );
  }

  /// Check if banner is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

