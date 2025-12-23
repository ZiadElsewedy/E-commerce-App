import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Cart/domain/entities/cart_item_entity.dart';

/// Order Entity - Domain Layer
/// كيان الطلب في طبقة النطاق
class OrderEntity {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final double subtotal;
  final double shipping;
  final double discount;
  final double total;
  final String status; // pending, paid, shipped, delivered, cancelled
  final Map<String, dynamic> address;
  final Timestamp createdAt;

  OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shipping,
    this.discount = 0.0,
    required this.total,
    required this.status,
    required this.address,
    required this.createdAt,
  });

  /// Parse from Firestore document
  /// تحويل من مستند Firestore
  factory OrderEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderEntity(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => CartItemEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (data['shipping'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'pending',
      address: data['address'] as Map<String, dynamic>? ?? {},
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Convert to JSON for Firestore
  /// تحويل إلى JSON لـ Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'discount': discount,
      'total': total,
      'status': status,
      'address': address,
      'createdAt': createdAt,
    };
  }

  /// Check if order is completed
  /// التحقق من اكتمال الطلب
  bool get isCompleted => status == 'delivered';

  /// Check if order is cancelled
  /// التحقق من إلغاء الطلب
  bool get isCancelled => status == 'cancelled';
}

