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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: ProductCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ProductCategory.coffee,
      ),
      sizes: (json['sizes'] as List<dynamic>).map((e) => e as String).toList(),
      options: (json['options'] as List<dynamic>)
          .map((e) => ProductOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      preparationTime: json['preparationTime'] as int? ?? 10,
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
  smoothie,
  food,
  pastry,
}

