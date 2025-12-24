import 'package:flutter/material.dart';

class SimpleWalletScreen extends StatefulWidget {
  @override
  _SimpleWalletScreenState createState() => _SimpleWalletScreenState();
}

class _SimpleWalletScreenState extends State<SimpleWalletScreen> {
  double balance = 1250.75;
  List<Transaction> transactions = [
    Transaction('Received from @user123', 50.0, DateTime.now().subtract(Duration(hours: 2)), true),
    Transaction('Sent to @creator456', -25.0, DateTime.now().subtract(Duration(hours: 5)), false),
    Transaction('Reward from video', 15.0, DateTime.now().subtract(Duration(days: 1)), true),
    Transaction('Purchase - Premium Filter', -10.0, DateTime.now().subtract(Duration(days: 2)), false),
    Transaction('Gift from @fan789', 100.0, DateTime.now().subtract(Duration(days: 3)), true),
  ];

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
            // Balance Card
            Container(
              margin: EdgeInsets.all(20),
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
                    '\$${balance.toStringAsFixed(2)}',
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
            
            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('View All clicked!')),
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
                          transaction.isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
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
                      Text(
                        '${transaction.amount > 0 ? '+' : ''}\$${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: transaction.isIncoming ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Add Money', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter amount',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixText: '\$',
                prefixStyle: TextStyle(color: Colors.white),
              ),
              keyboardType: TextInputType.number,
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
              Navigator.pop(context);
              setState(() {
                balance += 100.0; // Mock add money
                transactions.insert(0, Transaction('Added money', 100.0, DateTime.now(), true));
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Money added successfully!'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSendMoneyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Send Money', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Username or @handle',
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Amount',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixText: '\$',
                prefixStyle: TextStyle(color: Colors.white),
              ),
              keyboardType: TextInputType.number,
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
              Navigator.pop(context);
              setState(() {
                balance -= 50.0; // Mock send money
                transactions.insert(0, Transaction('Sent to @user', -50.0, DateTime.now(), false));
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Money sent successfully!'), backgroundColor: Colors.green),
              );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Transaction History clicked!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.white),
              title: Text('Payment Methods', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment Methods clicked!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.security, color: Colors.white),
              title: Text('Security Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Security Settings clicked!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Transaction {
  final String description;
  final double amount;
  final DateTime date;
  final bool isIncoming;

  Transaction(this.description, this.amount, this.date, this.isIncoming);
}