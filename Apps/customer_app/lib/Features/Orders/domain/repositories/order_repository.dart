import '../entities/order_entity.dart';

/// Order Repository Interface - Domain Layer
/// واجهة مستودع الطلبات في طبقة النطاق
abstract class OrderRepository {
  /// Create new order
  /// إنشاء طلب جديد
  Future<String> createOrder(OrderEntity order);

  /// Get user's orders
  /// الحصول على طلبات المستخدم
  Future<List<OrderEntity>> getUserOrders(String userId);

  /// Get order by ID
  /// الحصول على طلب بالمعرف
  Future<OrderEntity?> getOrderById(String orderId);

  /// Update order status
  /// تحديث حالة الطلب
  Future<void> updateOrderStatus(String orderId, String status);
}

