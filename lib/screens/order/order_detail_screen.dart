import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'dart:typed_data';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../config/theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cached_image.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _order;
  bool _isRefreshing = false;
  final ScreenshotController _screenshotController = ScreenshotController();

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
    setState(() {
      _isRefreshing = true;
    });

    try {
      await context.read<OrderProvider>().refreshOrder(_order.id);
      final updatedOrder = context
          .read<OrderProvider>()
          .orders
          .firstWhere((o) => o.id == _order.id);
      if (mounted) {
        setState(() {
          _order = updatedOrder;
        });
      }
      _startAutoRefresh();
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _saveBarcode() async {
    try {
      // Check if we have permission
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      // Capture the barcode as an image
      final Uint8List? imageBytes = await _screenshotController.capture();
      
      if (imageBytes != null) {
        // Save to gallery using Gal
        await Gal.putImageBytes(
          imageBytes,
          name: 'highlands_order_${_order.id.substring(0, 8)}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã lưu mã vạch vào thư viện'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _cancelOrder() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Cancel order
      await context.read<OrderProvider>().cancelOrder(
        _order.id,
        reason: 'Customer request',
      );

      if (mounted) {
        // Get updated order from provider and update local state immediately
        final updatedOrder = context
            .read<OrderProvider>()
            .orders
            .firstWhere((o) => o.id == _order.id);
        
        setState(() {
          _order = updatedOrder;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy đơn hàng thành công'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        textAlign: TextAlign.center,
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
                      // Show normal timeline if not cancelled
                      if (_order.status != OrderStatus.cancelled) ...[
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
                      // Show cancelled timeline
                      if (_order.status == OrderStatus.cancelled) ...[
                        _buildTimelineItem(
                          'Đã đặt hàng',
                          _order.orderTime,
                          true,
                        ),
                        _buildTimelineItem(
                          'Đã hủy',
                          null,
                          true,
                          isLast: true,
                          isCancelled: true,
                        ),
                      ],
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
                              CachedImage(
                                imageUrl: item.product.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(8),
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
                                    if (item.selectedToppings.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Topping: ${item.selectedToppings.map((t) => t.name).join(', ')}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppTheme.primaryGreen,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                item.totalPrice.toCurrency(),
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
                      _buildInfoRow('Tạm tính', _order.subtotal.toCurrency()),
                      _buildInfoRow('Thuế', _order.tax.toCurrency()),
                      _buildInfoRow('Phí giao hàng', _order.deliveryFee.toCurrency()),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng cộng',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            _order.total.toCurrency(),
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
              const SizedBox(height: 16),

              // Barcode section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Mã đơn hàng',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      
                      const SizedBox(height: 16),
                      Screenshot(
                        controller: _screenshotController,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          color: Colors.white,
                          child: Column(
                            children: [
                              BarcodeWidget(
                                barcode: Barcode.code128(),
                                data: 'HL${_order.id.toUpperCase()}',
                                width: 250,
                                height: 100,
                                drawText: true,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '#${_order.id.substring(0, 8).toUpperCase()}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                              ),
                              
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveBarcode,
                          icon: const Icon(Icons.download),
                          label: const Text('Lưu mã vạch'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
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
                      if (_order.deliveryAddress != null) ...[
                        _buildInfoRow(
                          'Địa chỉ giao hàng',
                          '${_order.deliveryAddress!['street']}, ${_order.deliveryAddress!['ward']}',
                        ),
                      ],
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
              
              // Cancel order button (only show if order can be cancelled)
              if (_order.status == OrderStatus.pending || 
                  _order.status == OrderStatus.confirmed) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cancelOrder,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Hủy đơn hàng'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime? time, bool isCompleted,
      {bool isLast = false, bool isCancelled = false}) {
    final color = isCancelled 
        ? AppTheme.errorColor 
        : (isCompleted ? AppTheme.primaryGreen : Colors.grey[300]!);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? Icon(
                      isCancelled ? Icons.close : Icons.check, 
                      size: 16, 
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: color,
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
                        color: isCancelled 
                            ? AppTheme.errorColor
                            : (isCompleted
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary),
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

