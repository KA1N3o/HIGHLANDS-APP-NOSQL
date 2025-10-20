import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/store.dart';

class ApiService {
  // Replace with your actual Bigtable REST API endpoint
  // static const String baseUrl = 'https://your-bigtable-api.com/api';
  
  // For development, you can use a local server or mock API
  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  
  final http.Client _client;
  String? _authToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  // Helper method to decode escape sequences
  String _decodeEscapeSequences(String text) {
    // Handle \x escape sequences - these are UTF-8 bytes that need to be reconstructed
    
    // Find all \x sequences and collect them as bytes
    final List<int> bytes = [];
    final regex = RegExp(r'\\x([0-9A-Fa-f]{2})');
    
    int lastEnd = 0;
    for (final match in regex.allMatches(text)) {
      // Add any text before this match
      if (match.start > lastEnd) {
        bytes.addAll(text.substring(lastEnd, match.start).codeUnits);
      }
      
      // Add the hex byte
      final hex = match.group(1)!;
      final byte = int.parse(hex, radix: 16);
      bytes.add(byte);
      
      lastEnd = match.end;
    }
    
    // Add any remaining text
    if (lastEnd < text.length) {
      bytes.addAll(text.substring(lastEnd).codeUnits);
    }
    
    // Convert bytes to UTF-8 string
    try {
      return utf8.decode(bytes);
    } catch (e) {
      // If UTF-8 decoding fails, return original text
      return text;
    }
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
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          // Return the data field directly for compatibility
          return jsonResponse['data'] as Map<String, dynamic>;
        } else {
          throw Exception('Login failed: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
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
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          // Return the data field directly for compatibility
          return jsonResponse['data'] as Map<String, dynamic>;
        } else {
          throw Exception('Registration failed: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
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
        Uri.parse('$baseUrl/users/me'),
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
        final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (responseData['success'] == true && responseData['message'] != null) {
          final Map<String, dynamic> messageData = responseData['message'] as Map<String, dynamic>;
          
          final List<dynamic> productsData = messageData['products'] as List<dynamic>;
          
          // Fix sizes field if it's a string instead of array
          final fixedProducts = productsData.map((json) {
            final productJson = json as Map<String, dynamic>;
            
            // Fix sizes field
            if (productJson['sizes'] is String) {
              try {
                productJson['sizes'] = jsonDecode(productJson['sizes'] as String);
              } catch (e) {
                productJson['sizes'] = [];
              }
            }
            
            // Fix UTF-8 encoding issues in text fields
            final textFields = ['name', 'description'];
            for (final field in textFields) {
              if (productJson[field] is String) {
                final text = productJson[field] as String;
                // Decode escape sequences like \xE1\xBB\x81n
                final decoded = _decodeEscapeSequences(text);
                print('DEBUG: $field - Original: $text');
                print('DEBUG: $field - Decoded: $decoded');
                productJson[field] = decoded;
              }
            }
            
            return productJson;
          }).toList();
          
          return fixedProducts.map((json) => Product.fromJson(json)).toList();
        } else {
          throw Exception('Failed to get products: ${responseData['error']?['message'] ?? 'Unknown error'}');
        }
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
        final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> storesData = responseData['data'] as List<dynamic>;
          return storesData.map((json) => Store.fromJson(json as Map<String, dynamic>)).toList();
        } else {
          throw Exception('Failed to get stores: ${responseData['error']?['message'] ?? 'Unknown error'}');
        }
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

