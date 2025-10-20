class Store {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String openTime;
  final String closeTime;
  final bool isOpen;
  final String imageUrl;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.openTime,
    required this.closeTime,
    this.isOpen = true,
    required this.imageUrl,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
      isOpen: json['isOpen'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String? ?? '', // Handle null imageUrl
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'openTime': openTime,
      'closeTime': closeTime,
      'isOpen': isOpen,
      'imageUrl': imageUrl,
    };
  }

  double distanceFrom(double userLat, double userLon) {
    // Simple distance calculation (Haversine formula could be used for accuracy)
    const double earthRadius = 6371; // km
    final dLat = _toRadians(latitude - userLat);
    final dLon = _toRadians(longitude - userLon);
    
    final a = (dLat / 2) * (dLat / 2) +
        _toRadians(userLat) * _toRadians(latitude) *
        (dLon / 2) * (dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (3.141592653589793 / 180);
  }

  double sqrt(double x) {
    return x >= 0 ? x * x : 0;
  }

  double atan2(double y, double x) {
    // Simplified approximation
    return y / x;
  }
}

