import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'api_client.dart';

class PurchaseService {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static final ApiClient _apiClient = ApiClient();
  static late StreamSubscription<List<PurchaseDetails>> _subscription;
  static bool _isAvailable = false;

  // Product IDs for virtual coins
  static const Set<String> _productIds = {
    'coins_100',
    'coins_500',
    'coins_1000',
    'coins_5000',
  };

  static List<ProductDetails> _products = [];
  static final StreamController<PurchaseResult> _purchaseController = 
      StreamController<PurchaseResult>.broadcast();

  static Stream<PurchaseResult> get purchaseStream => _purchaseController.stream;

  static Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (!_isAvailable) {
      debugPrint('In-app purchases not available');
      return;
    }

    if (Platform.isAndroid) {
      // Android-specific initialization if needed
    }

    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription.cancel(),
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );

    await _loadProducts();
  }

  static Future<void> _loadProducts() async {
    if (!_isAvailable) return;

    final ProductDetailsResponse response = 
        await _inAppPurchase.queryProductDetails(_productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
  }

  static List<ProductDetails> getProducts() => _products;

  static Future<void> purchaseCoins(String productId) async {
    if (!_isAvailable) {
      _purchaseController.add(PurchaseResult(
        success: false,
        message: 'In-app purchases not available',
      ));
      return;
    }

    final ProductDetails? product = _products
        .where((p) => p.id == productId)
        .firstOrNull;

    if (product == null) {
      _purchaseController.add(PurchaseResult(
        success: false,
        message: 'Product not found',
      ));
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    
    try {
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _purchaseController.add(PurchaseResult(
        success: false,
        message: 'Purchase failed: $e',
      ));
    }
  }

  static Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      await _processPurchase(purchase);
    }
  }

  static Future<void> _processPurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased) {
      // Validate purchase with backend
      final validationResult = await _validatePurchase(purchase);
      
      if (validationResult['success']) {
        _purchaseController.add(PurchaseResult(
          success: true,
          message: 'Purchase successful!',
          coins: validationResult['coins'],
        ));
      } else {
        _purchaseController.add(PurchaseResult(
          success: false,
          message: validationResult['message'] ?? 'Purchase validation failed',
        ));
      }

      // Complete the purchase
      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    } else if (purchase.status == PurchaseStatus.error) {
      _purchaseController.add(PurchaseResult(
        success: false,
        message: purchase.error?.message ?? 'Purchase failed',
      ));
    } else if (purchase.status == PurchaseStatus.canceled) {
      _purchaseController.add(PurchaseResult(
        success: false,
        message: 'Purchase canceled',
      ));
    }
  }

  static Future<Map<String, dynamic>> _validatePurchase(PurchaseDetails purchase) async {
    try {
      final response = await _apiClient.post('/wallet/purchase/validate', data: {
        'productId': purchase.productID,
        'purchaseToken': purchase.verificationData.serverVerificationData,
        'orderId': purchase.purchaseID,
        'platform': Platform.isAndroid ? 'android' : 'ios',
      });

      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'],
        'coins': response.data['data']?['coins'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Validation error: $e',
      };
    }
  }

  static Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _purchaseController.add(PurchaseResult(
        success: false,
        message: 'Restore failed: $e',
      ));
    }
  }

  static void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }

  static Map<String, int> getCoinsForProduct(String productId) {
    const coinMap = {
      'coins_100': 100,
      'coins_500': 500,
      'coins_1000': 1000,
      'coins_5000': 5000,
    };
    return {productId: coinMap[productId] ?? 0};
  }
}

class PurchaseResult {
  final bool success;
  final String message;
  final int? coins;

  PurchaseResult({
    required this.success,
    required this.message,
    this.coins,
  });
}
