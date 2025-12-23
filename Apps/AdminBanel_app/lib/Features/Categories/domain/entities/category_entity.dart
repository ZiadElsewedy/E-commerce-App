import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

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
  factory CategoryEntity.fromJson(
  Map<String, dynamic> json, {
  required String documentId,
}) {
  return CategoryEntity(
    id: documentId, // ✅ جاي من Firestore doc.id
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    imageUrl: json['imageUrl'] as String?,
    isActive: json['isActive'] ?? true,
    createdAt: _toDateTime(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? _toDateTime(json['updatedAt'])
        : null,
    productCount: json['productCount'] ?? 0,
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

DateTime _toDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  throw Exception('Invalid date type');
}
