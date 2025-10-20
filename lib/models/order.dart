import 'cart_item.dart';
import 'store.dart';

class Order {
  final String id;
  final String userId;
  final Store store;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime orderTime;
  final DateTime? pickupTime;
  final DateTime? completedTime;
  final String? notes;

  Order({
    required this.id,
    required this.userId,
    required this.store,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderTime,
    this.pickupTime,
    this.completedTime,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      store: Store.fromJson(json['store'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
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
      orderTime: DateTime.parse(json['orderTime'] as String),
      pickupTime: json['pickupTime'] != null
          ? DateTime.parse(json['pickupTime'] as String)
          : null,
      completedTime: json['completedTime'] != null
          ? DateTime.parse(json['completedTime'] as String)
          : null,
      notes: json['notes'] as String?,
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
    double? total,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    DateTime? orderTime,
    DateTime? pickupTime,
    DateTime? completedTime,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      store: store ?? this.store,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderTime: orderTime ?? this.orderTime,
      pickupTime: pickupTime ?? this.pickupTime,
      completedTime: completedTime ?? this.completedTime,
      notes: notes ?? this.notes,
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

