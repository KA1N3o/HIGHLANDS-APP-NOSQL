import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../config/theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cached_image.dart';

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

  // Giá cho 1 món (đã tính size và options, chưa tính quantity)
  double get _pricePerItem {
    // Giá gốc là giá của size nhỏ nhất
    double priceForSize = widget.product.price;
    
    // Tính giá theo size: mỗi size lớn hơn +30% so với size trước
    // Size 0: price, Size 1: price × 1.3, Size 2: price × 1.3 × 1.3
    int sizeIndex = widget.product.sizes.indexOf(_selectedSize);
    if (sizeIndex > 0) {
      for (int i = 0; i < sizeIndex; i++) {
        priceForSize *= 1.3;
      }
    }
    
    // Add extra price for options
    for (var option in widget.product.options) {
      if (_selectedOptions.containsKey(option.name)) {
        priceForSize += option.extraPrice;
      }
    }
    
    return priceForSize;
  }

  // Tổng giá (đã tính quantity)
  double get _totalPrice {
    return _pricePerItem * _quantity;
  }

  void _addToCart() {
    // Check if product is available
    if (!widget.product.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sản phẩm này hiện đang tạm ngưng bán'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedImage(
                          imageUrl: widget.product.imageUrl,
                          fit: BoxFit.cover,
                        ),
                        // Unavailable overlay
                        if (!widget.product.isAvailable)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.remove_shopping_cart,
                                    color: Colors.white,
                                    size: 64,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'TẠM NGƯNG BÁN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
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
                          _pricePerItem.toCurrency(),
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Rating
                        InkWell(
                          onTap: _showRatingDialog,
                          child: Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < widget.product.rating.floor()
                                      ? Icons.star
                                      : (index < widget.product.rating
                                          ? Icons.star_half
                                          : Icons.star_border),
                                  color: Colors.amber,
                                  size: 24,
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewCount} đánh giá)',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, size: 20),
                            ],
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
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          textCapitalization: TextCapitalization.sentences,
                          enableIMEPersonalizedLearning: false,
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
                          _totalPrice.toCurrency(),
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
                      onPressed: widget.product.isAvailable ? _addToCart : null,
                      icon: Icon(
                        widget.product.isAvailable 
                            ? Icons.shopping_cart_outlined 
                            : Icons.remove_shopping_cart,
                      ),
                      label: Text(
                        widget.product.isAvailable 
                            ? 'Thêm vào giỏ' 
                            : 'Tạm ngưng bán',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.product.isAvailable 
                            ? null 
                            : Colors.grey,
                      ),
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

  void _showRatingDialog() {
    int selectedRating = 0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Đánh giá sản phẩm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.product.name,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              if (selectedRating > 0)
                Text(
                  '$selectedRating sao',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: selectedRating > 0
                  ? () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cảm ơn bạn đã đánh giá $selectedRating sao!'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                      // TODO: Send rating to backend API
                    }
                  : null,
              child: const Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
  }
}

