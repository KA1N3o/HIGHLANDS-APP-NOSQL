import 'package:flutter/foundation.dart';
import '../models/store.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';

class StoreProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Store> _stores = [];
  Store? _selectedStore;
  bool _isLoading = false;
  bool _useMockData = true; // Set to false when backend is ready

  StoreProvider(this._apiService);

  List<Store> get stores => List.unmodifiable(_stores);
  Store? get selectedStore => _selectedStore;
  bool get isLoading => _isLoading;

  Future<void> loadStores() async {
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
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
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

