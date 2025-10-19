import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Order> _orders = [];
  bool _isLoading = false;
  Order? _currentOrder;

  OrderProvider(this._apiService);

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  Order? get currentOrder => _currentOrder;

  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _apiService.getUserOrders(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Order> createOrder(Order order) async {
    _isLoading = true;
    notifyListeners();

    try {
      final createdOrder = await _apiService.createOrder(order);
      _orders.insert(0, createdOrder);
      _currentOrder = createdOrder;
      _isLoading = false;
      notifyListeners();
      return createdOrder;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshOrder(String orderId) async {
    try {
      final order = await _apiService.getOrder(orderId);
      final index = _orders.indexWhere((o) => o.id == orderId);
      
      if (index >= 0) {
        _orders[index] = order;
      }
      
      if (_currentOrder?.id == orderId) {
        _currentOrder = order;
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedOrder = await _apiService.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((o) => o.id == orderId);
      
      if (index >= 0) {
        _orders[index] = updatedOrder;
      }
      
      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void setCurrentOrder(Order? order) {
    _currentOrder = order;
    notifyListeners();
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }
}

