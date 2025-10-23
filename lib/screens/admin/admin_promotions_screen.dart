import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/promotion_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/promotion.dart';
import '../../config/theme.dart';

class AdminPromotionsScreen extends StatefulWidget {
  const AdminPromotionsScreen({super.key});

  @override
  State<AdminPromotionsScreen> createState() => _AdminPromotionsScreenState();
}

class _AdminPromotionsScreenState extends State<AdminPromotionsScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load promotions (will use cache if still valid)
      if (mounted) {
        _loadPromotionsWithRetry();
      }
    });
  }
  
  // Try to load promotions, retry if auth not ready yet
  Future<void> _loadPromotionsWithRetry() async {
    print('AdminPromotionsScreen: Starting _loadPromotionsWithRetry');
    
    if (!mounted) return;
    
    setState(() {
      _errorMessage = null;
    });
    
    final promotionProvider = context.read<PromotionProvider>();
    final authProvider = context.read<AuthProvider>();
    
    // Wait a bit to ensure auth is fully loaded
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    // Check auth first
    if (authProvider.authToken == null) {
      print('AdminPromotionsScreen: No auth token available');
      if (mounted) {
        setState(() {
          _errorMessage = 'Vui lòng đăng nhập lại';
        });
      }
      return;
    }
    
    print('AdminPromotionsScreen: First attempt to load promotions (auth token available)');
    // First attempt
    await promotionProvider.loadAllPromotions(forceRefresh: true);
    
    print('AdminPromotionsScreen: After first load, promotions count: ${promotionProvider.promotions.length}');
    
    // If still no promotions and not loading, might be network issue
    // Wait a bit more and try again (up to 3 attempts)
    int attempts = 0;
    while (promotionProvider.promotions.isEmpty && 
           !promotionProvider.isLoading && 
           attempts < 3 && 
           mounted) {
      attempts++;
      print('AdminPromotionsScreen: No promotions loaded, attempt $attempts/3 - retrying in 500ms');
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await promotionProvider.loadAllPromotions(forceRefresh: true);
        print('AdminPromotionsScreen: After attempt $attempts, promotions count: ${promotionProvider.promotions.length}');
      }
    }
    
    if (promotionProvider.promotions.isEmpty && mounted) {
      print('AdminPromotionsScreen: Failed to load promotions after $attempts attempts');
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu. Vui lòng kiểm tra kết nối mạng hoặc khởi động lại backend.';
      });
    } else {
      print('AdminPromotionsScreen: Successfully loaded ${promotionProvider.promotions.length} promotions');
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    }
  }

  Future<void> _refreshPromotions() async {
    if (!mounted) return;
    await context.read<PromotionProvider>().loadAllPromotions(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final promotionProvider = context.watch<PromotionProvider>();
    final promotions = promotionProvider.promotions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý mã giảm giá'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPromotions,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPromotionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tạo mã giảm giá'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: promotionProvider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải dữ liệu...'),
                ],
              ),
            )
          : promotions.isEmpty
              ? RefreshIndicator(
                  onRefresh: _refreshPromotions,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _errorMessage != null ? Icons.error_outline : Icons.discount_outlined,
                            size: 64,
                            color: _errorMessage != null ? Colors.red.shade400 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _errorMessage ?? 'Chưa có mã giảm giá nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: _errorMessage != null ? Colors.red : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_errorMessage != null)
                            TextButton.icon(
                              onPressed: _loadPromotionsWithRetry,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                            )
                          else
                            TextButton.icon(
                              onPressed: () => _showPromotionDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Tạo mã giảm giá đầu tiên'),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshPromotions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: promotions.length,
                    itemBuilder: (context, index) {
                      final promotion = promotions[index];
                      return _buildPromotionCard(context, promotion);
                    },
                  ),
                ),
    );
  }

  Widget _buildPromotionCard(BuildContext context, Promotion promotion) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isExpired = DateTime.now().isAfter(promotion.endDate);
    final isNotStarted = DateTime.now().isBefore(promotion.startDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: promotion.isValid
                ? AppTheme.primaryGreen.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.discount,
            color: promotion.isValid ? AppTheme.primaryGreen : Colors.grey,
            size: 28,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                promotion.code,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            _buildStatusChip(promotion, isExpired, isNotStarted),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              promotion.name,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              promotion.displayValue,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (promotion.usageLimit != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Còn lại: ${promotion.usageLimit! - promotion.usageCount} lượt',
                    style: TextStyle(
                      fontSize: 13,
                      color: (promotion.usageLimit! - promotion.usageCount) <= 10
                          ? Colors.orange
                          : AppTheme.textSecondary,
                      fontWeight: (promotion.usageLimit! - promotion.usageCount) <= 10
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'toggle':
                _toggleActive(context, promotion);
                break;
              case 'edit':
                _showPromotionDialog(context, promotion: promotion);
                break;
              case 'delete':
                _deletePromotion(context, promotion);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    promotion.isActive ? Icons.pause_circle : Icons.play_circle,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(promotion.isActive ? 'Tắt' : 'Bật'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (promotion.description.isNotEmpty) ...[
                  Text(
                    promotion.description,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const Divider(height: 24),
                ],
                _buildDetailRow('Loại', _getTypeName(promotion.type)),
                _buildDetailRow('Giá trị', promotion.displayValue),
                if (promotion.maxDiscount != null)
                  _buildDetailRow('Giảm tối đa', promotion.displayMaxDiscount),
                _buildDetailRow('Đơn tối thiểu', promotion.displayMinOrderValue),
                _buildDetailRow('Bắt đầu', dateFormat.format(promotion.startDate)),
                _buildDetailRow('Kết thúc', dateFormat.format(promotion.endDate)),
                if (promotion.usageLimit != null)
                  _buildDetailRow(
                    'Giới hạn',
                    '${promotion.usageCount}/${promotion.usageLimit}',
                  )
                else
                  _buildDetailRow('Đã dùng', '${promotion.usageCount}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(Promotion promotion, bool isExpired, bool isNotStarted) {
    String label;
    Color color;

    if (!promotion.isActive) {
      label = 'Đã tắt';
      color = Colors.grey;
    } else if (isExpired) {
      label = 'Hết hạn';
      color = Colors.red;
    } else if (isNotStarted) {
      label = 'Chưa bắt đầu';
      color = Colors.orange;
    } else if (promotion.usageLimit != null && 
               promotion.usageCount >= promotion.usageLimit!) {
      label = 'Hết lượt';
      color = Colors.red;
    } else {
      label = 'Đang hoạt động';
      color = AppTheme.successColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeName(PromotionType type) {
    switch (type) {
      case PromotionType.percentage:
        return 'Phần trăm';
      case PromotionType.fixedAmount:
        return 'Số tiền cố định';
      case PromotionType.freeShipping:
        return 'Miễn phí ship';
    }
  }

  void _toggleActive(BuildContext context, Promotion promotion) async {
    try {
      await context.read<PromotionProvider>().updatePromotion(
        promotion.id,
        {'isActive': !promotion.isActive},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              promotion.isActive ? 'Đã tắt mã giảm giá' : 'Đã bật mã giảm giá',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deletePromotion(BuildContext context, Promotion promotion) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa mã "${promotion.code}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog first
              Navigator.pop(dialogContext);
              
              // Use the parent context (not dialog context)
              if (!mounted) return;
              
              try {
                await context.read<PromotionProvider>().deletePromotion(promotion.id);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa mã giảm giá'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showPromotionDialog(BuildContext context, {Promotion? promotion}) {
    showDialog(
      context: context,
      builder: (context) => _PromotionDialog(promotion: promotion),
    );
  }
}

class _PromotionDialog extends StatefulWidget {
  final Promotion? promotion;

  const _PromotionDialog({this.promotion});

  @override
  State<_PromotionDialog> createState() => _PromotionDialogState();
}

class _PromotionDialogState extends State<_PromotionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _valueController;
  late TextEditingController _minOrderValueController;
  late TextEditingController _maxDiscountController;
  late TextEditingController _usageLimitController;
  
  PromotionType _selectedType = PromotionType.percentage;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  bool _hasUsageLimit = false;
  bool _hasMaxDiscount = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.promotion != null) {
      final p = widget.promotion!;
      print('Editing promotion: ${p.code}');
      print('  Name: ${p.name}');
      print('  Type: ${p.type}');
      print('  Value: ${p.value}');
      print('  Min order: ${p.minOrderValue}');
      
      _codeController = TextEditingController(text: p.code);
      _nameController = TextEditingController(text: p.name);
      _descriptionController = TextEditingController(text: p.description);
      _valueController = TextEditingController(text: p.value.toString());
      _minOrderValueController = TextEditingController(text: p.minOrderValue.toString());
      _maxDiscountController = TextEditingController(
        text: p.maxDiscount?.toString() ?? '',
      );
      _usageLimitController = TextEditingController(
        text: p.usageLimit?.toString() ?? '',
      );
      _selectedType = p.type;
      _startDate = p.startDate;
      _endDate = p.endDate;
      _isActive = p.isActive;
      _hasUsageLimit = p.usageLimit != null;
      _hasMaxDiscount = p.maxDiscount != null;
      
      print('Controllers initialized:');
      print('  Code: ${_codeController.text}');
      print('  Name: ${_nameController.text}');
      print('  Value: ${_valueController.text}');
    } else {
      print('Creating new promotion');
      _codeController = TextEditingController();
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _valueController = TextEditingController();
      _minOrderValueController = TextEditingController(text: '0');
      _maxDiscountController = TextEditingController();
      _usageLimitController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _minOrderValueController.dispose();
    _maxDiscountController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.promotion == null ? 'Tạo mã giảm giá' : 'Sửa mã giảm giá'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Mã giảm giá *',
                  hintText: 'VD: SUMMER2024',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên chương trình *',
                  hintText: 'VD: Giảm giá mùa hè',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Mô tả chương trình',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PromotionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Loại giảm giá *',
                ),
                items: const [
                  DropdownMenuItem(
                    value: PromotionType.percentage,
                    child: Text('Phần trăm'),
                  ),
                  DropdownMenuItem(
                    value: PromotionType.fixedAmount,
                    child: Text('Số tiền cố định'),
                  ),
                  DropdownMenuItem(
                    value: PromotionType.freeShipping,
                    child: Text('Miễn phí ship'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_selectedType != PromotionType.freeShipping)
                TextFormField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: _selectedType == PromotionType.percentage
                        ? 'Giá trị (%) *'
                        : 'Giá trị (VNĐ) *',
                    hintText: _selectedType == PromotionType.percentage ? '10' : '50000',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị';
                    }
                    final number = double.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Giá trị phải lớn hơn 0';
                    }
                    if (_selectedType == PromotionType.percentage && number > 100) {
                      return 'Phần trăm không được vượt quá 100';
                    }
                    return null;
                  },
                ),
              if (_selectedType != PromotionType.freeShipping)
                const SizedBox(height: 16),
              TextFormField(
                controller: _minOrderValueController,
                decoration: const InputDecoration(
                  labelText: 'Giá trị đơn hàng tối thiểu (VNĐ)',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = double.tryParse(value);
                    if (number == null || number < 0) {
                      return 'Giá trị không hợp lệ';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_selectedType == PromotionType.percentage) ...[
                CheckboxListTile(
                  title: const Text('Có giới hạn giảm tối đa'),
                  value: _hasMaxDiscount,
                  onChanged: (value) {
                    setState(() {
                      _hasMaxDiscount = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                if (_hasMaxDiscount) ...[
                  TextFormField(
                    controller: _maxDiscountController,
                    decoration: const InputDecoration(
                      labelText: 'Giảm tối đa (VNĐ)',
                      hintText: '100000',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_hasMaxDiscount && (value == null || value.isEmpty)) {
                        return 'Vui lòng nhập giá trị';
                      }
                      if (value != null && value.isNotEmpty) {
                        final number = double.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Giá trị phải lớn hơn 0';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],
              CheckboxListTile(
                title: const Text('Giới hạn số lần sử dụng'),
                value: _hasUsageLimit,
                onChanged: (value) {
                  setState(() {
                    _hasUsageLimit = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              if (_hasUsageLimit) ...[
                TextFormField(
                  controller: _usageLimitController,
                  decoration: const InputDecoration(
                    labelText: 'Số lần sử dụng tối đa',
                    hintText: '100',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_hasUsageLimit && (value == null || value.isEmpty)) {
                      return 'Vui lòng nhập số lần';
                    }
                    if (value != null && value.isNotEmpty) {
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Số lần phải lớn hơn 0';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              ListTile(
                title: const Text('Ngày bắt đầu'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('Ngày kết thúc'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Kích hoạt'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
          ),
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Note: We don't check for duplicate codes client-side because:
    // 1. Client cache might be outdated or contain invalid data
    // 2. Backend is the source of truth and will validate properly
    // 3. Backend will return a clear error message if code exists

    // Calculate value based on type
    double value = 0;
    if (_selectedType == PromotionType.freeShipping) {
      value = 0;
    } else {
      final valueText = _valueController.text.trim();
      if (valueText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập giá trị giảm giá'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      value = double.parse(valueText);
    }

    final promotionData = {
      'code': _codeController.text.trim().toUpperCase(),
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'type': _selectedType == PromotionType.percentage
          ? 'percentage'
          : _selectedType == PromotionType.fixedAmount
              ? 'fixed_amount'
              : 'free_shipping',
      'value': value,
      'minOrderValue': double.parse(_minOrderValueController.text.isEmpty 
          ? '0' 
          : _minOrderValueController.text),
      'maxDiscount': _hasMaxDiscount && _maxDiscountController.text.isNotEmpty
          ? double.parse(_maxDiscountController.text)
          : null,
      'usageLimit': _hasUsageLimit && _usageLimitController.text.isNotEmpty
          ? int.parse(_usageLimitController.text)
          : null,
      'startDate': _startDate.toIso8601String(),
      'endDate': _endDate.toIso8601String(),
      'isActive': _isActive,
    };

    try {
      if (widget.promotion == null) {
        print('Creating new promotion...');
        await context.read<PromotionProvider>().createPromotion(promotionData);
        print('Promotion created successfully');
      } else {
        print('Updating promotion ${widget.promotion!.id}...');
        await context.read<PromotionProvider>().updatePromotion(
          widget.promotion!.id,
          promotionData,
        );
        print('Promotion updated successfully');
      }

      if (mounted) {
        Navigator.pop(context);
        
        // Verify the promotion was added
        final provider = context.read<PromotionProvider>();
        print('Current promotions count: ${provider.promotions.length}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.promotion == null
                  ? 'Đã tạo mã giảm giá (${provider.promotions.length} mã)'
                  : 'Đã cập nhật mã giảm giá',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      print('Error saving promotion: $e');
      if (mounted) {
        // Extract meaningful error message
        String errorMessage = 'Lỗi không xác định';
        final errorStr = e.toString();
        
        if (errorStr.contains('already exists')) {
          errorMessage = 'Mã giảm giá đã tồn tại. Vui lòng chọn mã khác.';
        } else if (errorStr.contains('required')) {
          errorMessage = 'Vui lòng điền đầy đủ thông tin bắt buộc';
        } else if (errorStr.contains('invalid')) {
          errorMessage = 'Thông tin không hợp lệ. Vui lòng kiểm tra lại';
        } else {
          // Try to extract the actual error message
          final match = RegExp(r'Exception:\s*(.+)$').firstMatch(errorStr);
          if (match != null) {
            errorMessage = match.group(1) ?? errorStr;
          } else {
            errorMessage = errorStr.replaceAll('Exception: ', '');
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}

