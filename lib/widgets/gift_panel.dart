import 'package:flutter/material.dart';
import '../services/gift_service.dart';
import '../services/wallet_service.dart';

class GiftPanel extends StatefulWidget {
  final String streamId;
  final Function(Map<String, dynamic>) onGiftSent;

  const GiftPanel({
    super.key,
    required this.streamId,
    required this.onGiftSent,
  });

  @override
  State<GiftPanel> createState() => _GiftPanelState();
}

class _GiftPanelState extends State<GiftPanel> {
  int _currentBalance = 0;
  bool _isLoading = false;
  String? _selectedGiftId;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final result = await WalletService.getBalance('user-account-id');
    if (mounted) {
      setState(() {
        _currentBalance = result['success'] ? result['balance'] ?? 0 : 0;
      });
    }
  }

  Future<void> _sendGift(Map<String, dynamic> gift) async {
    if (_isLoading) return;

    final totalCost = gift['cost'] * _quantity;
    if (totalCost > _currentBalance) {
      _showInsufficientFundsDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await GiftService.sendGift(
      streamId: widget.streamId,
      giftId: gift['id'],
      quantity: _quantity,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      setState(() {
        _currentBalance = result['newBalance'] ?? _currentBalance;
        _quantity = 1;
        _selectedGiftId = null;
      });
      
      widget.onGiftSent({
        ...gift,
        'quantity': _quantity,
      });

      Navigator.of(context).pop();
    } else {
      _showErrorDialog(result['message'] ?? 'Failed to send gift');
    }
  }

  void _showInsufficientFundsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Coins'),
        content: const Text('You don\'t have enough coins to send this gift. Please buy more coins.'),
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
        title: const Text('Error'),
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Send Gift',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet, 
                         color: Colors.amber[700], size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$_currentBalance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Gift grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: GiftService.availableGifts.length,
              itemBuilder: (context, index) {
                final gift = GiftService.availableGifts[index];
                final isSelected = _selectedGiftId == gift['id'];
                final canAfford = (gift['cost'] * _quantity) <= _currentBalance;

                return GestureDetector(
                  onTap: canAfford ? () {
                    setState(() {
                      _selectedGiftId = gift['id'];
                    });
                  } : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Color(gift['color']).withValues(alpha: 0.1) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Color(gift['color']) : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          gift['emoji'],
                          style: TextStyle(
                            fontSize: 32,
                            color: canAfford ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gift['name'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: canAfford ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              size: 12,
                              color: canAfford ? Colors.amber[700] : Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${gift['cost']}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: canAfford ? Colors.amber[700] : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Quantity and send section
          if (_selectedGiftId != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                children: [
                  // Quantity selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Quantity: ', style: TextStyle(fontSize: 16)),
                      IconButton(
                        onPressed: _quantity > 1 ? () {
                          setState(() {
                            _quantity--;
                          });
                        } : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final gift = GiftService.availableGifts
                              .firstWhere((g) => g['id'] == _selectedGiftId);
                          if ((gift['cost'] * (_quantity + 1)) <= _currentBalance) {
                            setState(() {
                              _quantity++;
                            });
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Send button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        final gift = GiftService.availableGifts
                            .firstWhere((g) => g['id'] == _selectedGiftId);
                        _sendGift(gift);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Send Gift (${GiftService.availableGifts.firstWhere((g) => g['id'] == _selectedGiftId)['cost'] * _quantity} coins)',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
