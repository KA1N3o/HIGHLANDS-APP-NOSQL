import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/cart_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../config/theme.dart';
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

      if (authProvider.currentUser == null) {
        throw Exception('Vui lòng đăng nhập');
      }

      final order = Order(
        id: const Uuid().v4(),
        userId: authProvider.currentUser!.id,
        store: storeProvider.selectedStore!,
        items: cartProvider.items,
        subtotal: cartProvider.subtotal,
        tax: cartProvider.tax,
        total: cartProvider.total,
        status: OrderStatus.pending,
        paymentMethod: _selectedPaymentMethod,
        paymentStatus: PaymentStatus.pending,
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt hàng thất bại: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
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
                              Text('${cartProvider.subtotal.toInt()}đ',
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Thuế (8%)',
                                  style: Theme.of(context).textTheme.bodyMedium),
                              Text('${cartProvider.tax.toInt()}đ',
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
                                '${cartProvider.total.toInt()}đ',
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

