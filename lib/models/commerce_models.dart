enum ProductStatus { active, inactive, outOfStock }
enum OrderStatus { pending, confirmed, processing, shipped, delivered, cancelled, refunded }
enum PaymentStatus { pending, completed, failed, refunded }
enum RefundStatus { requested, approved, rejected, processed }

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String sellerId;
  final ProductStatus status;
  final List<String> images;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.sellerId,
    required this.status,
    required this.images,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    price: json['price'].toDouble(),
    stock: json['stock'],
    sellerId: json['sellerId'],
    status: ProductStatus.values.firstWhere((e) => e.name == json['status']),
    images: List<String>.from(json['images'] ?? []),
    metadata: json['metadata'] ?? {},
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'stock': stock,
    'sellerId': sellerId,
    'status': status.name,
    'images': images,
    'metadata': metadata,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['productId'],
    productName: json['productName'],
    quantity: json['quantity'],
    price: json['price'].toDouble(),
    total: json['total'].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'price': price,
    'total': total,
  };
}

class Order {
  final String id;
  final String customerId;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final Map<String, dynamic> shippingAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.customerId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.shippingAddress,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    customerId: json['customerId'],
    items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
    subtotal: json['subtotal'].toDouble(),
    tax: json['tax'].toDouble(),
    total: json['total'].toDouble(),
    status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
    paymentStatus: PaymentStatus.values.firstWhere((e) => e.name == json['paymentStatus']),
    shippingAddress: json['shippingAddress'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );
}

class Refund {
  final String id;
  final String orderId;
  final double amount;
  final String reason;
  final RefundStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;

  Refund({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.requestedAt,
    this.processedAt,
  });

  factory Refund.fromJson(Map<String, dynamic> json) => Refund(
    id: json['id'],
    orderId: json['orderId'],
    amount: json['amount'].toDouble(),
    reason: json['reason'],
    status: RefundStatus.values.firstWhere((e) => e.name == json['status']),
    requestedAt: DateTime.parse(json['requestedAt']),
    processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : null,
  );
}

class TaxCalculation {
  final double rate;
  final double amount;
  final String jurisdiction;

  TaxCalculation({
    required this.rate,
    required this.amount,
    required this.jurisdiction,
  });

  factory TaxCalculation.fromJson(Map<String, dynamic> json) => TaxCalculation(
    rate: json['rate'].toDouble(),
    amount: json['amount'].toDouble(),
    jurisdiction: json['jurisdiction'],
  );
}

class SellerDashboardData {
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final int pendingOrders;
  final List<Order> recentOrders;
  final Map<String, int> salesByMonth;

  SellerDashboardData({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingOrders,
    required this.recentOrders,
    required this.salesByMonth,
  });

  factory SellerDashboardData.fromJson(Map<String, dynamic> json) => SellerDashboardData(
    totalProducts: json['totalProducts'],
    totalOrders: json['totalOrders'],
    totalRevenue: json['totalRevenue'].toDouble(),
    pendingOrders: json['pendingOrders'],
    recentOrders: (json['recentOrders'] as List).map((e) => Order.fromJson(e)).toList(),
    salesByMonth: Map<String, int>.from(json['salesByMonth']),
  );
}
