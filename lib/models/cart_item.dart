import 'product.dart';

class CartItem {
  final Product product;
  final String size;
  final Map<String, String> selectedOptions;
  final String? notes;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.selectedOptions,
    this.notes,
    this.quantity = 1,
  });

  double get totalPrice {
    double basePrice = product.price;
    
    // Add extra price for options
    for (var option in product.options) {
      if (selectedOptions.containsKey(option.name)) {
        basePrice += option.extraPrice;
      }
    }
    
    // Size multiplier (example: Medium = 1x, Large = 1.2x)
    double sizeMultiplier = 1.0;
    if (size == 'Large') {
      sizeMultiplier = 1.2;
    } else if (size == 'Small') {
      sizeMultiplier = 0.8;
    }
    
    return basePrice * sizeMultiplier * quantity;
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
    
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      size: json['size']?.toString() ?? 'Medium',
      selectedOptions: parseSelectedOptions(json['selectedOptions']),
      notes: json['notes']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'size': size,
      'selectedOptions': selectedOptions,
      'notes': notes,
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    Product? product,
    String? size,
    Map<String, String>? selectedOptions,
    String? notes,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      size: size ?? this.size,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      notes: notes ?? this.notes,
      quantity: quantity ?? this.quantity,
    );
  }

  // Helper method to check if two cart items are the same
  bool isSameAs(CartItem other) {
    return product.id == other.product.id &&
        size == other.size &&
        _mapsEqual(selectedOptions, other.selectedOptions) &&
        notes == other.notes;
  }

  bool _mapsEqual(Map<String, String> map1, Map<String, String> map2) {
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }
}

