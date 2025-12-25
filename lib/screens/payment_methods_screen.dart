import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: '1',
      type: PaymentMethodType.card,
      name: 'Visa ending in 4242',
      details: '**** **** **** 4242',
      isDefault: true,
      expiryDate: '12/25',
    ),
    PaymentMethod(
      id: '2',
      type: PaymentMethodType.card,
      name: 'Mastercard ending in 8888',
      details: '**** **** **** 8888',
      isDefault: false,
      expiryDate: '08/26',
    ),
    PaymentMethod(
      id: '3',
      type: PaymentMethodType.paypal,
      name: 'PayPal',
      details: 'user@example.com',
      isDefault: false,
    ),
    PaymentMethod(
      id: '4',
      type: PaymentMethodType.bank,
      name: 'Bank Account',
      details: 'Chase Bank ****1234',
      isDefault: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Payment Methods', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddPaymentMethodDialog,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Your Payment Methods',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)),
          
          SizedBox(height: 20),
          
          ElevatedButton.icon(
            onPressed: _showAddPaymentMethodDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text('Add Payment Method', style: TextStyle(color: Colors.white)),
          ),
          
          SizedBox(height: 24),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your payment information is encrypted and secure',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.verified_user, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'We never store your full card details',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: method.isDefault 
          ? Border.all(color: Colors.purple, width: 2)
          : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getMethodColor(method.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getMethodIcon(method.type),
              color: _getMethodColor(method.type),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (method.isDefault) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  method.details,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                if (method.expiryDate != null) ...[
                  SizedBox(height: 4),
                  Text(
                    'Expires ${method.expiryDate}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[400]),
            color: Colors.grey[800],
            onSelected: (value) => _handleMenuAction(value, method),
            itemBuilder: (context) => [
              if (!method.isDefault)
                PopupMenuItem(
                  value: 'set_default',
                  child: Text('Set as Default', style: TextStyle(color: Colors.white)),
                ),
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit', style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMethodIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethodType.bank:
        return Icons.account_balance;
      case PaymentMethodType.apple:
        return Icons.phone_iphone;
      case PaymentMethodType.google:
        return Icons.android;
    }
  }

  Color _getMethodColor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.card:
        return Colors.blue;
      case PaymentMethodType.paypal:
        return Colors.orange;
      case PaymentMethodType.bank:
        return Colors.green;
      case PaymentMethodType.apple:
        return Colors.grey;
      case PaymentMethodType.google:
        return Colors.red;
    }
  }

  void _handleMenuAction(String action, PaymentMethod method) {
    switch (action) {
      case 'set_default':
        setState(() {
          for (var m in _paymentMethods) {
            m.isDefault = m.id == method.id;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${method.name} set as default'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case 'edit':
        _showEditPaymentMethodDialog(method);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(method);
        break;
    }
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Add Payment Method', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.blue),
              title: Text('Credit/Debit Card', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAddCardDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet, color: Colors.orange),
              title: Text('PayPal', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAddPayPalDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance, color: Colors.green),
              title: Text('Bank Account', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAddBankDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.phone_iphone, color: Colors.grey),
              title: Text('Apple Pay', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Apple Pay integration coming soon')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.android, color: Colors.red),
              title: Text('Google Pay', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Google Pay integration coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCardDialog() {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Add Credit/Debit Card', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cardNumberController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Card Number',
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintText: '1234 5678 9012 3456',
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expiryController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'MM/YY',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      hintText: '12/25',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: cvvController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      hintText: '123',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintText: 'John Doe',
                hintStyle: TextStyle(color: Colors.grey[600]),
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
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _paymentMethods.add(PaymentMethod(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: PaymentMethodType.card,
                  name: 'Card ending in ${cardNumberController.text.substring(cardNumberController.text.length - 4)}',
                  details: '**** **** **** ${cardNumberController.text.substring(cardNumberController.text.length - 4)}',
                  isDefault: false,
                  expiryDate: expiryController.text,
                ));
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Card added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Add Card', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddPayPalDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Add PayPal Account', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'PayPal Email',
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintText: 'your@email.com',
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
              keyboardType: TextInputType.emailAddress,
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
                _paymentMethods.add(PaymentMethod(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: PaymentMethodType.paypal,
                  name: 'PayPal',
                  details: emailController.text,
                  isDefault: false,
                ));
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('PayPal account added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Add PayPal', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddBankDialog() {
    final routingController = TextEditingController();
    final accountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Add Bank Account', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: routingController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Routing Number',
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintText: '123456789',
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: accountController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Account Number',
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintText: '1234567890',
                hintStyle: TextStyle(color: Colors.grey[600]),
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
                _paymentMethods.add(PaymentMethod(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: PaymentMethodType.bank,
                  name: 'Bank Account',
                  details: 'Account ****${accountController.text.substring(accountController.text.length - 4)}',
                  isDefault: false,
                ));
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bank account added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Add Account', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditPaymentMethodDialog(PaymentMethod method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${method.name} - Feature coming soon')),
    );
  }

  void _showDeleteConfirmationDialog(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete Payment Method', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${method.name}?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _paymentMethods.removeWhere((m) => m.id == method.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${method.name} deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

enum PaymentMethodType { card, paypal, bank, apple, google }

class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String name;
  final String details;
  bool isDefault;
  final String? expiryDate;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.details,
    required this.isDefault,
    this.expiryDate,
  });
}