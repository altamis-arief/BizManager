class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double cost; // Add cost field
  final int stock;
  final String category;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String userId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.cost, // Add required cost
    required this.stock,
    required this.category,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    required this.userId,
  });

  // Calculate profit margin percentage
  double get profitMargin {
    if (price == 0) return 0;
    return ((price - cost) / price) * 100;
  }

  // Calculate profit amount per unit
  double get profitPerUnit {
    return price - cost;
  }

  // Convert Product to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'cost': cost, // Add cost to map
      'stock': stock,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'userId': userId,
    };
  }

  // Create Product from Firestore Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      cost: (map['cost'] ?? 0).toDouble(), // Add cost from map
      stock: map['stock'] ?? 0,
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isActive: map['isActive'] ?? true,
      userId: map['userId'] ?? '',
    );
  }

  // Create a copy with modified fields
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? cost,
    int? stock,
    String? category,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? userId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      userId: userId ?? this.userId,
    );
  }
}