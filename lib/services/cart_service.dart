class CartService {
  static final List<Map<String, dynamic>> _cartItems = [];

  static List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);

  static int get itemCount => _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));

  static double get totalPrice => _cartItems.fold(0.0, (sum, item) => 
    sum + ((item['product']['price'] as num) * (item['quantity'] as int)));

  static void addToCart(Map<String, dynamic> product, int quantity) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item['product']['id'] == product['id'],
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex]['quantity'] += quantity;
    } else {
      _cartItems.add({
        'product': product,
        'quantity': quantity,
      });
    }
  }

  static void updateQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere(
      (item) => item['product']['id'] == productId,
    );

    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index]['quantity'] = quantity;
      }
    }
  }

  static void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item['product']['id'] == productId);
  }

  static void clearCart() {
    _cartItems.clear();
  }

  static bool isInCart(String productId) {
    return _cartItems.any((item) => item['product']['id'] == productId);
  }

  static int getQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item['product']['id'] == productId,
      orElse: () => {'quantity': 0},
    );
    return item['quantity'] as int;
  }
}
