import 'package:flutter/material.dart';
import 'transaction_history_screen.dart';
import 'payment_methods_screen.dart';
import '../services/wallet_service.dart';

class SimpleWalletScreen extends StatefulWidget {
  const SimpleWalletScreen({super.key});

  @override
  _SimpleWalletScreenState createState() => _SimpleWalletScreenState();
}

class _SimpleWalletScreenState extends State<SimpleWalletScreen> {
  final WalletService _walletService = WalletService();
  bool _isAddingMoney = false;
  bool _isPurchasing = false;

  double get cashBalance => WalletService.cashBalance;
  int get virtualTokens => WalletService.tokenBalance;
  List<WalletTransaction> get transactions => WalletService.transactions;
  double get totalBalance => cashBalance + (virtualTokens * 0.02); // 1 token = $0.02

  @override
  void initState() {
    super.initState();
    WalletService.initializeSampleData();
    WalletService.onBalanceChanged = () {
      if (mounted) setState(() {});
    };
    WalletService.onTransactionAdded = () {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    WalletService.onBalanceChanged = null;
    WalletService.onTransactionAdded = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Wallet', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              _showWalletMenu(context);
            },
            icon: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Balance Cards
            Container(
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Total Balance Card
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\$${totalBalance.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '+12.5% this month',
                              style: TextStyle(color: Colors.green, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Cash and Tokens Row
                  Row(
                    children: [
                      // Cash Balance
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.attach_money, color: Colors.green, size: 20),
                                  SizedBox(width: 4),
                                  Text('Cash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '\$${cashBalance.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      // Virtual Tokens
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('🪙', style: TextStyle(fontSize: 20)),
                                  SizedBox(width: 4),
                                  Text('Tokens', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '$virtualTokens',
                                style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.add,
                          label: 'Add Money',
                          color: Colors.green,
                          onTap: () => _showAddMoneyDialog(),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.send,
                          label: 'Send',
                          color: Colors.blue,
                          onTap: () => _showSendMoneyDialog(),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.qr_code,
                          label: 'QR Pay',
                          color: Colors.orange,
                          onTap: () => _showQRCode(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.monetization_on,
                          label: 'Buy Tokens',
                          color: Colors.purple,
                          onTap: () => _showBuyTokensDialog(),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(child: SizedBox()),
                      SizedBox(width: 12),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Recent Transactions
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionHistoryScreen(),
                        ),
                      );
                    },
                    child: Text('View All', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
            
            // Transaction List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Container(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: transaction.isIncoming ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                transaction.isToken 
                                  ? (transaction.isIncoming ? Icons.add : Icons.remove)
                                  : (transaction.isIncoming ? Icons.arrow_downward : Icons.arrow_upward),
                                color: transaction.isIncoming ? Colors.green : Colors.red,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.description,
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _formatDate(transaction.date),
                                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  transaction.isToken 
                                    ? '${transaction.amount > 0 ? '+' : ''}${transaction.amount.toInt()} 🪙'
                                    : '${transaction.amount > 0 ? '+' : ''}\$${transaction.amount.abs().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: transaction.isIncoming ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (transaction.isToken)
                                  Text(
                                    '≈ \$${(transaction.amount.abs() * 0.02).toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
              },
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  void _showAddMoneyDialog() {
    final TextEditingController amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Add Money', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter amount',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixText: '\$',
                prefixStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            Text(
              'Minimum: \$1.00',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _isAddingMoney ? null : () async {
              final amountText = amountController.text.trim();
              final amount = double.tryParse(amountText);
              
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (amount < 1.0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Minimum amount is \$1.00'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              setState(() => _isAddingMoney = true);
              
              // Simulate processing time
              await Future.delayed(Duration(milliseconds: 800));
              
              Navigator.pop(context);
              
              setState(() {
                WalletService.addCash(amount, 'Added money via card');
                _isAddingMoney = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('\$${amount.toStringAsFixed(2)} added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: _isAddingMoney 
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSendMoneyDialog() {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Send Money', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Username or @handle',
                hintStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Amount',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixText: '\$',
                prefixStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            Text(
              'Available balance: \$${cashBalance.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final username = usernameController.text.trim();
              final amountText = amountController.text.trim();
              final amount = double.tryParse(amountText);
              
              if (username.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a username'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (amount > cashBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Insufficient balance'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              final success = WalletService.spendCash(amount, 'Sent to ${username.startsWith('@') ? username : '@$username'}');
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('\$${amount.toStringAsFixed(2)} sent to ${username.startsWith('@') ? username : '@$username'} successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transaction failed'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('QR Code', style: TextStyle(color: Colors.white)),
        content: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code, size: 100, color: Colors.black),
                Text('Scan to Pay', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showWalletMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.history, color: Colors.white),
              title: Text('Transaction History', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionHistoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.white),
              title: Text('Payment Methods', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentMethodsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.security, color: Colors.white),
              title: Text('Security Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showSecuritySettings();
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.white),
              title: Text('Wallet Help', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showWalletHelp();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSecuritySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Security Settings', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.fingerprint, color: Colors.purple),
              title: Text('Biometric Authentication', style: TextStyle(color: Colors.white)),
              subtitle: Text('Use fingerprint or face ID', style: TextStyle(color: Colors.grey[400])),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: Colors.purple,
              ),
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.orange),
              title: Text('PIN Protection', style: TextStyle(color: Colors.white)),
              subtitle: Text('Require PIN for transactions', style: TextStyle(color: Colors.grey[400])),
              trailing: Switch(
                value: false,
                onChanged: (value) {},
                activeColor: Colors.purple,
              ),
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.blue),
              title: Text('Transaction Alerts', style: TextStyle(color: Colors.white)),
              subtitle: Text('Get notified of all transactions', style: TextStyle(color: Colors.grey[400])),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: Colors.purple,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void _showBuyTokensDialog() {
    final List<Map<String, dynamic>> tokenPackages = [
      {'tokens': 100, 'price': 2.0, 'bonus': 0},
      {'tokens': 500, 'price': 10.0, 'bonus': 50},
      {'tokens': 1000, 'price': 20.0, 'bonus': 150},
      {'tokens': 2500, 'price': 50.0, 'bonus': 500},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Buy Tokens', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Balance: \$${cashBalance.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              SizedBox(height: 16),
              ...tokenPackages.map((package) {
                final totalTokens = package['tokens'] + package['bonus'];
                final canAfford = cashBalance >= package['price'];
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    tileColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    leading: Text('🪙', style: TextStyle(fontSize: 24)),
                    title: Text(
                      '${package['tokens']} Tokens${package['bonus'] > 0 ? ' + ${package['bonus']} Bonus' : ''}',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Total: $totalTokens tokens',
                      style: TextStyle(color: Colors.orange),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${package['price'].toStringAsFixed(2)}',
                          style: TextStyle(
                            color: canAfford ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!canAfford)
                          Text(
                            'Insufficient funds',
                            style: TextStyle(color: Colors.red, fontSize: 10),
                          ),
                      ],
                    ),
                    onTap: canAfford ? () => _purchaseTokens(package) : null,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _purchaseTokens(Map<String, dynamic> package) async {
    Navigator.pop(context);
    
    setState(() => _isPurchasing = true);
    
    try {
      // Simulate processing time
      await Future.delayed(Duration(milliseconds: 1000));
      
      final totalTokens = (package['tokens'] + package['bonus']) as int;
      final price = package['price'] as double;
      
      // Use the WalletService to handle the transaction
      final success = WalletService.purchaseTokensWithCash(totalTokens, price);
      
      setState(() {
        _isPurchasing = false;
      });
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully purchased ${totalTokens} tokens!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient funds to purchase tokens'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isPurchasing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to purchase tokens: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showWalletHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Wallet Help', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use your wallet:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Add money using credit cards, PayPal, or bank transfers', style: TextStyle(color: Colors.grey[300])),
              Text('• Buy tokens with your cash balance', style: TextStyle(color: Colors.grey[300])),
              Text('• Send money to other users instantly', style: TextStyle(color: Colors.grey[300])),
              Text('• Earn tokens by creating popular content', style: TextStyle(color: Colors.grey[300])),
              Text('• Use tokens to buy virtual gifts and products in live streams', style: TextStyle(color: Colors.grey[300])),
              Text('• Withdraw your earnings to your bank account', style: TextStyle(color: Colors.grey[300])),
              SizedBox(height: 16),
              Text(
                'Token Exchange Rate:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1 Token = \$0.02 USD', style: TextStyle(color: Colors.orange)),
              SizedBox(height: 16),
              Text(
                'Need more help?',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Contact support at wallet@sociallive.com', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }
}

