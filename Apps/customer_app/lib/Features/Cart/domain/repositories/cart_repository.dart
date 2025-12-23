import '../entities/cart_item_entity.dart';

/// Cart Repository Interface - Domain Layer
/// واجهة مستودع السلة في طبقة النطاق
abstract class CartRepository {
  /// Get user's cart items stream (real-time updates)
  /// الحصول على دفق عناصر سلة المستخدم (تحديثات فورية)
  Stream<List<CartItemEntity>> getCartItemsStream(String userId);

  /// Get user's cart items (one-time fetch)
  /// الحصول على عناصر سلة المستخدم (جلب لمرة واحدة)
  Future<List<CartItemEntity>> getCartItems(String userId);

  /// Add item to cart
  /// إضافة عنصر إلى السلة
  Future<void> addToCart(String userId, CartItemEntity item);

  /// Update item quantity
  /// تحديث كمية العنصر
  Future<void> updateQuantity(String userId, String productId, int qty);

  /// Remove item from cart
  /// إزالة عنصر من السلة
  Future<void> removeFromCart(String userId, String productId);

  /// Clear cart
  /// تفريغ السلة
  Future<void> clearCart(String userId);
}

