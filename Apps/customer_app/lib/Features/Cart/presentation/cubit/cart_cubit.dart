import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../../Catalog/domain/entities/product_entity.dart' as CatalogProduct;
import '../../../Home/domain/entities/product_entity.dart' as HomeProduct;
import '../../../Product/domain/entities/product_entity.dart' as ProductFeature;
import 'cart_state.dart';
import 'dart:async';

/// Cart Cubit - Presentation Layer
/// مكعب السلة في طبقة العرض
class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;
  String _userId;
  StreamSubscription<List<CartItemEntity>>? _cartSubscription;
  StreamSubscription<User?>? _authSubscription;

  CartCubit({
    required CartRepository repository,
    String? userId,
  })  : _repository = repository,
        _userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '',
        super(const CartState()) {
    _init();
  }

  /// Initialize cart listener
  /// تهيئة مستمع السلة
  void _init() {
    // Listen to auth state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && user.uid != _userId) {
        _userId = user.uid;
        _listenToCart();
      } else if (user == null) {
        _userId = '';
        _cartSubscription?.cancel();
        emit(const CartState(items: []));
      }
    });

    // Start listening to cart
    _listenToCart();
  }

  /// Listen to cart changes in real-time
  /// الاستماع إلى تغييرات السلة في الوقت الفعلي
  void _listenToCart() {
    if (_userId.isEmpty) {
      emit(const CartState(items: []));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    _cartSubscription?.cancel();
    _cartSubscription = _repository.getCartItemsStream(_userId).listen(
      (items) {
        emit(state.copyWith(items: items, isLoading: false));
      },
      onError: (error) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ));
      },
    );
  }


  /// Add product to cart (Catalog ProductEntity)
  /// إضافة منتج إلى السلة (من كتالوج المنتجات)
  Future<void> addProduct(CatalogProduct.ProductEntity product) async {
    if (_userId.isEmpty) {
      emit(state.copyWith(errorMessage: 'User not authenticated'));
      return;
    }

    if (!product.isInStock) {
      emit(state.copyWith(errorMessage: 'Product is out of stock'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final cartItem = CartItemEntity(
        productId: product.id,
        name: product.name,
        imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
        price: product.currentPrice,
        qty: 1,
        categoryId: product.categoryId,
      );

      await _repository.addToCart(_userId, cartItem);
      // Cart will update automatically via stream
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Add product to cart (Home ProductEntity)
  /// إضافة منتج إلى السلة (من صفحة الرئيسية)
  Future<void> addHomeProduct(HomeProduct.ProductEntity product) async {
    if (_userId.isEmpty) {
      emit(state.copyWith(errorMessage: 'User not authenticated'));
      return;
    }

    if (!product.isInStock) {
      emit(state.copyWith(errorMessage: 'Product is out of stock'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final cartItem = CartItemEntity(
        productId: product.id,
        name: product.name,
        imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
        price: product.currentPrice,
        qty: 1,
        categoryId: product.categoryId,
      );

      await _repository.addToCart(_userId, cartItem);
      // Cart will update automatically via stream
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Add product to cart (Product Details ProductEntity with quantity)
  /// إضافة منتج إلى السلة (من صفحة تفاصيل المنتج مع الكمية)
  Future<void> addProductWithQuantity(
    ProductFeature.ProductEntity product,
    int quantity,
  ) async {
    if (_userId.isEmpty) {
      emit(state.copyWith(errorMessage: 'User not authenticated'));
      return;
    }

    if (!product.isInStock) {
      emit(state.copyWith(errorMessage: 'Product is out of stock'));
      return;
    }

    if (quantity <= 0) {
      emit(state.copyWith(errorMessage: 'Quantity must be greater than 0'));
      return;
    }

    // Check stock availability
    final maxQuantity = product.hasVariants && product.variants != null
        ? product.totalStock
        : product.stockQuantity;

    if (quantity > maxQuantity) {
      emit(state.copyWith(
        errorMessage: 'Only $maxQuantity items available in stock',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final cartItem = CartItemEntity(
        productId: product.id,
        name: product.name,
        imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
        price: product.currentPrice,
        qty: quantity,
        categoryId: product.categoryId,
      );

      await _repository.addToCart(_userId, cartItem);
      // Cart will update automatically via stream
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Increase item quantity
  /// زيادة كمية العنصر
  Future<void> increaseQuantity(String productId) async {
    if (_userId.isEmpty) return;

    final item = state.items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => throw Exception('Item not found'),
    );

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.updateQuantity(_userId, productId, item.qty + 1);
      // Cart will update automatically via stream
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Decrease item quantity
  /// تقليل كمية العنصر
  Future<void> decreaseQuantity(String productId) async {
    if (_userId.isEmpty) return;

    final item = state.items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => throw Exception('Item not found'),
    );

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      if (item.qty > 1) {
        await _repository.updateQuantity(_userId, productId, item.qty - 1);
      } else {
        await _repository.removeFromCart(_userId, productId);
      }
      // Cart will update automatically via stream
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Remove item from cart
  /// إزالة عنصر من السلة
  Future<void> removeProduct(String productId) async {
    if (_userId.isEmpty) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.removeFromCart(_userId, productId);
      // Cart will update automatically via stream
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Clear cart
  /// تفريغ السلة
  Future<void> clear() async {
    if (_userId.isEmpty) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.clearCart(_userId);
      // Cart will update automatically via stream
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Refresh cart
  /// تحديث السلة
  Future<void> refresh() async {
    _listenToCart();
  }

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
