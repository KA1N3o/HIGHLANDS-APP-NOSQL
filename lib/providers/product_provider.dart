import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Product> _products = [];
  bool _isLoading = false;
  bool _useMockData = false; // Set to false when backend is ready
  DateTime? _lastLoadTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  ProductProvider(this._apiService);

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  bool get hasCache => _products.isNotEmpty && _isCacheValid;
  
  bool get _isCacheValid {
    if (_lastLoadTime == null) return false;
    return DateTime.now().difference(_lastLoadTime!) < _cacheValidDuration;
  }

  Future<void> loadProducts({bool forceRefresh = false}) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid && _products.isNotEmpty) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (_useMockData) {
        // Use mock data for development
        await Future.delayed(const Duration(milliseconds: 500));
        _products = MockDataService.getMockProducts();
      } else {
        // Check if we have auth token before making API call
        if (_apiService.authToken == null) {
          throw Exception('Authentication required. Please login first.');
        }
        _products = await _apiService.getProducts();
      }
      
      _lastLoadTime = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  void clearCache() {
    _products = [];
    _lastLoadTime = null;
    notifyListeners();
  }

  List<Product> getProductsByCategory(ProductCategory category) {
    return _products.where((p) => p.category == category).toList();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void toggleMockData(bool useMock) {
    _useMockData = useMock;
    notifyListeners();
  }
}

