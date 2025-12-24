class WalletModel {
  final String id;
  final String userId;
  final int balance;
  final int earned;
  final int spent;
  final int giftsSent;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    this.earned = 0,
    this.spent = 0,
    this.giftsSent = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'],
      userId: json['userId'],
      balance: json['balance'],
      earned: json['earned'] ?? 0,
      spent: json['spent'] ?? 0,
      giftsSent: json['giftsSent'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'balance': balance,
      'earned': earned,
      'spent': spent,
      'giftsSent': giftsSent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TransactionModel {
  final String id;
  final String walletId;
  final int amount;
  final String type; // CREDIT, DEBIT
  final String description;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      walletId: json['walletId'],
      amount: json['amount'],
      type: json['type'],
      description: json['description'] ?? 'Transaction',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'amount': amount,
      'type': type,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final int total;
  final String status;
  final List<OrderItemModel> items;
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
      total: json['total'],
      status: json['status'],
      items: (json['orderItems'] as List<dynamic>?)
          ?.map((item) => OrderItemModel.fromJson(item))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'total': total,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class OrderItemModel {
  final String id;
  final String productId;
  final int quantity;
  final int price;
  final ProductModel? product;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      productId: json['productId'],
      quantity: json['quantity'],
      price: json['price'],
      product: json['product'] != null 
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'product': product?.toJson(),
    };
  }
}

// Import the ProductModel from the existing product_model.dart
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
  final CreatorModel creator;
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
      inventory: json['inventory'],
      isActive: json['isActive'] ?? true,
      creatorId: json['creatorId'],
      creator: CreatorModel.fromJson(json['creator']),
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

class CreatorModel {
  final String id;
  final String username;
  final String name;
  final String? avatar;
  final bool verified;

  CreatorModel({
    required this.id,
    required this.username,
    required this.name,
    this.avatar,
    required this.verified,
  });

  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    return CreatorModel(
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