import 'product.dart';
import 'topping.dart';

class CartItem {
  final Product product;
  final String size;
  final Map<String, String> selectedOptions;
  final List<Topping> selectedToppings;
  final String? notes;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.selectedOptions,
    List<Topping>? selectedToppings,
    this.notes,
    this.quantity = 1,
  }) : selectedToppings = selectedToppings ?? [];

  double get totalPrice {
    // Giá gốc là giá của size nhỏ nhất
    double priceForSize = product.price;
    
    // Tính giá theo size: mỗi size lớn hơn +30% so với size trước
    // Size 0: price, Size 1: price × 1.3, Size 2: price × 1.3 × 1.3
    int sizeIndex = product.sizes.indexOf(size);
    if (sizeIndex > 0) {
      for (int i = 0; i < sizeIndex; i++) {
        priceForSize *= 1.3;
      }
    }
    
    // Add extra price for options
    for (var option in product.options) {
      if (selectedOptions.containsKey(option.name)) {
        priceForSize += option.extraPrice;
      }
    }
    
    // Add price for toppings
    for (var topping in selectedToppings) {
      priceForSize += topping.price;
    }
    
    return priceForSize * quantity;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Parse selectedOptions - handle null and various formats
    Map<String, String> parseSelectedOptions(dynamic value) {
      if (value == null) return {};
      if (value is Map) {
        return Map<String, String>.from(
          value.map((key, val) => MapEntry(key.toString(), val.toString())),
        );
      }
      return {};
    }
    
    // Parse selectedToppings - handle null and various formats
    List<Topping> parseSelectedToppings(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .whereType<Map<String, dynamic>>()
            .map((e) => Topping.fromJson(e))
            .toList();
      }
      return [];
    }
    
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      size: json['size']?.toString() ?? 'Medium',
      selectedOptions: parseSelectedOptions(json['selectedOptions']),
      selectedToppings: parseSelectedToppings(json['selectedToppings']),
      notes: json['notes']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'size': size,
      'selectedOptions': selectedOptions,
      'selectedToppings': selectedToppings.map((e) => e.toJson()).toList(),
      'notes': notes,
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    Product? product,
    String? size,
    Map<String, String>? selectedOptions,
    List<Topping>? selectedToppings,
    String? notes,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      size: size ?? this.size,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      selectedToppings: selectedToppings ?? this.selectedToppings,
      notes: notes ?? this.notes,
      quantity: quantity ?? this.quantity,
    );
  }

  // Helper method to check if two cart items are the same
  bool isSameAs(CartItem other) {
    return product.id == other.product.id &&
        size == other.size &&
        _mapsEqual(selectedOptions, other.selectedOptions) &&
        _listsEqual(selectedToppings, other.selectedToppings) &&
        notes == other.notes;
  }

  bool _mapsEqual(Map<String, String> map1, Map<String, String> map2) {
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }

  bool _listsEqual(List<Topping> list1, List<Topping> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
    }
    return true;
  }
}



