import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cached_image.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final storeProvider = context.watch<StoreProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          if (cartProvider.items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa giỏ hàng'),
                    content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          cartProvider.clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Xóa tất cả',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: cartProvider.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Giỏ hàng trống',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm sản phẩm để tiếp tục',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Mua sắm ngay'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product image
                              CachedImage(
                                imageUrl: item.product.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              const SizedBox(width: 12),

                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Size: ${item.size}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                    if (item.selectedOptions.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.selectedOptions.values.join(', '),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                      ),
                                    ],
                                    if (item.notes != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Ghi chú: ${item.notes}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppTheme.textSecondary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        // Quantity controls
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppTheme.primaryGreen,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  if (item.quantity > 1) {
                                                    cartProvider.updateQuantity(
                                                      index,
                                                      item.quantity - 1,
                                                    );
                                                  }
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6),
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                                child: Text(
                                                  '${item.quantity}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  cartProvider.updateQuantity(
                                                    index,
                                                    item.quantity + 1,
                                                  );
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 18,
                                                    color: AppTheme.primaryGreen,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          item.totalPrice.toCurrency(),
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

                              // Delete button
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: AppTheme.errorColor,
                                onPressed: () {
                                  cartProvider.removeItem(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Summary
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tạm tính',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              cartProvider.subtotal.toCurrency(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Thuế (8%)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              cartProvider.tax.toCurrency(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Phí giao hàng',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              cartProvider.deliveryFee.toCurrency(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng cộng',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
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
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (storeProvider.selectedStore == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Vui lòng chọn cửa hàng trước'),
                                  ),
                                );
                                Navigator.pushNamed(context, '/stores');
                              } else {
                                // Debug: Check auth before navigating to checkout
                                final authProvider = context.read<AuthProvider>();
                                print('DEBUG Cart->Checkout: User = ${authProvider.currentUser?.email}');
                                print('DEBUG Cart->Checkout: Token exists = ${authProvider.authToken != null}');
                                
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CheckoutScreen(),
                                  ),
                                );
                              }
                            },
                            child: const Text('Tiến hành thanh toán'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

