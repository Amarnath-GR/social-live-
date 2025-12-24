import 'package:flutter/material.dart';
import '../services/real_wallet_service.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final double rating;
  final int reviews;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.rating = 4.5,
    this.reviews = 100,
    this.description = '',
  });
}

class RealMarketplaceScreen extends StatefulWidget {
  @override
  _RealMarketplaceScreenState createState() => _RealMarketplaceScreenState();
}

class _RealMarketplaceScreenState extends State<RealMarketplaceScreen> {
  final RealWalletService _walletService = RealWalletService();
  
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Electronics', 'Fashion', 'Home', 'Sports'];
  
  final List<Product> _allProducts = [
    Product(id: '1', name: 'Wireless Headphones', price: 49.99, category: 'Electronics', rating: 4.5, reviews: 234),
    Product(id: '2', name: 'Smart Watch', price: 199.99, category: 'Electronics', rating: 4.7, reviews: 456),
    Product(id: '3', name: 'Designer Sunglasses', price: 89.99, category: 'Fashion', rating: 4.3, reviews: 123),
    Product(id: '4', name: 'Running Shoes', price: 79.99, category: 'Sports', rating: 4.6, reviews: 345),
    Product(id: '5', name: 'Yoga Mat', price: 29.99, category: 'Sports', rating: 4.4, reviews: 189),
    Product(id: '6', name: 'Coffee Maker', price: 129.99, category: 'Home', rating: 4.8, reviews: 567),
    Product(id: '7', name: 'Leather Wallet', price: 39.99, category: 'Fashion', rating: 4.2, reviews: 98),
    Product(id: '8', name: 'Bluetooth Speaker', price: 59.99, category: 'Electronics', rating: 4.5, reviews: 276),
  ];

  @override
  void initState() {
    super.initState();
    _walletService.addListener(_onWalletUpdate);
  }

  @override
  void dispose() {
    _walletService.removeListener(_onWalletUpdate);
    super.dispose();
  }

  void _onWalletUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'All') {
      return _allProducts;
    }
    return _allProducts.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Shop', style: TextStyle(color: Colors.white)),
        actions: [
          // Wallet balance display
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.blue],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_wallet, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  '\${_walletService.balance.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple : Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 16),
          
          // Products Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        _showProductDetails(product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(product.category),
                    color: Colors.purple,
                    size: 40,
                  ),
                ),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '${product.rating}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '(${product.reviews})',
                          style: TextStyle(color: Colors.grey[500], fontSize: 10),
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(
                      '\${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Electronics':
        return Icons.devices;
      case 'Fashion':
        return Icons.checkroom;
      case 'Home':
        return Icons.home;
      case 'Sports':
        return Icons.sports_basketball;
      default:
        return Icons.shopping_bag;
    }
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Product Image
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(product.category),
                    color: Colors.purple,
                    size: 80,
                  ),
                ),
              ),
              
              // Product Details
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      20 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 20),
                            SizedBox(width: 4),
                            Text(
                              '${product.rating}',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '(${product.reviews} reviews)',
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          '\${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Description',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This is an amazing ${product.name.toLowerCase()} with great quality and design. Perfect for everyday use and special occasions. High-quality materials and excellent craftsmanship.',
                          style: TextStyle(color: Colors.grey[300], fontSize: 14),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: Colors.purple, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Your balance: \${_walletService.balance.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmPurchase(product);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text(
                            'Buy Now - \${product.price.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmPurchase(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Confirm Purchase', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product: ${product.name}',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Price: \${product.price.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.purple, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Current Balance:', style: TextStyle(color: Colors.grey[400])),
                      Text('\${_walletService.balance.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('After Purchase:', style: TextStyle(color: Colors.grey[400])),
                      Text(
                        '\${(_walletService.balance - product.price).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: _walletService.hasEnoughBalance(product.price) ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!_walletService.hasEnoughBalance(product.price))
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Insufficient balance! Please add money to your wallet.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _walletService.hasEnoughBalance(product.price)
                ? () async {
                    Navigator.pop(context);
                    
                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: CircularProgressIndicator(color: Colors.purple),
                      ),
                    );
                    
                    // Simulate payment processing
                    await Future.delayed(Duration(milliseconds: 300));
                    
                    final success = await _walletService.purchaseProduct(product.name, product.price);
                    
                    Navigator.pop(context); // Close loading
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Successfully purchased ${product.name}!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Purchase failed'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _walletService.hasEnoughBalance(product.price) ? Colors.purple : Colors.grey,
            ),
            child: Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
