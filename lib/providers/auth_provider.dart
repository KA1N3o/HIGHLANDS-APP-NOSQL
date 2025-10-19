import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _currentUser;
  String? _authToken;
  bool _isLoading = false;

  AuthProvider(this._apiService);

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null && _authToken != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      _authToken = response['token'] as String;
      _currentUser = User.fromJson(response['user'] as Map<String, dynamic>);
      
      _apiService.setAuthToken(_authToken!);
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _authToken!);
      await prefs.setString('user_id', _currentUser!.id);
      
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
      final response = await _apiService.register(email, password, name, phone);
      _authToken = response['token'] as String;
      _currentUser = User.fromJson(response['user'] as Map<String, dynamic>);
      
      _apiService.setAuthToken(_authToken!);
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _authToken!);
      await prefs.setString('user_id', _currentUser!.id);
      
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
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');

      if (token != null && userId != null) {
        _authToken = token;
        _apiService.setAuthToken(token);
        _currentUser = await _apiService.getUser(userId);
      }
    } catch (e) {
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
      _currentUser = await _apiService.updateUser(updatedUser);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}

