import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Income', 'Expenses', 'Tokens', 'Cash'];
  
  final List<Transaction> _allTransactions = [
    Transaction('Received from @user123', 50.0, DateTime.now().subtract(Duration(hours: 2)), true, isToken: false),
    Transaction('Earned tokens from video', 150, DateTime.now().subtract(Duration(hours: 3)), true, isToken: true),
    Transaction('Sent to @creator456', -25.0, DateTime.now().subtract(Duration(hours: 5)), false, isToken: false),
    Transaction('Purchased product with tokens', -200, DateTime.now().subtract(Duration(hours: 6)), false, isToken: true),
    Transaction('Reward from video', 15.0, DateTime.now().subtract(Duration(days: 1)), true, isToken: false),
    Transaction('Gift tokens from @fan789', 300, DateTime.now().subtract(Duration(days: 2)), true, isToken: true),
    Transaction('Purchase - Premium Filter', -10.0, DateTime.now().subtract(Duration(days: 2)), false, isToken: false),
    Transaction('Live stream tips', 500, DateTime.now().subtract(Duration(days: 3)), true, isToken: true),
    Transaction('Added money', 100.0, DateTime.now().subtract(Duration(days: 4)), true, isToken: false),
    Transaction('Withdrawal to bank', -200.0, DateTime.now().subtract(Duration(days: 5)), false, isToken: false),
    Transaction('Video monetization', 75.0, DateTime.now().subtract(Duration(days: 6)), true, isToken: false),
    Transaction('Bought tokens', 1000, DateTime.now().subtract(Duration(days: 7)), true, isToken: true),
  ];

  List<Transaction> get _filteredTransactions {
    switch (_selectedFilter) {
      case 'Income':
        return _allTransactions.where((t) => t.isIncoming).toList();
      case 'Expenses':
        return _allTransactions.where((t) => !t.isIncoming).toList();
      case 'Tokens':
        return _allTransactions.where((t) => t.isToken).toList();
      case 'Cash':
        return _allTransactions.where((t) => !t.isToken).toList();
      default:
        return _allTransactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Transaction History', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: _exportTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                    backgroundColor: Colors.grey[800],
                    selectedColor: Colors.purple,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Summary Cards
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Income',
                    _calculateTotal(true),
                    Colors.green,
                    Icons.trending_up,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Expenses',
                    _calculateTotal(false),
                    Colors.red,
                    Icons.trending_down,
                  ),
                ),
              ],
            ),
          ),
          
          // Transactions List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _filteredTransactions[index];
                return _buildTransactionItem(transaction);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
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
              color: transaction.isIncoming 
                ? Colors.green.withOpacity(0.2) 
                : Colors.red.withOpacity(0.2),
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
                  : '${transaction.amount > 0 ? '+' : ''}\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: transaction.isIncoming ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (transaction.isToken)
                Text(
                  '≈ \$${(transaction.amount * 0.02).toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateTotal(bool isIncoming) {
    return _filteredTransactions
        .where((t) => t.isIncoming == isIncoming)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
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

  void _exportTransactions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Export Transactions', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text('Export as PDF', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PDF export started')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: Colors.green),
              title: Text('Export as CSV', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('CSV export started')),
                );
              },
            ),
          ],
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
}

class Transaction {
  final String description;
  final double amount;
  final DateTime date;
  final bool isIncoming;
  final bool isToken;

  Transaction(this.description, this.amount, this.date, this.isIncoming, {this.isToken = false});
}