import '../models/product.dart';
import '../models/store.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

/// Mock data service for development without backend
class MockDataService {
  static List<Product> getMockProducts() {
    return [
      Product(
        id: 'product#p001',
        name: 'Phin Sữa Đá',
        description: 'Cà phê phin truyền thống Việt Nam pha với sữa đặc',
        price: 39000,
        imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e',
        category: ProductCategory.coffee,
        sizes: ['Small', 'Medium', 'Large'],
        options: [
          ProductOption(
            name: 'Đường',
            choices: ['Ít đường', 'Vừa', 'Nhiều đường'],
            extraPrice: 0,
          ),
          ProductOption(
            name: 'Đá',
            choices: ['Ít đá', 'Vừa', 'Nhiều đá'],
            extraPrice: 0,
          ),
        ],
        preparationTime: 8,
      ),
      Product(
        id: 'product#p002',
        name: 'Bạc Xỉu',
        description: 'Cà phê sữa nóng kiểu Việt Nam với hương vị ngọt ngào',
        price: 39000,
        imageUrl: 'https://images.unsplash.com/photo-1511920170033-f8396924c348',
        category: ProductCategory.coffee,
        sizes: ['Small', 'Medium', 'Large'],
        options: [
          ProductOption(
            name: 'Đường',
            choices: ['Ít đường', 'Vừa', 'Nhiều đường'],
            extraPrice: 0,
          ),
        ],
        preparationTime: 7,
      ),
      Product(
        id: 'product#p003',
        name: 'Caramel Macchiato',
        description: 'Espresso kết hợp với sữa tươi và caramel thơm ngon',
        price: 55000,
        imageUrl: 'https://images.unsplash.com/photo-1572442388796-11668a67e53d',
        category: ProductCategory.coffee,
        sizes: ['Medium', 'Large'],
        options: [
          ProductOption(
            name: 'Topping',
            choices: ['Không', 'Whipped Cream', 'Extra Caramel'],
            extraPrice: 10000,
          ),
        ],
        preparationTime: 10,
      ),
      Product(
        id: 'product#p004',
        name: 'Cappuccino',
        description: 'Cà phê Ý truyền thống với bọt sữa mịn màng',
        price: 49000,
        imageUrl: 'https://images.unsplash.com/photo-1534778101976-62847782c213',
        category: ProductCategory.coffee,
        sizes: ['Small', 'Medium', 'Large'],
        options: [
          ProductOption(
            name: 'Shot',
            choices: ['Single', 'Double'],
            extraPrice: 15000,
          ),
        ],
        preparationTime: 8,
      ),
      Product(
        id: 'product#p005',
        name: 'Trà Đào Cam Sả',
        description: 'Trà đen kết hợp với đào, cam và sả thơm mát',
        price: 49000,
        imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc',
        category: ProductCategory.tea,
        sizes: ['Medium', 'Large'],
        options: [
          ProductOption(
            name: 'Đường',
            choices: ['Ít đường', 'Vừa', 'Nhiều đường'],
            extraPrice: 0,
          ),
          ProductOption(
            name: 'Đá',
            choices: ['Ít đá', 'Vừa', 'Nhiều đá'],
            extraPrice: 0,
          ),
        ],
        preparationTime: 12,
      ),
      Product(
        id: 'product#p007',
        name: 'Bánh Mì Pate',
        description: 'Bánh mì Việt Nam với pate, thịt nguội và rau thơm',
        price: 32000,
        imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8',
        category: ProductCategory.food,
        sizes: ['Standard'],
        options: [
          ProductOption(
            name: 'Độ cay',
            choices: ['Không cay', 'Ít cay', 'Cay vừa', 'Cay nhiều'],
            extraPrice: 0,
          ),
        ],
        preparationTime: 5,
      ),
      Product(
        id: 'product#p008',
        name: 'Bánh Croissant',
        description: 'Bánh sừng bò bơ thơm giòn tan',
        price: 35000,
        imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a',
        category: ProductCategory.pastry,
        sizes: ['Standard'],
        options: [],
        preparationTime: 3,
      ),
      Product(
        id: 'product#p009',
        name: 'Bình Giữ Nhiệt Highlands 500ml',
        description: 'Bình giữ nhiệt inox cao cấp, giữ nhiệt lạnh đến 12 giờ',
        price: 250000,
        imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8',
        category: ProductCategory.merchandise,
        sizes: ['500ml'],
        options: [],
        preparationTime: 0,
      ),
      Product(
        id: 'product#p010',
        name: 'Ly Sứ Highlands 350ml',
        description: 'Ly sứ cao cấp với logo Highlands, thiết kế sang trọng',
        price: 120000,
        imageUrl: 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d',
        category: ProductCategory.merchandise,
        sizes: ['350ml'],
        options: [],
        preparationTime: 0,
      ),
      Product(
        id: 'product#p011',
        name: 'Phín Pha Cà Phê Inox',
        description: 'Phín pha cà phê truyền thống bằng inox, chất lượng cao',
        price: 85000,
        imageUrl: 'https://images.unsplash.com/photo-1610889556528-9a770e32642f',
        category: ProductCategory.merchandise,
        sizes: ['Standard'],
        options: [],
        preparationTime: 0,
      ),
      Product(
        id: 'product#p012',
        name: 'Túi Tote Bag Highlands',
        description: 'Túi vải canvas bền đẹp với thiết kế Highlands độc đáo',
        price: 95000,
        imageUrl: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7',
        category: ProductCategory.merchandise,
        sizes: ['One Size'],
        options: [
          ProductOption(
            name: 'Màu sắc',
            choices: ['Trắng', 'Be', 'Xanh'],
            extraPrice: 0,
          ),
        ],
        preparationTime: 0,
      ),
      Product(
        id: 'product#p013',
        name: 'Áo Thun Highlands Limited Edition',
        description: 'Áo thun cotton cao cấp với thiết kế độc quyền',
        price: 195000,
        imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
        category: ProductCategory.merchandise,
        sizes: ['S', 'M', 'L', 'XL'],
        options: [
          ProductOption(
            name: 'Màu sắc',
            choices: ['Trắng', 'Đen', 'Xanh Navy'],
            extraPrice: 0,
          ),
        ],
        preparationTime: 0,
      ),
    ];
  }

  static List<Store> getMockStores() {
    return [
      Store(
        id: 'store#s001',
        name: 'Highlands Coffee - Nguyễn Huệ',
        address: '123 Nguyễn Huệ, Q.1, TP.HCM',
        latitude: 10.7756,
        longitude: 106.7019,
        phone: '0901234567',
        openTime: '07:00',
        closeTime: '22:00',
        isOpen: true,
        imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24',
      ),
      Store(
        id: 'store#s002',
        name: 'Highlands Coffee - Lê Lợi',
        address: '456 Lê Lợi, Q.1, TP.HCM',
        latitude: 10.7727,
        longitude: 106.6988,
        phone: '0901234568',
        openTime: '07:00',
        closeTime: '23:00',
        isOpen: true,
        imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb',
      ),
      Store(
        id: 'store#s003',
        name: 'Highlands Coffee - Vincom Center',
        address: '72 Lê Thánh Tôn, Q.1, TP.HCM',
        latitude: 10.7797,
        longitude: 106.7011,
        phone: '0901234569',
        openTime: '08:00',
        closeTime: '22:00',
        isOpen: true,
        imageUrl: 'https://images.unsplash.com/photo-1559496417-e7f25c30ff3e',
      ),
      Store(
        id: 'store#s004',
        name: 'Highlands Coffee - Landmark 81',
        address: '720A Điện Biên Phủ, Bình Thạnh, TP.HCM',
        latitude: 10.7943,
        longitude: 106.7218,
        phone: '0901234570',
        openTime: '08:00',
        closeTime: '22:00',
        isOpen: true,
        imageUrl: 'https://images.unsplash.com/photo-1511920170033-f8396924c348',
      ),
      Store(
        id: 'store#s005',
        name: 'Highlands Coffee - Crescent Mall',
        address: '101 Tôn Dật Tiên, Q.7, TP.HCM',
        latitude: 10.7285,
        longitude: 106.7198,
        phone: '0901234571',
        openTime: '08:00',
        closeTime: '22:00',
        isOpen: true,
        imageUrl: 'https://images.unsplash.com/photo-1442512595331-e89e73853f31',
      ),
    ];
  }

  static User getMockAdminUser() {
    return User(
      id: 'admin001',
      email: 'admin@highlands.vn',
      name: 'Admin User',
      phone: '0900000001',
      role: UserRole.admin,
      createdAt: DateTime.now(),
    );
  }

  static User getMockCustomerUser() {
    return User(
      id: 'customer001',
      email: 'customer@test.com',
      name: 'Test Customer',
      phone: '0900000000',
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );
  }

  static List<Order> getMockOrders() {
    final store = getMockStores().first;
    final products = getMockProducts();
    
    return [
      Order(
        id: 'ord_001',
        userId: 'customer001',
        store: store,
        items: [
          CartItem(
            product: products[0], // Phin Sữa Đá
            size: 'Medium',
            selectedOptions: {'Đường': 'Vừa'},
            quantity: 2,
          ),
        ],
        subtotal: 78000,
        tax: 7800,
        total: 85800,
        status: OrderStatus.pending,
        paymentMethod: PaymentMethod.card,
        paymentStatus: PaymentStatus.pending,
        orderTime: DateTime.now().subtract(const Duration(hours: 1)),
        notes: 'Ít đá',
      ),
      Order(
        id: 'ord_002',
        userId: 'customer001',
        store: store,
        items: [
          CartItem(
            product: products[2], // Caramel Macchiato
            size: 'Large',
            selectedOptions: {'Topping': 'Whipped Cream'},
            quantity: 1,
          ),
          CartItem(
            product: products[6], // Bánh Mì Pate
            size: 'Standard',
            selectedOptions: {'Độ cay': 'Cay vừa'},
            quantity: 1,
          ),
        ],
        subtotal: 87000,
        tax: 8700,
        total: 95700,
        status: OrderStatus.confirmed,
        paymentMethod: PaymentMethod.momo,
        paymentStatus: PaymentStatus.paid,
        orderTime: DateTime.now().subtract(const Duration(minutes: 30)),
        pickupTime: DateTime.now().add(const Duration(minutes: 20)),
      ),
      Order(
        id: 'ord_003',
        userId: 'customer001',
        store: store,
        items: [
          CartItem(
            product: products[4], // Trà Đào Cam Sả
            size: 'Large',
            selectedOptions: {'Đường': 'Ít đường'},
            quantity: 1,
          ),
        ],
        subtotal: 49000,
        tax: 4900,
        total: 53900,
        status: OrderStatus.preparing,
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.paid,
        orderTime: DateTime.now().subtract(const Duration(minutes: 15)),
        pickupTime: DateTime.now().add(const Duration(minutes: 10)),
      ),
      Order(
        id: 'ord_004',
        userId: 'customer001',
        store: store,
        items: [
          CartItem(
            product: products[1], // Bạc Xỉu
            size: 'Small',
            selectedOptions: {'Đường': 'Nhiều đường'},
            quantity: 1,
          ),
          CartItem(
            product: products[7], // Bánh Croissant
            size: 'Standard',
            selectedOptions: {},
            quantity: 2,
          ),
        ],
        subtotal: 109000,
        tax: 10900,
        total: 119900,
        status: OrderStatus.ready,
        paymentMethod: PaymentMethod.zalopay,
        paymentStatus: PaymentStatus.paid,
        orderTime: DateTime.now().subtract(const Duration(minutes: 45)),
        pickupTime: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Order(
        id: 'ord_005',
        userId: 'customer001',
        store: store,
        items: [
          CartItem(
            product: products[3], // Cappuccino
            size: 'Medium',
            selectedOptions: {'Shot': 'Double'},
            quantity: 1,
          ),
        ],
        subtotal: 64000,
        tax: 6400,
        total: 70400,
        status: OrderStatus.completed,
        paymentMethod: PaymentMethod.card,
        paymentStatus: PaymentStatus.paid,
        orderTime: DateTime.now().subtract(const Duration(hours: 2)),
        pickupTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        completedTime: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}

