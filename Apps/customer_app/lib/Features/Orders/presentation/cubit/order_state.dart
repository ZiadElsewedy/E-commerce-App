import '../../domain/entities/order_entity.dart';

/// Order State - Presentation Layer
/// حالة الطلبات في طبقة العرض
class OrderState {
  final List<OrderEntity> orders;
  final bool isLoading;
  final String? errorMessage;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OrderState copyWith({
    List<OrderEntity>? orders,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

