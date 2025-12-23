import 'package:cloud_firestore/cloud_firestore.dart';

/// Category Entity - Domain Layer
/// كيان الفئة في طبقة النطاق
class CategoryEntity {
  final String id;
  final String name;
  final String imageUrl;
  final Timestamp createdAt;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
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
  factory CategoryEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CategoryEntity(
      id: doc.id,
      name: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      createdAt: CategoryEntity._parseTimestamp(data['createdAt']),
    );
  }

  /// Convert to JSON for Firestore
  /// تحويل إلى JSON لـ Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}

