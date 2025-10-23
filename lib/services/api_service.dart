import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/store.dart';
import '../models/promotion.dart';

class ApiService {
  // Replace with your actual Bigtable REST API endpoint
  // static const String baseUrl = 'https://your-bigtable-api.com/api';
  
  // For development, you can use a local server or mock API
  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  
  // HTTP timeout to prevent long waits
  // Increased temporarily for slow Bigtable queries
  static const Duration _timeout = Duration(seconds: 30);
  
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
      ).timeout(_timeout);

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
  Future<User> getCurrentUser() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/users/me'),
        headers: _headers,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return User.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Failed to get current user: Invalid response format');
        }
      } else {
        throw Exception('Failed to get current user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get current user error: $e');
    }
  }

  Future<User> getUser(String userId) async {
    try {
      print('DEBUG getUser called with userId: $userId');
      print('DEBUG headers: $_headers');
      final url = Uri.parse('$baseUrl/users/me');
      print('DEBUG request URL: $url');
      final response = await _client.get(url, headers: _headers);

      print('DEBUG getUser response status: ${response.statusCode}');
      print('DEBUG getUser response body length: ${response.body.length}');
      if (response.body.length < 1000) {
        print('DEBUG getUser response body: ${response.body}');
      } else {
        print('DEBUG getUser response body (first 1000 chars): ${response.body.substring(0, 1000)}');
      }
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        print('DEBUG jsonResponse keys: ${jsonResponse.keys}');
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          // Check if data is already a User object or needs to be parsed
          final data = jsonResponse['data'];
          print('DEBUG data type: ${data.runtimeType}');
          print('DEBUG data is Map<String, dynamic>: ${data is Map<String, dynamic>}');
          
          if (data is Map<String, dynamic>) {
            print('DEBUG Map keys: ${data.keys}');
            // Check if the map has the expected keys
            print('DEBUG name in data: ${data.containsKey('name')}');
            print('DEBUG email in data: ${data.containsKey('email')}');
            if (data.containsKey('name')) {
              print('DEBUG name value: ${data['name']}');
            }
            if (data.containsKey('email')) {
              print('DEBUG email value: ${data['email']}');
            }
            
            try {
              final user = User.fromJson(data);
              print('DEBUG User created successfully: ${user.name}, ${user.email}');
              return user;
            } catch (e) {
              print('DEBUG User.fromJson failed: $e');
              rethrow;
            }
          } else if (data is String) {
            // If data is a string, try to parse it as JSON
            try {
              print('DEBUG parsing string data as JSON: $data');
              final userData = jsonDecode(data) as Map<String, dynamic>;
              return User.fromJson(userData);
            } catch (parseError) {
              print('DEBUG JSON parsing failed: $parseError');
              // If parsing fails, create a minimal user object
              return User(
                id: userId,
                email: 'unknown@example.com',
                name: 'Unknown User',
                phone: '',
                role: UserRole.customer,
                createdAt: DateTime.now(),
              );
            }
          } else {
            print('DEBUG unexpected data format, creating default user');
            print('DEBUG data type: ${data.runtimeType}');
            // If we get here, create a minimal user object with available data
            return User(
              id: userId,
              email: 'unknown@example.com',
              name: 'Unknown User',
              phone: '',
              role: UserRole.customer,
              createdAt: DateTime.now(),
            );
          }
        } else {
          print('DEBUG response not successful or data is null');
          print('DEBUG success: ${jsonResponse['success']}');
          print('DEBUG data: ${jsonResponse['data']}');
          throw Exception('Failed to get user: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else {
        print('DEBUG response status not 200: ${response.statusCode}');
        print('DEBUG response body: ${response.body}');
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('DEBUG getUser error: $e');
      print('DEBUG stack trace: $stackTrace');
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

  Future<User> uploadProfilePhoto(String base64Image) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/users/me/photo'),
        headers: _headers,
        body: jsonEncode({'photoUrl': base64Image}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return User.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Failed to upload photo: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to upload photo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Upload photo error: $e');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/users/me/change-password'),
        headers: _headers,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] != true) {
          throw Exception('Failed to change password: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Mật khẩu hiện tại không đúng');
      } else if (response.statusCode == 400) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final errors = jsonResponse['error']?['details'] as List<dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstError = errors[0] as Map<String, dynamic>;
          throw Exception(firstError['msg'] ?? 'Validation error');
        }
        throw Exception('Failed to change password: ${response.body}');
      } else {
        throw Exception('Failed to change password: ${response.body}');
      }
    } catch (e) {
      throw Exception('Change password error: $e');
    }
  }

  // Products
  Future<List<Product>> getProducts() async {
    try {
      final startTime = DateTime.now();
      final response = await _client.get(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
      ).timeout(_timeout);
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      print('API: Products fetched in ${duration}ms');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final Map<String, dynamic> dataMap = responseData['data'] as Map<String, dynamic>;
          
          final List<dynamic> productsData = dataMap['products'] as List<dynamic>;
          
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
      final startTime = DateTime.now();
      final response = await _client.get(
        Uri.parse('$baseUrl/stores'),
        headers: _headers,
      ).timeout(_timeout);
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      print('API: Stores fetched in ${duration}ms');

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
      final startTime = DateTime.now();
      final response = await _client.get(
        Uri.parse('$baseUrl/orders?limit=$limit'),
        headers: _headers,
      ).timeout(_timeout);
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      print('API: Orders fetched in ${duration}ms');

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

  Future<Order> cancelOrder(String orderId, {String? reason}) async {
    try {
      print('DEBUG API: Cancelling order $orderId');
      final response = await _client.post(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: _headers,
        body: jsonEncode({'reason': reason ?? 'Customer request'}),
      );

      print('DEBUG API: Cancel order response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Backend returns {success: true, message: "...", data: <order>}
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final orderData = jsonResponse['data'] as Map<String, dynamic>;
          return Order.fromJson(orderData);
        }
        
        throw Exception('Failed to cancel order: Invalid response format');
      } else {
        throw Exception('Failed to cancel order: ${response.body}');
      }
    } catch (e) {
      print('ERROR cancelling order: $e');
      throw Exception('Cancel order error: $e');
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

  Future<User> updateUserRole(String userId, UserRole role, {String? assignedStoreId}) async {
    try {
      final encodedUserId = Uri.encodeComponent(userId);
      final body = {'role': role.name};
      
      // Add assignedStoreId if provided, or explicitly set to null for non-staff roles
      if (role == UserRole.staff && assignedStoreId != null) {
        body['assignedStoreId'] = assignedStoreId;
      } else if (role != UserRole.staff) {
        // Clear assignedStoreId when changing from staff to other roles
        body['assignedStoreId'] = '';
      }
      
      final response = await _client.put(
        Uri.parse('$baseUrl/admin/users/$encodedUserId/role'),
        headers: _headers,
        body: jsonEncode(body),
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

  Future<void> deleteUser(String userId) async {
    try {
      final encodedUserId = Uri.encodeComponent(userId);
      print('DEBUG API: Deleting user ID: $userId (encoded: $encodedUserId)');
      
      final response = await _client.delete(
        Uri.parse('$baseUrl/admin/users/$encodedUserId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] != true) {
          throw Exception('Failed to delete user: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Không thể xóa tài khoản admin');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy người dùng');
      } else {
        throw Exception('Failed to delete user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Delete user error: $e');
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

  // ===== PROMOTION METHODS =====

  /// Get all active promotions
  Future<List<Promotion>> getActivePromotions() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/promotions'),
        headers: _headers,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'] as Map<String, dynamic>;
          final promotionsList = data['promotions'] as List;
          return promotionsList
              .map((json) => Promotion.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Failed to load promotions: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load promotions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Load promotions error: $e');
    }
  }

  /// Validate and apply promotion code
  Future<Map<String, dynamic>> validatePromotion(String code, double orderValue) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/promotions/validate'),
        headers: _headers,
        body: jsonEncode({
          'code': code,
          'orderValue': orderValue,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return jsonResponse['data'] as Map<String, dynamic>;
        } else {
          throw Exception(jsonResponse['error']?['message'] ?? 'Invalid promotion code');
        }
      } else {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(jsonResponse['error']?['message'] ?? 'Invalid promotion code');
      }
    } catch (e) {
      throw Exception('Validate promotion error: $e');
    }
  }

  // Admin promotion methods

  /// Get all promotions (admin)
  Future<List<Promotion>> getAllPromotions() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/admin/promotions'),
        headers: _headers,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        print('API getAllPromotions response success: ${jsonResponse['success']}');
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'] as Map<String, dynamic>;
          
          // Backend returns data.promotions as array
          final promotionsList = data['promotions'] as List;
          print('API getAllPromotions count: ${promotionsList.length}');
          
          if (promotionsList.isNotEmpty) {
            print('First promotion ID: ${promotionsList[0]['id']}');
            print('First promotion code: ${promotionsList[0]['code']}');
          }
          
          return promotionsList
              .map((json) => Promotion.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Failed to load promotions: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load promotions: ${response.body}');
      }
    } catch (e) {
      print('API getAllPromotions error: $e');
      throw Exception('Load promotions error: $e');
    }
  }

  /// Create new promotion (admin)
  Future<Promotion> createPromotion(Map<String, dynamic> promotionData) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/admin/promotions'),
        headers: _headers,
        body: jsonEncode(promotionData),
      ).timeout(_timeout);

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return Promotion.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Failed to create promotion: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(jsonResponse['error']?['message'] ?? 'Failed to create promotion');
      }
    } catch (e) {
      throw Exception('Create promotion error: $e');
    }
  }

  /// Update promotion (admin)
  Future<Promotion> updatePromotion(String promotionId, Map<String, dynamic> updates) async {
    try {
      final encodedPromotionId = Uri.encodeComponent(promotionId);
      final response = await _client.put(
        Uri.parse('$baseUrl/admin/promotions/$encodedPromotionId'),
        headers: _headers,
        body: jsonEncode(updates),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return Promotion.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Failed to update promotion: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        }
      } else {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(jsonResponse['error']?['message'] ?? 'Failed to update promotion');
      }
    } catch (e) {
      throw Exception('Update promotion error: $e');
    }
  }

  /// Delete promotion (admin)
  Future<void> deletePromotion(String promotionId) async {
    try {
      final encodedPromotionId = Uri.encodeComponent(promotionId);
      final response = await _client.delete(
        Uri.parse('$baseUrl/admin/promotions/$encodedPromotionId'),
        headers: _headers,
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(jsonResponse['error']?['message'] ?? 'Failed to delete promotion');
      }
    } catch (e) {
      throw Exception('Delete promotion error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

