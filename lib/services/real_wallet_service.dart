import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Transaction {
  final String id;
  final String type; // 'CREDIT' or 'DEBIT'
  final double amount;
  final String description;
  final DateTime createdAt;
  final String? reference;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.reference,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'amount': amount,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'reference': reference,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    type: json['type'],
    amount: json['amount'],
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
    reference: json['reference'],
  );
}

class RealWalletService extends ChangeNotifier {
  static final RealWalletService _instance = RealWalletService._internal();
  factory RealWalletService() => _instance;
  RealWalletService._internal() {
    _loadData();
  }

  double _balance = 0.0;
  final List<Transaction> _transactions = [];

  double get balance => _balance;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<Transaction> get recentTransactions => _transactions.take(10).toList();

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _balance = prefs.getDouble('wallet_balance') ?? 0.0;
      
      final transactionsJson = prefs.getString('wallet_transactions');
      if (transactionsJson != null) {
        final List<dynamic> decoded = json.decode(transactionsJson);
        _transactions.clear();
        _transactions.addAll(decoded.map((e) => Transaction.fromJson(e)).toList());
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading wallet data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('wallet_balance', _balance);
      
      final transactionsJson = json.encode(_transactions.map((e) => e.toJson()).toList());
      await prefs.setString('wallet_transactions', transactionsJson);
    } catch (e) {
      print('Error saving wallet data: $e');
    }
  }

  Future<bool> addMoney(double amount) async {
    if (amount <= 0) return false;
    
    _balance += amount;
    
    final transaction = Transaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      type: 'CREDIT',
      amount: amount,
      description: 'Added money to wallet',
      createdAt: DateTime.now(),
      reference: 'ADD_MONEY',
    );
    
    _transactions.insert(0, transaction);
    await _saveData();
    notifyListeners();
    
    return true;
  }

  Future<bool> deductMoney(double amount, String description, {String? reference}) async {
    if (amount <= 0 || amount > _balance) return false;
    
    _balance -= amount;
    
    final transaction = Transaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      type: 'DEBIT',
      amount: amount,
      description: description,
      createdAt: DateTime.now(),
      reference: reference,
    );
    
    _transactions.insert(0, transaction);
    await _saveData();
    notifyListeners();
    
    return true;
  }

  Future<bool> purchaseProduct(String productName, double price) async {
    return await deductMoney(
      price,
      'Purchased $productName',
      reference: 'PURCHASE',
    );
  }

  Future<bool> sendMoney(String recipient, double amount) async {
    return await deductMoney(
      amount,
      'Sent to $recipient',
      reference: 'SEND_MONEY',
    );
  }

  bool hasEnoughBalance(double amount) {
    return _balance >= amount;
  }

  void clearAll() async {
    _balance = 0.0;
    _transactions.clear();
    await _saveData();
    notifyListeners();
  }
}
