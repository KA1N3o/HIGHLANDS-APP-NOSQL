import 'package:flutter/foundation.dart';
import '../models/store.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';

class StoreProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Store> _stores = [];
  Store? _selectedStore;
  bool _isLoading = false;
  bool _useMockData = false; // Set to false when backend is ready
  DateTime? _lastLoadTime;
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  StoreProvider(this._apiService);

  List<Store> get stores => List.unmodifiable(_stores);
  Store? get selectedStore => _selectedStore;
  bool get isLoading => _isLoading;
  
  bool get _isCacheValid {
    if (_lastLoadTime == null) return false;
    return DateTime.now().difference(_lastLoadTime!) < _cacheValidDuration;
  }

  Future<void> loadStores({bool forceRefresh = false}) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid && _stores.isNotEmpty) {
      return;
    }

    // Check if user is authenticated
    if (!_useMockData && _apiService.authToken == null) {
      print('StoreProvider: Cannot load stores - user not authenticated');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (_useMockData) {
        // Use mock data for development
        await Future.delayed(const Duration(milliseconds: 500));
        _stores = MockDataService.getMockStores();
      } else {
        _stores = await _apiService.getStores();
      }
      
      _lastLoadTime = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('StoreProvider: Error loading stores: $e');
      _isLoading = false;
      notifyListeners();
      // Don't rethrow - just log the error
    }
  }
  
  void clearCache() {
    _stores = [];
    _lastLoadTime = null;
    notifyListeners();
  }

  void selectStore(Store store) {
    _selectedStore = store;
    notifyListeners();
  }

  void clearSelectedStore() {
    _selectedStore = null;
    notifyListeners();
  }

  List<Store> getNearbyStores(double userLat, double userLon, {double maxDistance = 10.0}) {
    final nearbyStores = _stores.where((store) {
      final distance = store.distanceFrom(userLat, userLon);
      return distance <= maxDistance;
    }).toList();

    // Sort by distance
    nearbyStores.sort((a, b) {
      final distA = a.distanceFrom(userLat, userLon);
      final distB = b.distanceFrom(userLat, userLon);
      return distA.compareTo(distB);
    });

    return nearbyStores;
  }

  void toggleMockData(bool useMock) {
    _useMockData = useMock;
    notifyListeners();
  }
}

