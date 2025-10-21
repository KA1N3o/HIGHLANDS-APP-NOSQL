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
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return User.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Failed to get user: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
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
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return User.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Failed to update user: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
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
          
          // Optimize: Process all products in one go
          final fixedProducts = <Map<String, dynamic>>[];
          
          for (var json in productsData) {
            final productJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
            
            // Fix sizes field
            if (productJson['sizes'] is String) {
              try {
                productJson['sizes'] = jsonDecode(productJson['sizes'] as String);
              } catch (e) {
                productJson['sizes'] = [];
              }
            }
            
            // Fix UTF-8 encoding issues in text fields - only decode if needed
            if (productJson['name'] is String) {
              final name = productJson['name'] as String;
              if (name.contains(r'\x')) {
                productJson['name'] = _decodeEscapeSequences(name);
              }
            }
            
            if (productJson['description'] is String) {
              final desc = productJson['description'] as String;
              if (desc.contains(r'\x')) {
                productJson['description'] = _decodeEscapeSequences(desc);
              }
            }
            
            fixedProducts.add(productJson);
          }
          
          // Parse to Product objects
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
      print('DEBUG createOrder: Token = ${_authToken != null ? "EXISTS" : "NULL"}');
      print('DEBUG createOrder: Headers = $_headers');
      
      final response = await _client.post(
        Uri.parse('$baseUrl/orders'),
        headers: _headers,
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Backend returns {success: true, message: "...", data: {...}}
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return Order.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Create order failed: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Create order error: $e');
    }
  }

  Future<List<Order>> getUserOrders(String userId) async {
    try {
      // URL encode userId to handle special characters like #
      final encodedUserId = Uri.encodeComponent(userId);
      final response = await _client.get(
        Uri.parse('$baseUrl/orders/user/$encodedUserId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Backend returns {success: true, data: [...]}
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          return data.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
        }
        
        throw Exception('Failed to get user orders: Invalid response format');
      } else {
        throw Exception('Failed to get user orders: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get user orders error: $e');
    }
  }

  Future<List<Order>> getAllOrders({int limit = 100}) async {
    try {
      print('DEBUG API: Fetching orders from $baseUrl/orders?limit=$limit');
      final response = await _client.get(
        Uri.parse('$baseUrl/orders?limit=$limit'),
        headers: _headers,
      );

      print('DEBUG API: Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('DEBUG API: Response body length: ${response.body.length}');
        print('DEBUG API: First 500 chars of response: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Backend returns {success: true, message: "...", data: {orders: [...], count: ...}}
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final dataMap = jsonResponse['data'] as Map<String, dynamic>;
          final List<dynamic> ordersData = dataMap['orders'] as List<dynamic>;
          print('DEBUG API: Got ${ordersData.length} orders from backend');
          
          // Parse each order and catch individual errors
          final List<Order> orders = [];
          for (int i = 0; i < ordersData.length; i++) {
            try {
              final orderJson = ordersData[i] as Map<String, dynamic>;
              print('DEBUG API: Parsing order $i: ${orderJson['id']}');
              final order = Order.fromJson(orderJson);
              orders.add(order);
            } catch (e, stackTrace) {
              print('ERROR parsing order $i: $e');
              print('Order JSON: ${ordersData[i]}');
              print('Stack trace: $stackTrace');
              // Continue to next order instead of failing completely
            }
          }
          
          print('DEBUG API: Successfully parsed ${orders.length} orders');
          return orders;
        }
        
        throw Exception('Failed to get all orders: Invalid response format');
      } else {
        throw Exception('Failed to get all orders: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get all orders error: $e');
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
      print('DEBUG API: Updating order $orderId to status ${status.name}');
      final response = await _client.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: _headers,
        body: jsonEncode({'status': status.name}),
      );

      print('DEBUG API: Update status response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Backend returns {success: true, message: "...", data: <order>}
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final orderData = jsonResponse['data'] as Map<String, dynamic>;
          return Order.fromJson(orderData);
        }
        
        throw Exception('Failed to update order status: Invalid response format');
      } else {
        throw Exception('Failed to update order status: ${response.body}');
      }
    } catch (e) {
      print('ERROR updating order status: $e');
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

  // Admin - User Management
  Future<List<User>> getAllUsers({int limit = 100}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/admin/users?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'] as Map<String, dynamic>;
          final List<dynamic> usersData = data['users'] as List<dynamic>;
          return usersData.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
        } else {
          throw Exception('Failed to get users: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to get users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get users error: $e');
    }
  }

  Future<User> updateUserInfo(String userId, Map<String, dynamic> updates) async {
    try {
      final encodedUserId = Uri.encodeComponent(userId);
      final response = await _client.put(
        Uri.parse('$baseUrl/admin/users/$encodedUserId'),
        headers: _headers,
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return User.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Failed to update user: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Update user error: $e');
    }
  }

  Future<User> updateUserRole(String userId, UserRole role) async {
    try {
      final encodedUserId = Uri.encodeComponent(userId);
      final response = await _client.put(
        Uri.parse('$baseUrl/admin/users/$encodedUserId/role'),
        headers: _headers,
        body: jsonEncode({'role': role.name}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return User.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Failed to update user role: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to update user role: ${response.body}');
      }
    } catch (e) {
      throw Exception('Update user role error: $e');
    }
  }

  // Admin - Product Management
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/admin/products'),
        headers: _headers,
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return Product.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Failed to create product: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to create product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Create product error: $e');
    }
  }

  Future<Product> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      // URL encode the product ID to handle special characters like #
      final encodedProductId = Uri.encodeComponent(productId);
      print('DEBUG API: Updating product ID: $productId');
      print('DEBUG API: Encoded ID: $encodedProductId');
      print('DEBUG API: URL: $baseUrl/admin/products/$encodedProductId');
      print('DEBUG API: Updates: $updates');
      
      final response = await _client.put(
        Uri.parse('$baseUrl/admin/products/$encodedProductId'),
        headers: _headers,
        body: jsonEncode(updates),
      );

      print('DEBUG API: Response status: ${response.statusCode}');
      print('DEBUG API: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        print('DEBUG API: Parsed JSON response: $jsonResponse');
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          print('DEBUG API: Product data: ${jsonResponse['data']}');
          print('DEBUG API: Product data type: ${jsonResponse['data'].runtimeType}');
          
          // Ensure data is a Map
          final productData = jsonResponse['data'];
          if (productData is! Map<String, dynamic>) {
            throw Exception('Product data is not a Map: ${productData.runtimeType}');
          }
          
          return Product.fromJson(productData);
        } else {
          throw Exception('Failed to update product: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to update product: ${response.body}');
      }
    } catch (e) {
      print('DEBUG API: Error: $e');
      throw Exception('Update product error: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // URL encode the product ID to handle special characters like #
      final encodedProductId = Uri.encodeComponent(productId);
      print('DEBUG API: Deleting product ID: $productId (encoded: $encodedProductId)');
      
      final response = await _client.delete(
        Uri.parse('$baseUrl/admin/products/$encodedProductId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Delete product error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

