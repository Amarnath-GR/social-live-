import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallet_model.dart';

class WalletService {
  static const String baseUrl = 'http://localhost:3000';
  String? _token;
  
  // Local state management
  static double _cashBalance = 1250.75;
  static int _tokenBalance = 2500;
  static List<WalletTransaction> _transactions = [];
  
  // Getters for local state
  static double get cashBalance => _cashBalance;
  static int get tokenBalance => _tokenBalance;
  static List<WalletTransaction> get transactions => List.unmodifiable(_transactions);
  
  // Callbacks for UI updates
  static Function()? onBalanceChanged;
  static Function()? onTransactionAdded;

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
  
  // Local methods for immediate UI updates
  static void addCash(double amount, String description) {
    _cashBalance += amount;
    _addTransaction(WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      amount: amount,
      date: DateTime.now(),
      isIncoming: true,
      isToken: false,
    ));
    _notifyBalanceChanged();
  }
  
  static bool spendCash(double amount, String description) {
    if (_cashBalance >= amount) {
      _cashBalance -= amount;
      _addTransaction(WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: description,
        amount: -amount,
        date: DateTime.now(),
        isIncoming: false,
        isToken: false,
      ));
      _notifyBalanceChanged();
      return true;
    }
    return false;
  }
  
  static void addTokens(int amount, String description) {
    _tokenBalance += amount;
    _addTransaction(WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      amount: amount.toDouble(),
      date: DateTime.now(),
      isIncoming: true,
      isToken: true,
    ));
    _notifyBalanceChanged();
  }
  
  static bool spendTokens(int amount, String description) {
    if (_tokenBalance >= amount) {
      _tokenBalance -= amount;
      _addTransaction(WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: description,
        amount: -amount.toDouble(),
        date: DateTime.now(),
        isIncoming: false,
        isToken: true,
      ));
      _notifyBalanceChanged();
      return true;
    }
    return false;
  }
  
  static bool purchaseTokensWithCash(int tokens, double price) {
    if (_cashBalance >= price) {
      _cashBalance -= price;
      _tokenBalance += tokens;
      
      // Add cash deduction transaction
      _addTransaction(WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: 'Purchased $tokens tokens',
        amount: -price,
        date: DateTime.now(),
        isIncoming: false,
        isToken: false,
      ));
      
      // Add token addition transaction
      _addTransaction(WalletTransaction(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        description: 'Received $tokens tokens',
        amount: tokens.toDouble(),
        date: DateTime.now(),
        isIncoming: true,
        isToken: true,
      ));
      
      _notifyBalanceChanged();
      return true;
    }
    return false;
  }
  
  static void _addTransaction(WalletTransaction transaction) {
    _transactions.insert(0, transaction);
    // Keep only last 50 transactions
    if (_transactions.length > 50) {
      _transactions = _transactions.take(50).toList();
    }
    onTransactionAdded?.call();
  }
  
  static void _notifyBalanceChanged() {
    onBalanceChanged?.call();
  }
  
  // Initialize with sample transactions
  static void initializeSampleData() {
    if (_transactions.isEmpty) {
      _transactions = [
        WalletTransaction(
          id: '1',
          description: 'Received from @user123',
          amount: 50.0,
          date: DateTime.now().subtract(Duration(hours: 2)),
          isIncoming: true,
          isToken: false,
        ),
        WalletTransaction(
          id: '2',
          description: 'Earned tokens from video',
          amount: 150,
          date: DateTime.now().subtract(Duration(hours: 3)),
          isIncoming: true,
          isToken: true,
        ),
        WalletTransaction(
          id: '3',
          description: 'Sent to @creator456',
          amount: -25.0,
          date: DateTime.now().subtract(Duration(hours: 5)),
          isIncoming: false,
          isToken: false,
        ),
      ];
    }
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
  
  Future<double> getBalance() async {
    try {
      final wallet = await getWallet();
      return (wallet?.balance ?? 0.0).toDouble();
    } catch (e) {
      print('Error getting balance: $e');
      return 0.0;
    }
  }
  
  Future<List<Map<String, dynamic>>> getJournalEntries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallet/journal'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error getting journal entries: $e');
    }
    return [];
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

  // Get virtual tokens balance
  Future<int> getTokenBalance() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallet/tokens'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['tokens'] ?? 0;
      }
    } catch (e) {
      print('Error getting token balance: $e');
    }
    return 0;
  }

  // Purchase tokens with cash balance
  Future<Map<String, dynamic>> purchaseTokens(int tokens, double price) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/wallet/buy-tokens'),
      headers: _headers,
      body: jsonEncode({
        'tokens': tokens,
        'price': price,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to purchase tokens: ${response.body}');
    }
  }

  // Purchase product with tokens
  Future<Map<String, dynamic>> purchaseWithTokens(String productId, int tokenCost) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/marketplace/purchase-with-tokens'),
      headers: _headers,
      body: jsonEncode({
        'productId': productId,
        'tokenCost': tokenCost,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to purchase with tokens: ${response.body}');
    }
  }
}

// Transaction model for local state
class WalletTransaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final bool isIncoming;
  final bool isToken;

  WalletTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.isIncoming,
    required this.isToken,
  });
}