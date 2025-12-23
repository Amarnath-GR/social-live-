import 'package:flutter/material.dart';
import '../models/commerce_models.dart';
import '../services/commerce_service.dart';

class CommerceController extends ChangeNotifier {
  // State management
  bool _isLoading = false;
  String? _error;
  
  // Data
  List<Product> _products = [];
  List<Order> _orders = [];
  List<Refund> _refunds = [];
  SellerDashboardData? _dashboardData;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Product> get products => _products;
  List<Order> get orders => _orders;
  List<Refund> get refunds => _refunds;
  SellerDashboardData? get dashboardData => _dashboardData;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // INVENTORY MANAGEMENT
  Future<bool> loadInventory(String sellerId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await CommerceService.getInventory(sellerId);
      if (result['success']) {
        _products = result['products'];
        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addProduct(Product product) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await CommerceService.addProduct(product);
      if (result['success']) {
        _products.add(result['product']);
        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProduct(String productId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await CommerceService.updateProduct(productId, updates);
      if (result['success']) {
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = result['product'];
        }
        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateStock(String productId, int quantity) async {
    try {
      final result = await CommerceService.updateStock(productId, quantity);
      if (result['success']) {
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          // Update local product stock
          final product = _products[index];
          _products[index] = Product(
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            stock: quantity,
            sellerId: product.sellerId,
            status: product.status,
            images: product.images,
            metadata: product.metadata,
            createdAt: product.createdAt,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ORDER MANAGEMENT
  Future<bool> loadOrders(String sellerId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await CommerceService.getOrdersBySeller(sellerId);
      if (result['success']) {
        _orders = result['orders'];
        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createOrder({
    required String customerId,
    required List<OrderItem> items,
    required Map<String, dynamic> shippingAddress,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await CommerceService.createOrder(
        customerId: customerId,
        items: items,
        shippingAddress: shippingAddress,
      );
      if (result['success']) {
        _orders.insert(0, result['order']);
        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final result = await CommerceService.updateOrderStatus(orderId, status);
      if (result['success']) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = result['order'];
          notifyListeners();
        }
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> shipOrder(String orderId, {String? trackingNumber}) async {
    try {
      final result = await CommerceService.shipOrder(orderId, trackingNumber: trackingNumber);
      if (result['success']) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = result['order'];
          notifyListeners();
        }
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // REFUND MANAGEMENT
  Future<bool> loadRefunds(String sellerId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await CommerceService.getPendingRefunds(sellerId);
      if (result['success']) {
        _refunds = result['refunds'];
        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> requestRefund({
    required String orderId,
    required double amount,
    required String reason,
  }) async {
    try {
      final result = await CommerceService.requestRefund(
        orderId: orderId,
        amount: amount,
        reason: reason,
      );
      if (result['success']) {
        _refunds.insert(0, result['refund']);
        notifyListeners();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> approveRefund(String refundId) async {
    try {
      final result = await CommerceService.approveRefund(refundId);
      if (result['success']) {
        final index = _refunds.indexWhere((r) => r.id == refundId);
        if (index != -1) {
          _refunds[index] = result['refund'];
          notifyListeners();
        }
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> processRefund(String refundId) async {
    try {
      final result = await CommerceService.processRefund(refundId);
      if (result['success']) {
        final index = _refunds.indexWhere((r) => r.id == refundId);
        if (index != -1) {
          _refunds[index] = result['refund'];
          notifyListeners();
        }
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // DASHBOARD
  Future<bool> loadDashboardData(String sellerId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await CommerceService.getDashboardData(sellerId);
      if (result['success']) {
        _dashboardData = result['data'];
        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ANALYTICS
  Future<Map<String, dynamic>?> getSalesAnalytics(String sellerId, DateTime startDate, DateTime endDate) async {
    try {
      final result = await CommerceService.getSalesAnalytics(sellerId, startDate, endDate);
      if (result['success']) {
        return result['analytics'];
      } else {
        _setError(result['message']);
        return null;
      }
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<List<Product>?> getTopProducts(String sellerId) async {
    try {
      final result = await CommerceService.getTopProducts(sellerId);
      if (result['success']) {
        return result['products'];
      } else {
        _setError(result['message']);
        return null;
      }
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // TAX CALCULATIONS
  Future<TaxCalculation?> calculateTax(double amount, Map<String, dynamic> address) async {
    try {
      final result = await CommerceService.calculateTax(amount, address);
      if (result['success']) {
        return result['tax'];
      } else {
        _setError(result['message']);
        return null;
      }
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // UTILITY METHODS
  List<Product> getLowStockProducts({int threshold = 10}) {
    return _products.where((product) => product.stock <= threshold).toList();
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<Refund> getRefundsByStatus(RefundStatus status) {
    return _refunds.where((refund) => refund.status == status).toList();
  }

  double getTotalRevenue() {
    return _orders
        .where((order) => order.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.total);
  }

  int getPendingOrdersCount() {
    return _orders.where((order) => order.status == OrderStatus.pending).length;
  }
}
