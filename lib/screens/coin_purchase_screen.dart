import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/purchase_service.dart';
import '../services/wallet_service.dart';

class CoinPurchaseScreen extends StatefulWidget {
  const CoinPurchaseScreen({super.key});

  @override
  State<CoinPurchaseScreen> createState() => _CoinPurchaseScreenState();
}

class _CoinPurchaseScreenState extends State<CoinPurchaseScreen> {
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _isPurchasing = false;
  double _currentBalance = 0.0;
  final WalletService _walletService = WalletService();

  @override
  void initState() {
    super.initState();
    _initializePurchases();
    _loadWalletBalance();
    _listenToPurchases();
  }

  Future<void> _initializePurchases() async {
    await PurchaseService.initialize();
    setState(() {
      _products = PurchaseService.getProducts();
      _isLoading = false;
    });
  }

  Future<void> _loadWalletBalance() async {
    try {
      final balance = await _walletService.getBalance();
      setState(() {
        _currentBalance = balance;
      });
    } catch (e) {
      setState(() {
        _currentBalance = 0.0;
      });
    }
  }

  void _listenToPurchases() {
    PurchaseService.purchaseStream.listen((result) {
      setState(() {
        _isPurchasing = false;
      });

      if (result.success) {
        _showSuccessDialog(result.coins ?? 0);
        _loadWalletBalance(); // Refresh balance
      } else {
        _showErrorDialog(result.message);
      }
    });
  }

  Future<void> _purchaseCoins(String productId) async {
    setState(() {
      _isPurchasing = true;
    });

    await PurchaseService.purchaseCoins(productId);
  }

  void _showSuccessDialog(int coins) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Successful!'),
        content: Text('You received $coins coins!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Coins'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Current balance
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber[400]!, Colors.orange[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Current Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currentBalance.toInt()} Coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Products list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No products available',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final coins = PurchaseService.getCoinsForProduct(product.id)[product.id] ?? 0;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.amber[100],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.monetization_on,
                                  color: Colors.amber[700],
                                  size: 32,
                                ),
                              ),
                              title: Text(
                                '$coins Coins',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                product.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    product.price,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ElevatedButton(
                                    onPressed: _isPurchasing 
                                        ? null 
                                        : () => _purchaseCoins(product.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: _isPurchasing
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Buy'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Restore purchases button
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: () async {
                await PurchaseService.restorePurchases();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Restore purchases initiated')),
                  );
                }
              },
              child: const Text('Restore Purchases'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    PurchaseService.dispose();
    super.dispose();
  }
}
