import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _currentUser;
  String? _authToken;
  bool _isLoading = false;
  bool _useMockData = false; // Set to false when backend is ready

    AuthProvider(this._apiService) {
    // Auto-restore session when provider is created
    _restoreSession();
  }

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null && _authToken != null;

  // Restore session from SharedPreferences
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedUserId = prefs.getString('user_id');
      
      if (savedToken != null && savedUserId != null) {
        _authToken = savedToken;
        // IMPORTANT: Set token in ApiService
        _apiService.setAuthToken(savedToken);
        
        // Try to get current user info from API
        try {
          _currentUser = await _apiService.getCurrentUser();
          notifyListeners();
        } catch (e) {
          // If token is expired or invalid, clear session
          print('Failed to restore session: $e');
          await logout();
        }
      }
    } catch (e) {
      print('Error restoring session: $e');
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Mock login logic
        if (email == 'admin@highlands.vn' && password == 'admin123') {
          _currentUser = MockDataService.getMockAdminUser();
          _authToken = 'mock_admin_token_${DateTime.now().millisecondsSinceEpoch}';
        } else if (email == 'customer@test.com' && password == 'customer123') {
          _currentUser = MockDataService.getMockCustomerUser();
          _authToken = 'mock_customer_token_${DateTime.now().millisecondsSinceEpoch}';
        } else {
          throw Exception('Email hoặc mật khẩu không đúng');
        }
        
        _apiService.setAuthToken(_authToken!);
        
        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _authToken!);
        await prefs.setString('user_id', _currentUser!.id);
      } else {
        final response = await _apiService.login(email, password);
        _authToken = response['token'] as String;
        _currentUser = User.fromJson(response['user'] as Map<String, dynamic>);
        
        _apiService.setAuthToken(_authToken!);
        
        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _authToken!);
        await prefs.setString('user_id', _currentUser!.id);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Mock registration - create new customer
        _currentUser = User(
          id: 'customer_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: name,
          phone: phone,
          role: UserRole.customer,
          createdAt: DateTime.now(),
        );
        _authToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        
        _apiService.setAuthToken(_authToken!);
        
        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _authToken!);
        await prefs.setString('user_id', _currentUser!.id);
      } else {
        final response = await _apiService.register(email, password, name, phone);
        _authToken = response['token'] as String;
        _currentUser = User.fromJson(response['user'] as Map<String, dynamic>);
        
        _apiService.setAuthToken(_authToken!);
        
        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _authToken!);
        await prefs.setString('user_id', _currentUser!.id);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _authToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    
    notifyListeners();
  }

  Future<void> loadSavedAuth() async {
    print('DEBUG loadSavedAuth: method called');
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');

      print('DEBUG loadSavedAuth: token exists = ${token != null}, userId = $userId');

      if (token != null && userId != null) {
        _authToken = token;
        _apiService.setAuthToken(token);
        print('DEBUG loadSavedAuth: Token set to ApiService');
        
        try {
          print('DEBUG loadSavedAuth: Calling getUser with userId: $userId');
          _currentUser = await _apiService.getUser(userId);
          print('DEBUG loadSavedAuth: User loaded successfully: ${_currentUser?.email}');
        } catch (e) {
          print('DEBUG loadSavedAuth: Failed to load user, but keeping token: $e');
          // Keep the token even if user loading fails (might be network issue)
          // Only logout if it's an auth error (401)
          if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
            print('DEBUG loadSavedAuth: Auth error, logging out');
            await logout();
          }
        }
      }
    } catch (e) {
      print('ERROR loadSavedAuth: $e');
      // If loading saved auth fails, clear it
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(User updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        _currentUser = updatedUser;
      } else {
        _currentUser = await _apiService.updateUser(updatedUser);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> uploadProfilePhoto(String base64Image) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        _currentUser = _currentUser?.copyWith(photoUrl: base64Image);
      } else {
        _currentUser = await _apiService.uploadProfilePhoto(base64Image);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        // Mock password change - just succeed
      } else {
        await _apiService.changePassword(currentPassword, newPassword, confirmPassword);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void toggleMockData(bool useMock) {
    _useMockData = useMock;
    notifyListeners();
  }
}

