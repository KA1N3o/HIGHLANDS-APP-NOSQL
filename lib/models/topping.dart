class Topping {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final bool isAvailable;

  Topping({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory Topping.fromJson(Map<String, dynamic> json) {
    // Parse price - handle both string and number
    double parsePrice(dynamic value, {double defaultValue = 0.0}) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed ?? defaultValue;
      }
      return defaultValue;
    }

    // Parse boolean - handle both bool and string
    bool parseBool(dynamic value, bool defaultValue) {
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return defaultValue;
    }

    return Topping(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: parsePrice(json['price']),
      imageUrl: json['imageUrl']?.toString(),
      isAvailable: parseBool(json['isAvailable'], true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Topping && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

