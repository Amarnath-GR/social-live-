import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallet_model.dart';

class WalletService {
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

  Future<WalletModel?> getWallet() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallet'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return WalletModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error getting wallet: $e');
    }
    return null;
  }

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallet/transactions'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting transactions: $e');
    }
    return [];
  }

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> orders = data['orders'] ?? data;
        return orders.map((json) => OrderModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting orders: $e');
    }
    return [];
  }

  Future<void> buyCoinPackage(int coins) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/wallet/buy-coins'),
      headers: _headers,
      body: jsonEncode({'coins': coins}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to buy coins: ${response.body}');
    }
  }

  Future<void> sendGift(String recipientId, String giftType, int amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/wallet/send-gift'),
      headers: _headers,
      body: jsonEncode({
        'recipientId': recipientId,
        'giftType': giftType,
        'amount': amount,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send gift: ${response.body}');
    }
  }

  Future<void> topUpWallet(int amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/wallet/top-up'),
      headers: _headers,
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to top up wallet: ${response.body}');
    }
  }

  // Add money to wallet (amount in dollars, converted to cents for backend)
  Future<WalletModel> addMoney(double amount) async {
    final amountInCents = (amount * 100).round();
    final response = await http.post(
      Uri.parse('$baseUrl/api/wallet/credit'),
      headers: _headers,
      body: jsonEncode({
        'amount': amountInCents,
        'description': 'Added money to wallet',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WalletModel.fromJson(data['data']);
    } else {
      throw Exception('Failed to add money: ${response.body}');
    }
  }

  // Purchase product with wallet balance
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
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to purchase product: ${response.body}');
    }
  }
}