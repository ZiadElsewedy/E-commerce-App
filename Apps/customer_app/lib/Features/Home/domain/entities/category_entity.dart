/// Category Entity - Customer App
/// Represents a product category
class CategoryEntity {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final int productCount;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    this.productCount = 0,
  });

  /// Create entity from JSON
  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      productCount: json['productCount'] as int? ?? 0,
    );
  }
}

