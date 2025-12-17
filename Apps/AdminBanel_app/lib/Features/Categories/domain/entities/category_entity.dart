/// Category Entity - Domain Layer
/// Represents a product category in the e-commerce app
class CategoryEntity {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int productCount; // Number of products in this category

  CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.productCount = 0,
  });

  /// Convert entity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'productCount': productCount,
    };
  }

  /// Create entity from JSON
  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      productCount: json['productCount'] as int? ?? 0,
    );
  }

  /// Create copy with modifications
  CategoryEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? productCount,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productCount: productCount ?? this.productCount,
    );
  }
}

