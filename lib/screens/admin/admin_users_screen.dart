import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../models/user.dart';
import '../../models/store.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<User> _users = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    // Load stores after the first frame is built to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStores();
    });
  }

  Future<void> _loadStores() async {
    try {
      await context.read<StoreProvider>().loadStores();
    } catch (e) {
      // Silently fail - stores will be loaded when needed
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<AuthProvider>().authToken != null
          ? ApiService()
          : ApiService();
      
      // Set auth token
      final authProvider = context.read<AuthProvider>();
      if (authProvider.authToken != null) {
        apiService.setAuthToken(authProvider.authToken!);
      }

      final users = await apiService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách người dùng: $e')),
        );
      }
    }
  }

  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.phone.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm người dùng...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('Không tìm thấy người dùng'))
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    // Use read instead of watch to avoid setState during build
    final storeProvider = context.read<StoreProvider>();
    Store? assignedStore;
    
    if (user.role == UserRole.staff && user.assignedStoreId != null) {
      try {
        assignedStore = storeProvider.stores.firstWhere(
          (s) => s.id == user.assignedStoreId,
        );
      } catch (e) {
        // Store not found
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRoleName(user.role),
                style: TextStyle(
                  color: _getRoleColor(user.role),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 2),
            Text(
              user.phone,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            // Show assigned store for staff
            if (user.role == UserRole.staff) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.store,
                    size: 14,
                    color: assignedStore != null 
                        ? AppTheme.primaryGreen 
                        : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      assignedStore != null 
                          ? 'Cửa hàng: ${assignedStore.name}'
                          : 'Chưa gán cửa hàng',
                      style: TextStyle(
                        color: assignedStore != null 
                            ? AppTheme.primaryGreen 
                            : Colors.grey,
                        fontSize: 12,
                        fontStyle: assignedStore == null 
                            ? FontStyle.italic 
                            : FontStyle.normal,
                      ),
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
              case 'edit':
                _showEditUserDialog(user);
                break;
              case 'change_role':
                _showChangeRoleDialog(user);
                break;
              case 'delete':
                _showDeleteUserDialog(user);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 12),
                  Text('Chỉnh sửa thông tin'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'change_role',
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, size: 20),
                  SizedBox(width: 12),
                  Text('Thay đổi quyền'),
                ],
              ),
            ),
            if (user.role != UserRole.admin)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                    SizedBox(width: 12),
                    Text(
                      'Xóa tài khoản',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppTheme.accentOrange;
      case UserRole.staff:
        return Colors.blue;
      case UserRole.customer:
        return AppTheme.primaryGreen;
    }
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.staff:
        return 'Nhân viên';
      case UserRole.customer:
        return 'Khách hàng';
    }
  }

  void _showEditUserDialog(User user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Chỉnh sửa thông tin người dùng'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Tên',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text('Đang cập nhật...'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setDialogState(() => isLoading = true);
                        
                        try {
                          final apiService = ApiService();
                          final authProvider = context.read<AuthProvider>();
                          if (authProvider.authToken != null) {
                            apiService.setAuthToken(authProvider.authToken!);
                          }

                          await apiService.updateUserInfo(user.id, {
                            'name': nameController.text,
                            'phone': phoneController.text,
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cập nhật thông tin thành công'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                            _loadUsers();
                          }
                        } catch (e) {
                          setDialogState(() => isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: $e'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangeRoleDialog(User user) {
    UserRole selectedRole = user.role;
    String? selectedStoreId = user.assignedStoreId;
    bool isLoading = false;
    final storeProvider = context.read<StoreProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Thay đổi quyền: ${user.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn quyền:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...UserRole.values.map((role) {
                    return RadioListTile<UserRole>(
                      title: Text(_getRoleName(role)),
                      value: role,
                      groupValue: selectedRole,
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedRole = value;
                                  // Clear store assignment when changing from staff
                                  if (value != UserRole.staff) {
                                    selectedStoreId = null;
                                  }
                                });
                              }
                            },
                      activeColor: _getRoleColor(role),
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                  // Show store selection only for staff role
                  if (selectedRole == UserRole.staff) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Gán cửa hàng:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bắt buộc phải chọn cửa hàng cho nhân viên',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (storeProvider.stores.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Không có cửa hàng nào',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedStoreId == null 
                                ? Colors.red.shade300 
                                : Colors.grey.shade300,
                            width: selectedStoreId == null ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: selectedStoreId == null 
                              ? Colors.red.shade50 
                              : null,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedStoreId,
                            hint: const Text(
                              'Chọn cửa hàng *',
                              style: TextStyle(color: Colors.red),
                            ),
                            items: storeProvider.stores.map((store) {
                              return DropdownMenuItem<String>(
                                value: store.id,
                                child: Text(
                                  store.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setDialogState(() {
                                      selectedStoreId = value;
                                    });
                                  },
                          ),
                        ),
                      ),
                    if (selectedStoreId != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryGreen,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Nhân viên sẽ quản lý: ${storeProvider.stores.firstWhere((s) => s.id == selectedStoreId).name}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  if (isLoading) ...[
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text('Đang cập nhật quyền...'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        // Validate: Staff must have an assigned store
                        if (selectedRole == UserRole.staff && selectedStoreId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vui lòng chọn cửa hàng cho nhân viên'),
                              backgroundColor: AppTheme.errorColor,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        setDialogState(() => isLoading = true);

                        try {
                          final apiService = ApiService();
                          final authProvider = context.read<AuthProvider>();
                          if (authProvider.authToken != null) {
                            apiService.setAuthToken(authProvider.authToken!);
                          }

                          await apiService.updateUserRole(
                            user.id, 
                            selectedRole,
                            assignedStoreId: selectedStoreId,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            
                            String message = 'Đã cập nhật quyền ${_getRoleName(selectedRole)} cho ${user.name}';
                            if (selectedRole == UserRole.staff && selectedStoreId != null) {
                              final storeName = storeProvider.stores
                                  .firstWhere((s) => s.id == selectedStoreId)
                                  .name;
                              message += ' và gán cửa hàng $storeName';
                            }
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                            _loadUsers();
                          }
                        } catch (e) {
                          setDialogState(() => isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: $e'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteUserDialog(User user) {
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: AppTheme.errorColor),
                SizedBox(width: 8),
                Text('Xác nhận xóa tài khoản'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bạn có chắc chắn muốn xóa tài khoản này?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                user.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(user.email)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(user.phone)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hành động này không thể hoàn tác!',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text('Đang xóa tài khoản...'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setDialogState(() => isLoading = true);

                        try {
                          final apiService = ApiService();
                          final authProvider = context.read<AuthProvider>();
                          if (authProvider.authToken != null) {
                            apiService.setAuthToken(authProvider.authToken!);
                          }

                          await apiService.deleteUser(user.id);

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã xóa tài khoản ${user.name}'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                            _loadUsers();
                          }
                        } catch (e) {
                          setDialogState(() => isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Xóa'),
              ),
            ],
          );
        },
      ),
    );
  }
}

