import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service.dart';
import '../services/order_service.dart';
import '../services/cart_service.dart';
import '../services/wallet_service.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> orderItems;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.orderItems,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isProcessing = false;
  String _cardType = '';
  bool _saveCard = false;
  String _paymentMethod = 'money'; // 'money' or 'tokens'
  double _walletBalance = 0.0;
  final WalletService _walletService = WalletService();

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final balance = await _walletService.getBalance();
      setState(() {
        _walletBalance = balance;
      });
    } catch (e) {
      print('Error loading wallet balance: $e');
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged(String value) {
    setState(() {
      _cardType = PaymentService.getCardType(value);
    });
  }

  Future<void> _processPayment() async {
    if (_paymentMethod == 'tokens') {
      await _processTokenPayment();
    } else {
      await _processCardPayment();
    }
  }

  Future<void> _processTokenPayment() async {
    setState(() => _isProcessing = true);

    try {
      // Check if user has enough tokens
      if (_walletBalance < widget.totalAmount) {
        _showErrorDialog('Insufficient tokens. You need \$${widget.totalAmount.toStringAsFixed(2)} but only have \$${_walletBalance.toStringAsFixed(2)}');
        return;
      }

      // Create order first
      final orderResult = await OrderService.createOrder(
        items: widget.orderItems,
        shippingAddress: {
          'name': 'Token Purchase',
          'address': 'Digital Product',
          'city': 'Digital',
          'country': 'Digital',
        },
      );

      if (!orderResult['success']) {
        _showErrorDialog(orderResult['message']);
        return;
      }

      final orderId = orderResult['order']['id'];

      // Process token payment
      await _walletService.purchaseProduct(orderId, 1);
      
      // Clear cart and show success
      CartService.clearCart();
      _showSuccessDialog(orderId);
    } catch (e) {
      _showErrorDialog('Token payment failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processCardPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      // Validate card details
      final validation = PaymentService.validateCardDetails(
        cardNumber: _cardNumberController.text,
        expiryMonth: _expiryController.text.split('/')[0],
        expiryYear: '20${_expiryController.text.split('/')[1]}',
        cvv: _cvvController.text,
      );

      if (!validation['isValid']) {
        _showErrorDialog(validation['errors'].join('\n'));
        return;
      }

      // Create order first
      final orderResult = await OrderService.createOrder(
        items: widget.orderItems,
        shippingAddress: {
          'name': _nameController.text,
          'address': 'Digital Product', // For digital products
          'city': 'Digital',
          'country': 'Digital',
        },
      );

      if (!orderResult['success']) {
        _showErrorDialog(orderResult['message']);
        return;
      }

      final orderId = orderResult['order']['id'];

      // Create payment intent
      final paymentIntentResult = await PaymentService.createPaymentIntent(
        amount: widget.totalAmount,
        currency: 'usd',
        orderId: orderId,
        metadata: {
          'order_id': orderId,
          'customer_name': _nameController.text,
        },
      );

      if (!paymentIntentResult['success']) {
        _showErrorDialog(paymentIntentResult['message']);
        return;
      }

      // Simulate payment confirmation (in real app, use Stripe SDK)
      final confirmResult = await PaymentService.confirmPayment(
        paymentIntentId: paymentIntentResult['paymentIntentId'],
        paymentMethodId: 'pm_card_visa', // Mock payment method
      );

      if (confirmResult['success']) {
        // Clear cart and show success
        CartService.clearCart();
        _showSuccessDialog(orderId);
      } else {
        _showErrorDialog(confirmResult['message']);
      }
    } catch (e) {
      _showErrorDialog('Payment processing failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text('Order ID: $orderId'),
            const SizedBox(height: 8),
            const Text('Your order has been placed successfully.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to marketplace
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...widget.orderItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item['product']['name']} x${item['quantity']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '\$${((item['product']['price'] as num) * (item['quantity'] as int)).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${widget.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method Selection
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: _paymentMethod == 'money' ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                      child: InkWell(
                        onTap: () => setState(() => _paymentMethod = 'money'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 32,
                                color: _paymentMethod == 'money' ? Theme.of(context).primaryColor : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Credit Card',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _paymentMethod == 'money' ? Theme.of(context).primaryColor : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      color: _paymentMethod == 'tokens' ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                      child: InkWell(
                        onTap: () => setState(() => _paymentMethod = 'tokens'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                size: 32,
                                color: _paymentMethod == 'tokens' ? Theme.of(context).primaryColor : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Wallet Tokens',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _paymentMethod == 'tokens' ? Theme.of(context).primaryColor : Colors.grey,
                                ),
                              ),
                              Text(
                                '\$${_walletBalance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _paymentMethod == 'tokens' ? Theme.of(context).primaryColor : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Payment Form (only show for card payments)
              if (_paymentMethod == 'money') ...[
              const Text(
                'Payment Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Cardholder Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardholder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.credit_card),
                  suffixIcon: _cardType.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _cardType,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                  _CardNumberFormatter(),
                ],
                onChanged: _onCardNumberChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  final cleanValue = value.replaceAll(' ', '');
                  if (cleanValue.length < 13) {
                    return 'Card number is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Expiry and CVV
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'MM/YY',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length < 5) {
                          return 'Invalid format';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length < 3) {
                          return 'Invalid CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Save Card Checkbox
              CheckboxListTile(
                title: const Text('Save card for future purchases'),
                value: _saveCard,
                onChanged: (value) => setState(() => _saveCard = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              ],
              
              // Token payment info
              if (_paymentMethod == 'tokens') ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Token Payment',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Balance:'),
                            Text(
                              '\$${_walletBalance.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Required Amount:'),
                            Text(
                              '\$${widget.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('After Purchase:'),
                            Text(
                              '\$${(_walletBalance - widget.totalAmount).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: (_walletBalance - widget.totalAmount) >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        if (_walletBalance < widget.totalAmount) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Insufficient tokens. Please add \$${(widget.totalAmount - _walletBalance).toStringAsFixed(2)} to your wallet.',
                                    style: const TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Payment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _paymentMethod == 'tokens' 
                            ? 'Pay with Tokens \$${widget.totalAmount.toStringAsFixed(2)}'
                            : 'Pay \$${widget.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your payment information is secure and encrypted.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Card number formatter
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Expiry date formatter
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
