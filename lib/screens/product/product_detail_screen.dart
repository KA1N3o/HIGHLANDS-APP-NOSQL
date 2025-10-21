import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../config/theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String _selectedSize;
  final Map<String, String> _selectedOptions = {};
  final TextEditingController _notesController = TextEditingController();
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Initialize selected size safely
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first;
    } else {
      _selectedSize = 'Medium'; // Default size if no sizes available
    }
    
    // Initialize default options
    for (var option in widget.product.options) {
      if (option.choices.isNotEmpty) {
        _selectedOptions[option.name] = option.choices.first;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double basePrice = widget.product.price;
    
    // Add extra price for options
    for (var option in widget.product.options) {
      if (_selectedOptions.containsKey(option.name)) {
        basePrice += option.extraPrice;
      }
    }
    
    // Size multiplier
    double sizeMultiplier = 1.0;
    if (_selectedSize == 'Large') {
      sizeMultiplier = 1.2;
    } else if (_selectedSize == 'Small') {
      sizeMultiplier = 0.8;
    }
    
    return basePrice * sizeMultiplier * _quantity;
  }

  void _addToCart() {
    final cartItem = CartItem(
      product: widget.product,
      size: _selectedSize,
      selectedOptions: Map.from(_selectedOptions),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      quantity: _quantity,
    );

    context.read<CartProvider>().addItem(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã thêm vào giỏ hàng'),
        backgroundColor: AppTheme.successColor,
        action: SnackBarAction(
          label: 'Xem giỏ hàng',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pushNamed('/cart');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: widget.product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.backgroundColor,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return Container(
                          color: AppTheme.backgroundColor,
                          child: const Icon(
                            Icons.coffee,
                            size: 100,
                            color: AppTheme.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name and price
                        Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.product.price.toInt()}đ',
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          widget.product.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 24),

                        // Size selection
                        if (widget.product.sizes.isNotEmpty) ...[
                          Text(
                            'Kích thước',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: widget.product.sizes.map((size) {
                              final isSelected = _selectedSize == size;
                              return ChoiceChip(
                                label: Text(size),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedSize = size;
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: AppTheme.primaryGreen,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Options
                        ...widget.product.options.map((option) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: option.choices.map((choice) {
                                  final isSelected =
                                      _selectedOptions[option.name] == choice;
                                  return ChoiceChip(
                                    label: Text(choice),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedOptions[option.name] = choice;
                                      });
                                    },
                                    backgroundColor: Colors.white,
                                    selectedColor: AppTheme.primaryGreen,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }),

                        // Notes
                        Text(
                          'Ghi chú',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Thêm ghi chú cho món này...',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Quantity
                        Text(
                          'Số lượng',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1
                                  ? () {
                                      setState(() {
                                        _quantity--;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              iconSize: 32,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.primaryGreen),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$_quantity',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              iconSize: 32,
                              color: AppTheme.primaryGreen,
                            ),
                          ],
                        ),
                      ],
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tổng cộng',
                          style:
                              Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${_totalPrice.toInt()}đ',
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addToCart,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Thêm vào giỏ'),
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

