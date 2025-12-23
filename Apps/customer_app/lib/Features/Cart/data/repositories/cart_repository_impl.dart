import '../../domain/repositories/cart_repository.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../datasources/cart_remote_datasource.dart';

/// Cart Repository Implementation - Data Layer
/// تنفيذ مستودع السلة في طبقة البيانات
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _dataSource;

  CartRepositoryImpl({required CartRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Stream<List<CartItemEntity>> getCartItemsStream(String userId) {
    return _dataSource.getCartItemsStream(userId);
  }

  @override
  Future<List<CartItemEntity>> getCartItems(String userId) async {
    return await _dataSource.getCartItems(userId);
  }

  @override
  Future<void> addToCart(String userId, CartItemEntity item) async {
    return await _dataSource.addToCart(userId, item);
  }

  @override
  Future<void> updateQuantity(String userId, String productId, int qty) async {
    return await _dataSource.updateQuantity(userId, productId, qty);
  }

  @override
  Future<void> removeFromCart(String userId, String productId) async {
    return await _dataSource.removeFromCart(userId, productId);
  }

  @override
  Future<void> clearCart(String userId) async {
    return await _dataSource.clearCart(userId);
  }
}

