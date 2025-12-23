import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Cart/domain/entities/cart_item_entity.dart';
import '../../../Orders/domain/entities/order_entity.dart';
import '../../../Cart/domain/repositories/cart_repository.dart';
import '../../../Catalog/domain/repositories/catalog_repository.dart';
import 'checkout_state.dart';

/// Checkout Cubit - Presentation Layer
/// مكعب الدفع في طبقة العرض
class CheckoutCubit extends Cubit<CheckoutState> {
  final CartRepository _cartRepository;
  final CatalogRepository _catalogRepository;
  final String _userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CheckoutCubit({
    required CartRepository cartRepository,
    required CatalogRepository catalogRepository,
    String? userId,
  })  : _cartRepository = cartRepository,
        _catalogRepository = catalogRepository,
        _userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '',
        super(const CheckoutState());

  /// Update shipping address fields
  /// تحديث حقول عنوان الشحن
  void updateName(String name) {
    emit(state.copyWith(name: name));
  }

  void updatePhone(String phone) {
    emit(state.copyWith(phone: phone));
  }

  void updateCity(String city) {
    emit(state.copyWith(city: city));
  }

  void updateStreet(String street) {
    emit(state.copyWith(street: street));
  }

  void updateNotes(String? notes) {
    emit(state.copyWith(notes: notes));
  }

  /// Place order
  /// تقديم الطلب
  Future<bool> placeOrder({
    required List<CartItemEntity> items,
    required double subtotal,
    required double shipping,
    double discount = 0.0,
  }) async {
    if (_userId.isEmpty) {
      emit(state.copyWith(errorMessage: 'User not authenticated'));
      return false;
    }

    if (!state.isValid) {
      emit(state.copyWith(errorMessage: 'Please fill all required fields'));
      return false;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Validate stock before placing order
      // التحقق من المخزون قبل تقديم الطلب
      for (var item in items) {
        final product = await _catalogRepository.getProductById(item.productId);
        if (product == null || product.stock < item.qty) {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: '${item.name} is out of stock',
          ));
          return false;
        }
      }

      // Create order
      // إنشاء الطلب
      final order = OrderEntity(
        id: '', // Will be set by Firestore
        userId: _userId,
        items: items,
        subtotal: subtotal,
        shipping: shipping,
        discount: discount,
        total: subtotal + shipping - discount,
        status: 'pending',
        address: {
          'name': state.name,
          'phone': state.phone,
          'city': state.city,
          'street': state.street,
          if (state.notes != null) 'notes': state.notes,
        },
        createdAt: Timestamp.now(),
      );

      // Use batch write to create order and update stock atomically
      // استخدام كتابة مجمعة لإنشاء الطلب وتحديث المخزون بشكل ذري
      final batch = _firestore.batch();

      // Create order
      final orderRef = _firestore.collection('orders').doc();
      batch.set(orderRef, order.toJson());

      // Update product stock
      for (var item in items) {
        final productRef = _firestore.collection('products').doc(item.productId);
        batch.update(productRef, {
          'stock': FieldValue.increment(-item.qty),
        });
      }

      // Commit batch
      await batch.commit();

      // Clear cart
      await _cartRepository.clearCart(_userId);

      emit(state.copyWith(isLoading: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }
}

