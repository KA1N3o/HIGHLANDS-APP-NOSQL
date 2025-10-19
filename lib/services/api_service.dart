import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/store.dart';

class ApiService {
  // Replace with your actual Bigtable REST API endpoint
  static const String baseUrl = 'https://your-bigtable-api.com/api';
  
  // For development, you can use a local server or mock API
  // static const String baseUrl = 'http://localhost:8080/api';
  
  final http.Client _client;
  String? _authToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  // User
  Future<User> getUser(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get user error: $e');
    }
  }

  Future<User> updateUser(User user) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/users/${user.id}'),
        headers: _headers,
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Update user error: $e');
    }
  }

  // Products
  Future<List<Product>> getProducts() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get products: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get products error: $e');
    }
  }

  Future<Product> getProduct(String productId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get product error: $e');
    }
  }

  // Stores
  Future<List<Store>> getStores() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/stores'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) => Store.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get stores: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get stores error: $e');
    }
  }

  Future<Store> getStore(String storeId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/stores/$storeId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Store.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get store: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get store error: $e');
    }
  }

  // Orders
  Future<Order> createOrder(Order order) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/orders'),
        headers: _headers,
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode == 201) {
        return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Create order error: $e');
    }
  }

  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/orders/user/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get user orders: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get user orders error: $e');
    }
  }

  Future<Order> getOrder(String orderId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get order error: $e');
    }
  }

  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: _headers,
        body: jsonEncode({'status': status.name}),
      );

      if (response.statusCode == 200) {
        return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update order status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Update order status error: $e');
    }
  }

  // Payment
  Future<Map<String, dynamic>> processPayment(
    String orderId,
    PaymentMethod method,
    Map<String, dynamic> paymentDetails,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/payments'),
        headers: _headers,
        body: jsonEncode({
          'orderId': orderId,
          'method': method.name,
          'details': paymentDetails,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Payment failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

