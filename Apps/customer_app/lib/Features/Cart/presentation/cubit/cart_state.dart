import '../../domain/entities/cart_item_entity.dart';

/// Cart State - Presentation Layer
/// حالة السلة في طبقة العرض
class CartState {
  final List<CartItemEntity> items;
  final bool isLoading;
  final String? errorMessage;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  /// Calculate total items count
  /// حساب إجمالي عدد العناصر
  int get totalItems => items.fold(0, (sum, item) => sum + item.qty);

  /// Calculate subtotal
  /// حساب الإجمالي الفرعي
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);

  CartState copyWith({
    List<CartItemEntity>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
