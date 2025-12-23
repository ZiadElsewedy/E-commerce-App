import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/order_entity.dart';
import 'order_state.dart';

/// Order Cubit - Presentation Layer
/// مكعب الطلبات في طبقة العرض
class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;
  final String _userId;

  OrderCubit({
    required OrderRepository repository,
    String? userId,
  })  : _repository = repository,
        _userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '',
        super(const OrderState()) {
    _loadOrders();
  }

  /// Load user orders
  /// تحميل طلبات المستخدم
  Future<void> _loadOrders() async {
    if (_userId.isEmpty) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final orders = await _repository.getUserOrders(_userId);
      emit(state.copyWith(orders: orders, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Create new order
  /// إنشاء طلب جديد
  Future<String?> createOrder(OrderEntity order) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final orderId = await _repository.createOrder(order);
      await _loadOrders();
      emit(state.copyWith(isLoading: false));
      return orderId;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
      return null;
    }
  }

  /// Refresh orders
  /// تحديث الطلبات
  Future<void> refresh() async {
    await _loadOrders();
  }
}

