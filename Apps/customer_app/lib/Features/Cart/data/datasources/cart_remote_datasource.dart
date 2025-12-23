import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cart_item_entity.dart';

/// Cart Remote Data Source - Data Layer
/// مصدر بيانات السلة البعيد في طبقة البيانات
class CartRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user's cart items stream (real-time updates)
  /// الحصول على دفق عناصر سلة المستخدم (تحديثات فورية)
  Stream<List<CartItemEntity>> getCartItemsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartItemEntity.fromJson({
                  ...doc.data(),
                  'productId': doc.id,
                }))
            .toList());
  }

  /// Get user's cart items (one-time fetch)
  /// الحصول على عناصر سلة المستخدم (جلب لمرة واحدة)
  Future<List<CartItemEntity>> getCartItems(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      return snapshot.docs
          .map((doc) => CartItemEntity.fromJson({
                ...doc.data(),
                'productId': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cart items: $e');
    }
  }

  /// Add item to cart
  /// إضافة عنصر إلى السلة
  Future<void> addToCart(String userId, CartItemEntity item) async {
    try {
      final cartRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(item.productId);

      final existingDoc = await cartRef.get();
      if (existingDoc.exists) {
        // Update quantity if item exists
        final currentQty = existingDoc.data()?['qty'] as int? ?? 0;
        await cartRef.update({'qty': currentQty + item.qty});
      } else {
        // Add new item
        await cartRef.set(item.toJson());
      }
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  /// Update item quantity
  /// تحديث كمية العنصر
  Future<void> updateQuantity(
      String userId, String productId, int qty) async {
    try {
      if (qty <= 0) {
        await removeFromCart(userId, productId);
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .update({'qty': qty});
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  /// Remove item from cart
  /// إزالة عنصر من السلة
  Future<void> removeFromCart(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  /// Clear cart
  /// تفريغ السلة
  Future<void> clearCart(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}

