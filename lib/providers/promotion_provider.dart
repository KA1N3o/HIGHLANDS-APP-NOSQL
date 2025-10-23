import 'package:flutter/foundation.dart';
import '../models/promotion.dart';
import '../services/api_service.dart';

class PromotionProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Promotion> _promotions = [];
  List<Promotion> _activePromotions = [];
  bool _isLoading = false;
  Promotion? _appliedPromotion;
  double _discountAmount = 0;
  DateTime? _lastLoadTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  PromotionProvider(this._apiService);

  List<Promotion> get promotions => List.unmodifiable(_promotions);
  List<Promotion> get activePromotions => List.unmodifiable(_activePromotions);
  bool get isLoading => _isLoading;
  Promotion? get appliedPromotion => _appliedPromotion;
  double get discountAmount => _discountAmount;
  bool get hasAppliedPromotion => _appliedPromotion != null;
  
  /// Check if applied promotion is free shipping
  bool get isFreeShipping => _appliedPromotion?.type == PromotionType.freeShipping;
  
  /// Get shipping discount amount (for free shipping promotions)
  double getShippingDiscount(double deliveryFee) {
    if (_appliedPromotion?.type == PromotionType.freeShipping && _appliedPromotion!.isValid) {
      return deliveryFee; // Free shipping = full delivery fee discount
    }
    return 0;
  }
  
  bool get _isCacheValid {
    if (_lastLoadTime == null) return false;
    return DateTime.now().difference(_lastLoadTime!) < _cacheValidDuration;
  }

  /// Load all active promotions (for users)
  Future<void> loadActivePromotions() async {
    // Check if user is authenticated
    if (_apiService.authToken == null) {
      print('PromotionProvider: Cannot load promotions - user not authenticated');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _activePromotions = await _apiService.getActivePromotions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('PromotionProvider: Error loading active promotions: $e');
      _isLoading = false;
      notifyListeners();
      // Don't rethrow - just log the error
    }
  }

  /// Load all promotions (for admin)
  Future<void> loadAllPromotions({bool forceRefresh = false}) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid && _promotions.isNotEmpty) {
      print('PromotionProvider: Returning ${_promotions.length} promotions from cache');
      return;
    }

    // Check if user is authenticated
    if (_apiService.authToken == null) {
      print('PromotionProvider: Cannot load all promotions - user not authenticated');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _promotions = await _apiService.getAllPromotions();
      _lastLoadTime = DateTime.now();
      print('PromotionProvider: Loaded ${_promotions.length} promotions from server');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('PromotionProvider: Error loading all promotions: $e');
      _isLoading = false;
      notifyListeners();
      // Don't rethrow - just log the error
    }
  }

  /// Apply promotion code
  Future<void> applyPromotion(String code, double orderValue) async {
    // Check if user is authenticated
    if (_apiService.authToken == null) {
      throw Exception('Vui lòng đăng nhập để sử dụng mã giảm giá');
    }

    try {
      final result = await _apiService.validatePromotion(code, orderValue);
      
      final promotionData = result['promotion'] as Map<String, dynamic>;
      final discount = (result['discount'] as num).toDouble();
      
      _appliedPromotion = Promotion.fromJson(promotionData);
      _discountAmount = discount;
      
      notifyListeners();
    } catch (e) {
      print('PromotionProvider: Error applying promotion: $e');
      rethrow;
    }
  }

  /// Remove applied promotion
  void removePromotion() {
    _appliedPromotion = null;
    _discountAmount = 0;
    notifyListeners();
  }

  /// Recalculate discount when order value changes
  void updateDiscount(double newOrderValue) {
    if (_appliedPromotion != null) {
      _discountAmount = _appliedPromotion!.calculateDiscount(newOrderValue);
      
      // If promotion is no longer valid, remove it
      // Exception: free_shipping can have discount = 0
      if (!_appliedPromotion!.isValid || 
          (_discountAmount == 0 && _appliedPromotion!.type != PromotionType.freeShipping)) {
        removePromotion();
      } else {
        notifyListeners();
      }
    }
  }

  // Admin methods

  /// Create new promotion
  Future<void> createPromotion(Map<String, dynamic> promotionData) async {
    // Check if user is authenticated
    if (_apiService.authToken == null) {
      throw Exception('Vui lòng đăng nhập để tạo mã giảm giá');
    }

    try {
      final promotion = await _apiService.createPromotion(promotionData);
      _promotions.add(promotion);
      _lastLoadTime = DateTime.now(); // Update cache time
      print('PromotionProvider: Created promotion, total: ${_promotions.length}');
      notifyListeners();
    } catch (e) {
      print('PromotionProvider: Error creating promotion: $e');
      rethrow;
    }
  }

  /// Update promotion
  Future<void> updatePromotion(String promotionId, Map<String, dynamic> updates) async {
    // Check if user is authenticated
    if (_apiService.authToken == null) {
      throw Exception('Vui lòng đăng nhập để cập nhật mã giảm giá');
    }

    try {
      final updatedPromotion = await _apiService.updatePromotion(promotionId, updates);
      
      final index = _promotions.indexWhere((p) => p.id == promotionId);
      if (index != -1) {
        _promotions[index] = updatedPromotion;
        _lastLoadTime = DateTime.now(); // Update cache time
        notifyListeners();
      }
    } catch (e) {
      print('PromotionProvider: Error updating promotion: $e');
      rethrow;
    }
  }

  /// Delete promotion
  Future<void> deletePromotion(String promotionId) async {
    // Check if user is authenticated
    if (_apiService.authToken == null) {
      throw Exception('Vui lòng đăng nhập để xóa mã giảm giá');
    }

    try {
      await _apiService.deletePromotion(promotionId);
      
      _promotions.removeWhere((p) => p.id == promotionId);
      _lastLoadTime = DateTime.now(); // Update cache time
      
      // If the deleted promotion was applied, remove it
      if (_appliedPromotion?.id == promotionId) {
        removePromotion();
      }
      
      notifyListeners();
    } catch (e) {
      print('PromotionProvider: Error deleting promotion: $e');
      rethrow;
    }
  }

  /// Get promotion by ID
  Promotion? getPromotionById(String id) {
    try {
      return _promotions.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear all data
  void clear() {
    _promotions = [];
    _activePromotions = [];
    _appliedPromotion = null;
    _discountAmount = 0;
    _lastLoadTime = null;
    notifyListeners();
  }
}

