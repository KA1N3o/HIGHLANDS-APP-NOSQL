import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/cart_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../config/theme.dart';
import '../../utils/currency_formatter.dart';
import '../order/order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;
  final _notesController = TextEditingController();
  DateTime? _selectedPickupTime;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Default pickup time: 20 minutes from now
    _selectedPickupTime = DateTime.now().add(const Duration(minutes: 20));
    
    // Check authentication on init (only for debugging, actual check is in _placeOrder)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      print('DEBUG CheckoutScreen init: User = ${authProvider.currentUser?.email}, Token exists = ${authProvider.authToken != null}');
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupTime() async {
    final now = DateTime.now();
    final initialTime = _selectedPickupTime ?? now.add(const Duration(minutes: 20));

    final date = await showDatePicker(
      context: context,
      initialDate: initialTime,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialTime),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedPickupTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _placeOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final cartProvider = context.read<CartProvider>();
      final storeProvider = context.read<StoreProvider>();
      final authProvider = context.read<AuthProvider>();
      final orderProvider = context.read<OrderProvider>();

      if (storeProvider.selectedStore == null) {
        throw Exception('Vui lòng chọn cửa hàng');
      }

      // Debug: Check token
      print('DEBUG _placeOrder: User = ${authProvider.currentUser?.email}');
      print('DEBUG _placeOrder: Token exists = ${authProvider.authToken != null}');
      
      if (authProvider.currentUser == null) {
        throw Exception('Vui lòng đăng nhập để tiếp tục');
      }
      
      if (authProvider.authToken == null) {
        throw Exception('Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại');
      }

      final order = Order(
        id: const Uuid().v4(),
        userId: authProvider.currentUser!.id,
        store: storeProvider.selectedStore!,
        items: cartProvider.items,
        subtotal: cartProvider.subtotal,
        tax: cartProvider.tax,
        deliveryFee: cartProvider.deliveryFee,
        total: cartProvider.total,
        status: OrderStatus.pending,
        paymentMethod: _selectedPaymentMethod,
        paymentStatus: PaymentStatus.pending,
        deliveryMethod: cartProvider.deliveryMethod,
        orderTime: DateTime.now(),
        pickupTime: _selectedPickupTime,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Create order
      final createdOrder = await orderProvider.createOrder(order);

      // Clear cart
      cartProvider.clear();

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Navigate to success screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(order: createdOrder),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        String errorMessage = 'Đặt hàng thất bại';
        bool shouldRedirectToLogin = false;
        
        // Parse error for better user message
        final errorStr = e.toString();
        if (errorStr.contains('No token provided') || 
            errorStr.contains('401') || 
            errorStr.contains('Unauthorized')) {
          errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại';
          shouldRedirectToLogin = true;
        } else if (errorStr.contains('network') || 
                   errorStr.contains('SocketException') ||
                   errorStr.contains('Connection')) {
          errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng';
        } else if (errorStr.contains('Vui lòng')) {
          errorMessage = errorStr.replaceAll('Exception: ', '');
        } else {
          errorMessage = 'Đặt hàng thất bại. Vui lòng thử lại sau';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Redirect to login if auth error
        if (shouldRedirectToLogin) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final storeProvider = context.watch<StoreProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store info
                  Text(
                    'Cửa hàng nhận hàng',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.store),
                      title: Text(storeProvider.selectedStore?.name ?? ''),
                      subtitle: Text(storeProvider.selectedStore?.address ?? ''),
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/stores');
                        },
                        child: const Text('Đổi'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Delivery method
                  Text(
                    'Phương thức nhận hàng',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...DeliveryMethod.values.map((method) {
                    return Card(
                      child: RadioListTile<DeliveryMethod>(
                        value: method,
                        groupValue: cartProvider.deliveryMethod,
                        onChanged: (value) {
                          cartProvider.setDeliveryMethod(value!);
                        },
                        title: Text(_getDeliveryMethodName(method)),
                        subtitle: Text(_getDeliveryMethodDescription(method)),
                        secondary: Icon(_getDeliveryMethodIcon(method)),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Pickup time
                  Text(
                    'Thời gian nhận hàng',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(_selectedPickupTime != null
                          ? '${_selectedPickupTime!.day}/${_selectedPickupTime!.month}/${_selectedPickupTime!.year} - ${_selectedPickupTime!.hour}:${_selectedPickupTime!.minute.toString().padLeft(2, '0')}'
                          : 'Chọn thời gian'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _selectPickupTime,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment method
                  Text(
                    'Phương thức thanh toán',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...PaymentMethod.values.map((method) {
                    return Card(
                      child: RadioListTile<PaymentMethod>(
                        value: method,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        title: Text(_getPaymentMethodName(method)),
                        secondary: Icon(_getPaymentMethodIcon(method)),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Notes
                  Text(
                    'Ghi chú đơn hàng',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Thêm ghi chú cho đơn hàng...',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order summary
                  Text(
                    'Tóm tắt đơn hàng',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tạm tính',
                                  style: Theme.of(context).textTheme.bodyMedium),
                              Text(cartProvider.subtotal.toCurrency(),
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Thuế (8%)',
                                  style: Theme.of(context).textTheme.bodyMedium),
                              Text(cartProvider.tax.toCurrency(),
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Phí giao hàng',
                                  style: Theme.of(context).textTheme.bodyMedium),
                              Text(cartProvider.deliveryFee.toCurrency(),
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tổng cộng',
                                  style: Theme.of(context).textTheme.titleLarge),
                              Text(
                                cartProvider.total.toCurrency(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppTheme.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _placeOrder,
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Đặt hàng'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDeliveryMethodName(DeliveryMethod method) {
    switch (method) {
      case DeliveryMethod.pickup:
        return 'Nhận tại cửa hàng';
      case DeliveryMethod.delivery:
        return 'Giao tận nơi';
    }
  }

  String _getDeliveryMethodDescription(DeliveryMethod method) {
    switch (method) {
      case DeliveryMethod.pickup:
        return 'Miễn phí - Nhận hàng tại cửa hàng';
      case DeliveryMethod.delivery:
        return 'Phí giao hàng 15,000đ';
    }
  }

  IconData _getDeliveryMethodIcon(DeliveryMethod method) {
    switch (method) {
      case DeliveryMethod.pickup:
        return Icons.store;
      case DeliveryMethod.delivery:
        return Icons.delivery_dining;
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return 'Thẻ tín dụng/Ghi nợ';
      case PaymentMethod.cash:
        return 'Tiền mặt';
      case PaymentMethod.momo:
        return 'Ví MoMo';
      case PaymentMethod.zalopay:
        return 'ZaloPay';
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.momo:
        return Icons.account_balance_wallet;
      case PaymentMethod.zalopay:
        return Icons.account_balance_wallet;
    }
  }
}

