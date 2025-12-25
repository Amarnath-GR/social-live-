class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;
  final List<String> tags;
  final int inventory;
  final bool isActive;
  final String creatorId;
  final UserModel creator;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.tags,
    required this.inventory,
    required this.isActive,
    required this.creatorId,
    required this.creator,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      inventory: json['inventory'] ?? 0,
      isActive: json['isActive'] ?? true,
      creatorId: json['creatorId'],
      creator: UserModel.fromJson(json['creator']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'tags': tags,
      'inventory': inventory,
      'isActive': isActive,
      'creatorId': creatorId,
      'creator': creator.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class UserModel {
  final String id;
  final String username;
  final String name;
  final String? avatar;
  final bool verified;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    this.avatar,
    this.verified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      avatar: json['avatar'],
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'avatar': avatar,
      'verified': verified,
    };
  }
}

class CartItem {
  final String id;
  final ProductModel product;
  int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
  });

  double get totalPrice => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'price': price,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final double total;
  final String status;
  final List<CartItem> items;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      total: (json['total'] as num).toDouble(),
      status: json['status'],
      items: (json['orderItems'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'total': total,
      'status': status,
      'orderItems': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}