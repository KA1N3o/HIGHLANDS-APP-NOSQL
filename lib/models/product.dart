import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final ProductCategory category;
  final List<String> sizes;
  final List<ProductOption> options;
  final bool isAvailable;
  final int preparationTime; // in minutes
  final double rating; // Average rating (0-5)
  final int reviewCount; // Number of reviews

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.sizes,
    required this.options,
    this.isAvailable = true,
    this.preparationTime = 10,
    this.rating = 4.5,
    this.reviewCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
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
    
    // Parse sizes - handle both string JSON and array
    List<String> parseSizes(dynamic value) {
      if (value == null) return ['Medium'];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (e) {
          // If JSON decode fails, return default
        }
      }
      return ['Medium'];
    }
    
    // Parse options - handle both string JSON and array
    List<ProductOption> parseOptions(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .map((e) => ProductOption.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded
                .map((e) => ProductOption.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        } catch (e) {
          // If JSON decode fails, return empty
        }
      }
      return [];
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
    
    // Parse int - handle both int and string
    int parseInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is num) return value.toInt();
      return defaultValue;
    }
    
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: parsePrice(json['price']),
      imageUrl: json['imageUrl']?.toString() ?? '',
      category: ProductCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ProductCategory.coffee,
      ),
      sizes: parseSizes(json['sizes']),
      options: parseOptions(json['options']),
      isAvailable: parseBool(json['isAvailable'], true),
      preparationTime: parseInt(json['preparationTime'], 10),
      rating: parsePrice(json['rating'] ?? json['averageRating'], defaultValue: 4.5),
      reviewCount: parseInt(json['reviewCount'] ?? json['totalReviews'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category.name,
      'sizes': sizes,
      'options': options.map((e) => e.toJson()).toList(),
      'isAvailable': isAvailable,
      'preparationTime': preparationTime,
    };
  }
}

class ProductOption {
  final String name;
  final List<String> choices;
  final double extraPrice;

  ProductOption({
    required this.name,
    required this.choices,
    this.extraPrice = 0,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      name: json['name'] as String,
      choices:
          (json['choices'] as List<dynamic>).map((e) => e as String).toList(),
      extraPrice: (json['extraPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'choices': choices,
      'extraPrice': extraPrice,
    };
  }
}

enum ProductCategory {
  coffee,
  tea,
  freeze,
  food,
  pastry,
  merchandise,
}

