import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Order> _orders = [];
  bool _isLoading = false;
  Order? _currentOrder;
  bool _useMockData = false; // Set to false when backend is ready

  OrderProvider(this._apiService);

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  Order? get currentOrder => _currentOrder;

  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        // Load mock orders
        _orders = MockDataService.getMockOrders();
      } else {
        _orders = await _apiService.getUserOrders(userId);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadAllOrders({int limit = 100}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        // Load mock orders
        _orders = MockDataService.getMockOrders();
      } else {
        print('DEBUG: Loading all orders with limit $limit');
        _orders = await _apiService.getAllOrders(limit: limit);
        print('DEBUG: Successfully loaded ${_orders.length} orders');
      }
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      print('ERROR loading orders: $e');
      print('Stack trace: $stackTrace');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Order> createOrder(Order order) async {
    _isLoading = true;
    notifyListeners();

    try {
      Order createdOrder;
      
      if (_useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        // In mock mode, just return the order as-is (simulating successful creation)
        createdOrder = order;
      } else {
        createdOrder = await _apiService.createOrder(order);
      }
      
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
    try {
      print('Updating order $orderId to status ${status.name}');
      Order updatedOrder;
      
      if (_useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Find and update order in mock data
        final orderIndex = _orders.indexWhere((o) => o.id == orderId);
        if (orderIndex >= 0) {
          final order = _orders[orderIndex];
          updatedOrder = order.copyWith(status: status);
          _orders[orderIndex] = updatedOrder;
        } else {
          throw Exception('Order not found');
        }
      } else {
        updatedOrder = await _apiService.updateOrderStatus(orderId, status);
        print('Received updated order from API: ${updatedOrder.id}, status: ${updatedOrder.status.name}');
        
        final index = _orders.indexWhere((o) => o.id == orderId);
        
        if (index >= 0) {
          _orders[index] = updatedOrder;
          print('Updated order in list at index $index');
          print('Orders list now has ${_orders.length} orders');
          print('Order statuses: ${_orders.map((o) => '${o.id.substring(0, 8)}: ${o.status.name}').join(', ')}');
        } else {
          // If not found, add it
          _orders.add(updatedOrder);
          print('Added updated order to list');
        }
      }
      
      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }
      
      // Force rebuild by notifying listeners
      notifyListeners();
      print('Order status updated successfully, notified listeners');
    } catch (e) {
      print('Error updating order status: $e');
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

  void toggleMockData(bool useMock) {
    _useMockData = useMock;
    notifyListeners();
  }
}

