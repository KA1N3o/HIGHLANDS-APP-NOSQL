import 'cart_item.dart';
import 'store.dart';

class Order {
  final String id;
  final String userId;
  final Store store;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DeliveryMethod deliveryMethod;
  final Map<String, dynamic>? deliveryAddress;
  final DateTime orderTime;
  final DateTime? pickupTime;
  final DateTime? completedTime;
  final String? notes;
  final String? promotionCode;

  Order({
    required this.id,
    required this.userId,
    required this.store,
    required this.items,
    required this.subtotal,
    required this.tax,
    this.deliveryFee = 0.0,
    this.discount = 0.0,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.deliveryMethod = DeliveryMethod.pickup,
    this.deliveryAddress,
    required this.orderTime,
    this.pickupTime,
    this.completedTime,
    this.notes,
    this.promotionCode,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse DateTime - handle null and empty strings
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return null;
      }
    }
    
    // Parse deliveryAddress - handle both object and null
    Map<String, dynamic>? parseDeliveryAddress(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return null;
    }
    
    return Order(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      store: Store.fromJson(json['store'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.card,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      deliveryMethod: DeliveryMethod.values.firstWhere(
        (e) => e.name == json['deliveryMethod'],
        orElse: () => DeliveryMethod.pickup,
      ),
      deliveryAddress: parseDeliveryAddress(json['deliveryAddress']),
      orderTime: parseDateTime(json['orderTime']) ?? DateTime.now(),
      pickupTime: parseDateTime(json['pickupTime']),
      completedTime: parseDateTime(json['completedTime']),
      notes: json['notes']?.toString(),
      promotionCode: json['promotionCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    // Validate all items have valid productId
    for (final item in items) {
      if (item.product.id.isEmpty) {
        throw Exception('Product ID cannot be empty for item: ${item.product.name}');
      }
    }
    
    return {
      'id': id,
      'userId': userId,
      'storeId': store.id, // Send storeId instead of full store object
      'items': items.map((e) => {
        'productId': e.product.id, // Ensure product.id is not null
        'quantity': e.quantity,
        'size': e.size,
        'options': e.selectedOptions,
      }).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'deliveryMethod': deliveryMethod.name,
      'orderTime': orderTime.toIso8601String(),
      'pickupTime': pickupTime?.toIso8601String(),
      'completedTime': completedTime?.toIso8601String(),
      'notes': notes,
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    Store? store,
    List<CartItem>? items,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? discount,
    double? total,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    DeliveryMethod? deliveryMethod,
    Map<String, dynamic>? deliveryAddress,
    DateTime? orderTime,
    DateTime? pickupTime,
    DateTime? completedTime,
    String? notes,
    String? promotionCode,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      store: store ?? this.store,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      orderTime: orderTime ?? this.orderTime,
      pickupTime: pickupTime ?? this.pickupTime,
      completedTime: completedTime ?? this.completedTime,
      notes: notes ?? this.notes,
      promotionCode: promotionCode ?? this.promotionCode,
    );
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled,
}

enum PaymentMethod {
  card,
  cash,
  momo,
  zalopay,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

enum DeliveryMethod {
  pickup,    // Nhận tại cửa hàng
  delivery,  // Giao tận nơi
}

