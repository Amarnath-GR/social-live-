import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import 'cart_service.dart';

class MarketplaceService {
  static const String baseUrl = 'http://localhost:3000';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Products
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
  }) async {
    var url = '$baseUrl/api/products?page=$page&limit=$limit';
    if (category != null) url += '&category=$category';
    if (search != null) url += '&search=$search';

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> products = data['products'] ?? data;
      return products.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  Future<List<String>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/categories'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> categories = jsonDecode(response.body);
      return categories.cast<String>();
    } else {
      throw Exception('Failed to load categories: ${response.body}');
    }
  }

  Future<ProductModel> getProduct(String productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/$productId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product: ${response.body}');
    }
  }

  // Cart Management
  Future<List<CartItem>> getCart() async {
    // Always use local cart, ignore backend
    final cartItems = CartService.cartItems;
    return cartItems.map((item) => CartItem(
      id: item['product']['id'],
      product: ProductModel.fromJson(item['product']),
      quantity: item['quantity'],
      price: (item['product']['price'] as num).toDouble(),
    )).toList();
  }

  Future<void> addToCart(String productId, int quantity) async {
    // Use local cart service for now
    return;
  }

  Future<void> updateCartItem(String itemId, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/cart/$itemId'),
      headers: _headers,
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart: ${response.body}');
    }
  }

  Future<void> removeFromCart(String itemId) async {
    CartService.removeFromCart(itemId);
  }

  // Orders
  Future<OrderModel> createOrder() async {
    final cartItems = CartService.cartItems;
    final total = CartService.totalPrice;
    
    // Convert to CartItem objects
    final items = cartItems.map((item) => CartItem(
      id: item['product']['id'],
      product: ProductModel.fromJson(item['product']),
      quantity: item['quantity'],
      price: (item['product']['price'] as num).toDouble(),
    )).toList();
    
    // Clear cart after order
    CartService.clearCart();
    
    // Return mock order
    return OrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_1',
      items: items,
      total: total,
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  Future<List<OrderModel>> getOrders({int page = 1, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> orders = data['orders'] ?? data;
      return orders.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.body}');
    }
  }

  Future<OrderModel> getOrder(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/$orderId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return OrderModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load order: ${response.body}');
    }
  }

  // Search and Discovery
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/search?q=${Uri.encodeComponent(query)}'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> products = jsonDecode(response.body);
      return products.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search products: ${response.body}');
    }
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/featured'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> products = jsonDecode(response.body);
      return products.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load featured products: ${response.body}');
    }
  }

  Future<List<ProductModel>> getTrendingProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/trending'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> products = jsonDecode(response.body);
      return products.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trending products: ${response.body}');
    }
  }
  
  Future<List<ProductModel>> getCreatorProducts(String creatorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/creator/$creatorId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> products = jsonDecode(response.body);
      return products.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load creator products: ${response.body}');
    }
  }

  // Purchase product with wallet balance (secure payment)
  Future<Map<String, dynamic>> purchaseProduct(String productId, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/marketplace/purchase'),
      headers: _headers,
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to purchase product');
    }
  }

  // Direct buy now (bypasses cart)
  Future<Map<String, dynamic>> buyNow(String productId, int quantity) async {
    return purchaseProduct(productId, quantity);
  }
}