class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? photoUrl;
  final DateTime createdAt;
  final UserRole role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.photoUrl,
    required this.createdAt,
    this.role = UserRole.customer,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Parse DateTime safely
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String && value.isEmpty) return DateTime.now();
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString(),
      createdAt: parseDateTime(json['createdAt']),
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'role': role.name,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }
}

enum UserRole {
  customer,
  staff,
  admin,
}

