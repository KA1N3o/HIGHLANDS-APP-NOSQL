import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  DeliveryMethod _deliveryMethod = DeliveryMethod.pickup;

  List<CartItem> get items => List.unmodifiable(_items);

  DeliveryMethod get deliveryMethod => _deliveryMethod;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * 0.08; // 8% tax

  double get deliveryFee {
    // Nhận tại cửa hàng: không tính phí ship
    // Giao tận nơi: 15,000 VND
    return _deliveryMethod == DeliveryMethod.pickup ? 0.0 : 15000.0;
  }

  double get total => subtotal + tax + deliveryFee;

  void setDeliveryMethod(DeliveryMethod method) {
    _deliveryMethod = method;
    notifyListeners();
  }

  void addItem(CartItem item) {
    // Check if the same item already exists
    final existingIndex = _items.indexWhere((i) => i.isSameAs(item));
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _deliveryMethod = DeliveryMethod.pickup; // Reset to default
    notifyListeners();
  }

  bool isEmpty() {
    return _items.isEmpty;
  }
}

