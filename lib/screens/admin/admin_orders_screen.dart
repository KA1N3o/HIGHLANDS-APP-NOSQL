import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../models/store.dart';
import '../../models/user.dart';
import '../../config/theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cached_image.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _loadingOrders = {}; // Track loading state per order
  Store? _selectedStore;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStoresAndOrders();
    });
  }

  Future<void> _loadStoresAndOrders() async {
    try {
      final storeProvider = context.read<StoreProvider>();
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      
      await storeProvider.loadStores();
      
      // If staff with assigned store, auto-select that store
      if (currentUser != null && 
          currentUser.role == UserRole.staff && 
          currentUser.assignedStoreId != null) {
        final assignedStore = storeProvider.stores.firstWhere(
          (store) => store.id == currentUser.assignedStoreId,
          orElse: () => storeProvider.stores.first,
        );
        
        setState(() {
          _selectedStore = assignedStore;
        });
        
        await _loadOrders();
      }
      // Admin: Don't auto-select store, wait for user to select
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh sách cửa hàng: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      // Admin loads ALL orders, not just their own
      // Limit to 50 for better performance
      await context.read<OrderProvider>().loadAllOrders(limit: 50, forceRefresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải đơn hàng: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final storeProvider = context.watch<StoreProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isStaff = currentUser?.role == UserRole.staff;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chờ xử lý'),
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Sẵn sàng'),
            Tab(text: 'Hoàn thành'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
        ),
      ),
      body: Column(
        children: [
          // Store info for staff with assigned store
          if (isStaff && currentUser?.assignedStoreId != null && _selectedStore != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.store, color: AppTheme.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cửa hàng của bạn',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedStore!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Nhân viên',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Store selector (only show for admin or if staff has no assigned store)
          if (!isStaff || currentUser?.assignedStoreId == null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.store, color: AppTheme.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: storeProvider.stores.isEmpty
                        ? const Center(
                            child: Text(
                              'Đang tải danh sách cửa hàng...',
                              style: TextStyle(fontSize: 14),
                            ),
                          )
                        : DropdownButtonFormField<Store>(
                            value: _selectedStore,
                            hint: const Text('Chọn cửa hàng để xem đơn hàng'),
                            decoration: const InputDecoration(
                              labelText: 'Cửa hàng',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: storeProvider.stores.map((store) {
                              return DropdownMenuItem(
                                value: store,
                                child: Text(
                                  store.name,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (Store? newStore) async {
                              if (newStore != null) {
                                setState(() {
                                  _selectedStore = newStore;
                                });
                                await _loadOrders();
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
          
          // Orders list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(orderProvider, [OrderStatus.pending]),
                _buildOrderList(orderProvider, [OrderStatus.confirmed, OrderStatus.preparing]),
                _buildOrderList(orderProvider, [OrderStatus.ready]),
                _buildOrderList(orderProvider, [OrderStatus.completed, OrderStatus.cancelled]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(OrderProvider provider, List<OrderStatus> statuses) {
    // Show placeholder if no store selected
    if (_selectedStore == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 80,
              color: AppTheme.primaryGreen.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Chọn cửa hàng để xem đơn hàng',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng chọn cửa hàng từ danh sách bên trên',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Filter orders by selected store and status
    final orders = provider.orders
        .where((order) => 
            statuses.contains(order.status) && 
            order.store.id == _selectedStore!.id)
        .toList();

    print('Building order list for store: ${_selectedStore?.name ?? 'All'}, statuses: ${statuses.map((s) => s.name).join(', ')}');
    print('Found ${orders.length} orders matching these filters');
    if (orders.isNotEmpty) {
      print('Orders: ${orders.map((o) => '${o.id.substring(0, 8)}: ${o.status.name}').join(', ')}');
    }

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Không có đơn hàng tại ${_selectedStore!.name}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        key: ValueKey('${statuses.join('_')}_${orders.length}'),
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildAdminOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildAdminOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(order.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${order.items.fold<int>(0, (sum, item) => sum + item.quantity)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        title: Text(
          '#${order.id.toUpperCase()}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.store, size: 14, color: AppTheme.primaryGreen),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.store.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Topping indicator badge
                if (order.items.any((item) => item.selectedToppings.isNotEmpty))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_circle,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Topping',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            if (order.userName != null)
              Text(
                order.userName!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            Text(
              '${order.orderTime.hour}:${order.orderTime.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            if (order.pickupTime != null)
              Text(
                'Nhận lúc: ${order.pickupTime!.hour}:${order.pickupTime!.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.bold,
                    ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(order.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getStatusText(order.status),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getStatusColor(order.status),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.store, color: AppTheme.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.store.name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                            ),
                            Text(
                              order.store.address,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Order items
                Text(
                  'Sản phẩm:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedImage(
                          imageUrl: item.product.imageUrl,
                          width: 50,
                          height: 50,
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
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Size: ${item.size} x${item.quantity}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                              if (item.selectedToppings.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppTheme.primaryGreen.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 14,
                                        color: AppTheme.primaryGreen,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Topping: ${item.selectedToppings.map((t) => t.name).join(', ')}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppTheme.primaryGreen,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (item.selectedOptions.isNotEmpty)
                                Text(
                                  item.selectedOptions.values.join(', '),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              if (item.notes != null)
                                Text(
                                  'Ghi chú: ${item.notes}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.accentOrange,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Order notes
                if (order.notes != null) ...[
                  Text(
                    'Ghi chú đơn hàng:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng tiền:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      order.total.toCurrency(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    if (order.status == OrderStatus.pending) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loadingOrders[order.id] == true 
                              ? null 
                              : () => _updateOrderStatus(order, OrderStatus.cancelled),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            side: const BorderSide(color: AppTheme.errorColor),
                          ),
                          child: _loadingOrders[order.id] == true
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _loadingOrders[order.id] == true 
                              ? null 
                              : () => _updateOrderStatus(order, OrderStatus.confirmed),
                          child: _loadingOrders[order.id] == true
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Xác nhận'),
                        ),
                      ),
                    ],
                    if (order.status == OrderStatus.confirmed) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loadingOrders[order.id] == true 
                              ? null 
                              : () => _updateOrderStatus(order, OrderStatus.preparing),
                          child: _loadingOrders[order.id] == true
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Bắt đầu làm'),
                        ),
                      ),
                    ],
                    if (order.status == OrderStatus.preparing) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loadingOrders[order.id] == true 
                              ? null 
                              : () => _updateOrderStatus(order, OrderStatus.ready),
                          child: _loadingOrders[order.id] == true
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Hoàn thành'),
                        ),
                      ),
                    ],
                    if (order.status == OrderStatus.ready) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loadingOrders[order.id] == true 
                              ? null 
                              : () => _updateOrderStatus(order, OrderStatus.completed),
                          child: _loadingOrders[order.id] == true
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Đã giao'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(Order order, OrderStatus newStatus) async {
    // Set loading state
    setState(() {
      _loadingOrders[order.id] = true;
    });

    try {
      await context.read<OrderProvider>().updateOrderStatus(order.id, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật trạng thái đơn hàng'),
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
    } finally {
      // Clear loading state
      if (mounted) {
        setState(() {
          _loadingOrders.remove(order.id);
        });
      }
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
        return 'Đang xử lý';
      case OrderStatus.ready:
        return 'Sẵn sàng';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

