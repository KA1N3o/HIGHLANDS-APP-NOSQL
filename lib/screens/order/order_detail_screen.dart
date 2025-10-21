import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../config/theme.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    // Auto refresh every 30 seconds if order is not completed
    if (_order.status != OrderStatus.completed &&
        _order.status != OrderStatus.cancelled) {
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) {
          _refreshOrder();
        }
      });
    }
  }

  Future<void> _refreshOrder() async {
    try {
      await context.read<OrderProvider>().refreshOrder(_order.id);
      final updatedOrder = context
          .read<OrderProvider>()
          .orders
          .firstWhere((o) => o.id == _order.id);
      setState(() {
        _order = updatedOrder;
      });
      _startAutoRefresh();
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrder,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrder,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        _getStatusIcon(_order.status),
                        size: 64,
                        color: _getStatusColor(_order.status),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getStatusText(_order.status),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: _getStatusColor(_order.status),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStatusDescription(_order.status),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order timeline
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trạng thái đơn hàng',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildTimelineItem(
                        'Đã đặt hàng',
                        _order.orderTime,
                        true,
                      ),
                      _buildTimelineItem(
                        'Đã xác nhận',
                        null,
                        _order.status.index >= OrderStatus.confirmed.index,
                      ),
                      _buildTimelineItem(
                        'Đang chuẩn bị',
                        null,
                        _order.status.index >= OrderStatus.preparing.index,
                      ),
                      _buildTimelineItem(
                        'Sẵn sàng',
                        null,
                        _order.status.index >= OrderStatus.ready.index,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin đơn hàng',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Mã đơn hàng',
                          '#${_order.id.substring(0, 8).toUpperCase()}'),
                      _buildInfoRow('Cửa hàng', _order.store.name),
                      _buildInfoRow('Địa chỉ', _order.store.address),
                      _buildInfoRow('Số điện thoại', _order.store.phone),
                      _buildInfoRow(
                        'Phương thức nhận hàng',
                        _getDeliveryMethodName(_order.deliveryMethod),
                      ),
                      if (_order.pickupTime != null)
                        _buildInfoRow(
                          'Thời gian nhận',
                          '${_order.pickupTime!.day}/${_order.pickupTime!.month} - ${_order.pickupTime!.hour}:${_order.pickupTime!.minute.toString().padLeft(2, '0')}',
                        ),
                      _buildInfoRow(
                        'Thanh toán',
                        _getPaymentMethodName(_order.paymentMethod),
                      ),
                      if (_order.notes != null)
                        _buildInfoRow('Ghi chú', _order.notes!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order items
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sản phẩm',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ..._order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.product.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: AppTheme.backgroundColor,
                                      child: const Icon(Icons.coffee),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      'Size: ${item.size} x${item.quantity}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${item.totalPrice.toInt()}đ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 24),
                      _buildInfoRow('Tạm tính', '${_order.subtotal.toInt()}đ'),
                      _buildInfoRow('Thuế', '${_order.tax.toInt()}đ'),
                      _buildInfoRow('Phí giao hàng', '${_order.deliveryFee.toInt()}đ'),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng cộng',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${_order.total.toInt()}đ',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
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
    );
  }

  Widget _buildTimelineItem(String title, DateTime? time, bool isCompleted,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.primaryGreen : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppTheme.primaryGreen : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isCompleted ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                ),
                if (time != null)
                  Text(
                    '${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.shopping_bag_outlined;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return AppTheme.accentOrange;
      case OrderStatus.ready:
        return AppTheme.successColor;
      case OrderStatus.completed:
        return AppTheme.successColor;
      case OrderStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.preparing:
        return 'Đang chuẩn bị';
      case OrderStatus.ready:
        return 'Sẵn sàng';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Đơn hàng của bạn đang chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đơn hàng đã được xác nhận và đang xử lý';
      case OrderStatus.preparing:
        return 'Đồ uống của bạn đang được chuẩn bị';
      case OrderStatus.ready:
        return 'Đơn hàng đã sẵn sàng, vui lòng đến nhận';
      case OrderStatus.completed:
        return 'Đơn hàng đã hoàn thành';
      case OrderStatus.cancelled:
        return 'Đơn hàng đã bị hủy';
    }
  }

  String _getDeliveryMethodName(DeliveryMethod method) {
    switch (method) {
      case DeliveryMethod.pickup:
        return 'Nhận tại cửa hàng';
      case DeliveryMethod.delivery:
        return 'Giao tận nơi';
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
}

