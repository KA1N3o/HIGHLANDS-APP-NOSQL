import '../models/product.dart';
import '../models/store.dart';

/// Mock data service for development without backend
class MockDataService {
  static List<Product> getMockProducts() {
    return [
      Product(
        id: 'p1',
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
        id: 'p2',
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
        id: 'p3',
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
        id: 'p4',
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
        id: 'p5',
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
        id: 'p6',
        name: 'Smoothie Xoài',
        description: 'Sinh tố xoài tươi mát lạnh, ngọt tự nhiên',
        price: 59000,
        imageUrl: 'https://images.unsplash.com/photo-1505252585461-04db1eb84625',
        category: ProductCategory.smoothie,
        sizes: ['Medium', 'Large'],
        options: [
          ProductOption(
            name: 'Topping',
            choices: ['Không', 'Thạch dừa', 'Trân châu'],
            extraPrice: 10000,
          ),
        ],
        preparationTime: 10,
      ),
      Product(
        id: 'p7',
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
        id: 'p8',
        name: 'Bánh Croissant',
        description: 'Bánh sừng bò bơ thơm giòn tan',
        price: 35000,
        imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a',
        category: ProductCategory.pastry,
        sizes: ['Standard'],
        options: [],
        preparationTime: 3,
      ),
    ];
  }

  static List<Store> getMockStores() {
    return [
      Store(
        id: 's1',
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
        id: 's2',
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
        id: 's3',
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
        id: 's4',
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
        id: 's5',
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
}

