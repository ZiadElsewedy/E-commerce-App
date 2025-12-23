import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/order_entity.dart';
import '../datasources/order_remote_datasource.dart';

/// Order Repository Implementation - Data Layer
/// تنفيذ مستودع الطلبات في طبقة البيانات
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _dataSource;

  OrderRepositoryImpl({required OrderRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<String> createOrder(OrderEntity order) async {
    return await _dataSource.createOrder(order);
  }

  @override
  Future<List<OrderEntity>> getUserOrders(String userId) async {
    return await _dataSource.getUserOrders(userId);
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) async {
    return await _dataSource.getOrderById(orderId);
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    return await _dataSource.updateOrderStatus(orderId, status);
  }
}

