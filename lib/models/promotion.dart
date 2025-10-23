enum PromotionType {
  percentage,
  fixedAmount,
  freeShipping,
}

class Promotion {
  final String id;
  final String code;
  final String name;
  final String description;
  final PromotionType type;
  final double value;
  final double minOrderValue;
  final double? maxDiscount;
  final int? usageLimit;
  final int usageCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Promotion({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.minOrderValue = 0,
    this.maxDiscount,
    this.usageLimit,
    this.usageCount = 0,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isValid {
    if (!isActive) return false;
    
    final now = DateTime.now();
    if (now.isBefore(startDate) || now.isAfter(endDate)) return false;
    
    if (usageLimit != null && usageCount >= usageLimit!) return false;
    
    return true;
  }

  double calculateDiscount(double orderValue) {
    if (!isValid) return 0;
    if (orderValue < minOrderValue) return 0;

    double discount = 0;

    switch (type) {
      case PromotionType.percentage:
        discount = (orderValue * value) / 100;
        if (maxDiscount != null) {
          discount = discount > maxDiscount! ? maxDiscount! : discount;
        }
        break;
      case PromotionType.fixedAmount:
        discount = value;
        break;
      case PromotionType.freeShipping:
        // Will be handled separately in shipping calculation
        discount = 0;
        break;
    }

    return discount > orderValue ? orderValue : discount;
  }

  String get displayValue {
    switch (type) {
      case PromotionType.percentage:
        return '${value.toStringAsFixed(0)}%';
      case PromotionType.fixedAmount:
        return '${value.toStringAsFixed(0)}đ';
      case PromotionType.freeShipping:
        return 'Miễn phí ship';
    }
  }

  String get displayMaxDiscount {
    if (maxDiscount != null && type == PromotionType.percentage) {
      return 'Tối đa ${maxDiscount!.toStringAsFixed(0)}đ';
    }
    return '';
  }

  String get displayMinOrderValue {
    if (minOrderValue > 0) {
      return 'Đơn tối thiểu ${minOrderValue.toStringAsFixed(0)}đ';
    }
    return 'Không có giới hạn';
  }

  factory Promotion.fromJson(Map<String, dynamic> json) {
    PromotionType parseType(String? typeStr) {
      switch (typeStr) {
        case 'percentage':
          return PromotionType.percentage;
        case 'fixed_amount':
          return PromotionType.fixedAmount;
        case 'free_shipping':
          return PromotionType.freeShipping;
        default:
          return PromotionType.percentage;
      }
    }

    double parseDouble(dynamic value, {double defaultValue = 0.0}) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed ?? defaultValue;
      }
      return defaultValue;
    }

    int parseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is num) return value.toInt();
      return defaultValue;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    bool parseBool(dynamic value, bool defaultValue) {
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return defaultValue;
    }

    return Promotion(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: parseType(json['type']?.toString()),
      value: parseDouble(json['value']),
      minOrderValue: parseDouble(json['minOrderValue']),
      maxDiscount: json['maxDiscount'] != null 
          ? parseDouble(json['maxDiscount']) 
          : null,
      usageLimit: json['usageLimit'] != null 
          ? parseInt(json['usageLimit']) 
          : null,
      usageCount: parseInt(json['usageCount']),
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      isActive: parseBool(json['isActive'], true),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    String typeToString(PromotionType type) {
      switch (type) {
        case PromotionType.percentage:
          return 'percentage';
        case PromotionType.fixedAmount:
          return 'fixed_amount';
        case PromotionType.freeShipping:
          return 'free_shipping';
      }
    }

    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'type': typeToString(type),
      'value': value,
      'minOrderValue': minOrderValue,
      'maxDiscount': maxDiscount,
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Promotion copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    PromotionType? type,
    double? value,
    double? minOrderValue,
    double? maxDiscount,
    int? usageLimit,
    int? usageCount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Promotion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

