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
  DateTime? _lastLoadTime;
  // Increased cache duration to 5 minutes for better performance
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  String? _lastUserId; // Track which user's orders are cached

  OrderProvider(this._apiService);

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  Order? get currentOrder => _currentOrder;
  
  bool _isCacheValid(String? userId) {
    if (_lastLoadTime == null) return false;
    if (userId != null && _lastUserId != userId) return false; // Different user
    return DateTime.now().difference(_lastLoadTime!) < _cacheValidDuration;
  }

  Future<void> loadUserOrders(String userId, {bool forceRefresh = false}) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid(userId) && _orders.isNotEmpty) {
      print('OrderProvider: Returning ${_orders.length} orders from cache');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final startTime = DateTime.now();
      
      if (_useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        // Load mock orders
        _orders = MockDataService.getMockOrders();
      } else {
        _orders = await _apiService.getUserOrders(userId);
      }
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      print('OrderProvider: Loaded ${_orders.length} user orders in ${duration}ms');
      
      _lastLoadTime = DateTime.now();
      _lastUserId = userId;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('OrderProvider: Error loading user orders: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadAllOrders({int limit = 20, bool forceRefresh = false}) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid(null) && _orders.isNotEmpty) {
      print('OrderProvider: Returning ${_orders.length} orders from cache');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final startTime = DateTime.now();
      
      if (_useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        // Load mock orders
        _orders = MockDataService.getMockOrders();
      } else {
        print('OrderProvider: Loading all orders with limit $limit');
        _orders = await _apiService.getAllOrders(limit: limit);
      }
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      print('OrderProvider: Loaded ${_orders.length} orders in ${duration}ms');
      
      _lastLoadTime = DateTime.now();
      _lastUserId = null; // Admin loads all users
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      print('OrderProvider ERROR: $e');
      print('Stack trace: $stackTrace');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  void clearCache() {
    _orders = [];
    _lastLoadTime = null;
    _lastUserId = null;
    notifyListeners();
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
          // Only update if status actually changed
          if (_orders[index].status != updatedOrder.status) {
            _orders[index] = updatedOrder;
            print('Updated order in list at index $index');
          }
        } else {
          // If not found, add it
          _orders.add(updatedOrder);
          print('Added updated order to list');
        }
      }
      
      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }
      
      // Only notify once after all updates
      notifyListeners();
      print('Order status updated successfully, notified listeners');
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      print('Cancelling order $orderId');
      Order updatedOrder;
      
      if (_useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Find and update order in mock data
        final orderIndex = _orders.indexWhere((o) => o.id == orderId);
        if (orderIndex >= 0) {
          final order = _orders[orderIndex];
          updatedOrder = order.copyWith(status: OrderStatus.cancelled);
          _orders[orderIndex] = updatedOrder;
        } else {
          throw Exception('Order not found');
        }
      } else {
        updatedOrder = await _apiService.cancelOrder(orderId, reason: reason);
        print('Order cancelled successfully: ${updatedOrder.id}');
        
        final index = _orders.indexWhere((o) => o.id == orderId);
        
        if (index >= 0) {
          _orders[index] = updatedOrder;
          print('Updated cancelled order in list at index $index');
        } else {
          _orders.add(updatedOrder);
          print('Added cancelled order to list');
        }
      }
      
      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }
      
      notifyListeners();
      print('Order cancelled successfully, notified listeners');
    } catch (e) {
      print('Error cancelling order: $e');
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

