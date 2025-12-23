import '../models/commerce_models.dart';
import 'inventory_service.dart';
import 'order_lifecycle_service.dart';
import 'refund_service.dart';
import 'tax_service.dart';
import 'seller_dashboard_service.dart';

class CommerceService {
  // Inventory Management
  static Future<Map<String, dynamic>> getInventory(String sellerId) =>
      InventoryService.getInventory(sellerId);

  static Future<Map<String, dynamic>> updateStock(String productId, int quantity) =>
      InventoryService.updateStock(productId, quantity);

  static Future<Map<String, dynamic>> addProduct(Product product) =>
      InventoryService.addProduct(product);

  static Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> updates) =>
      InventoryService.updateProduct(productId, updates);

  static Future<Map<String, dynamic>> getLowStockProducts(String sellerId) =>
      InventoryService.getLowStockProducts(sellerId);

  // Order Lifecycle
  static Future<Map<String, dynamic>> createOrder({
    required String customerId,
    required List<OrderItem> items,
    required Map<String, dynamic> shippingAddress,
  }) => OrderLifecycleService.createOrder(
    customerId: customerId,
    items: items,
    shippingAddress: shippingAddress,
  );

  static Future<Map<String, dynamic>> getOrder(String orderId) =>
      OrderLifecycleService.getOrder(orderId);

  static Future<Map<String, dynamic>> updateOrderStatus(String orderId, OrderStatus status) =>
      OrderLifecycleService.updateOrderStatus(orderId, status);

  static Future<Map<String, dynamic>> cancelOrder(String orderId, String reason) =>
      OrderLifecycleService.cancelOrder(orderId, reason);

  static Future<Map<String, dynamic>> shipOrder(String orderId, {String? trackingNumber}) =>
      OrderLifecycleService.shipOrder(orderId, trackingNumber: trackingNumber);

  // Refunds
  static Future<Map<String, dynamic>> requestRefund({
    required String orderId,
    required double amount,
    required String reason,
  }) => RefundService.requestRefund(
    orderId: orderId,
    amount: amount,
    reason: reason,
  );

  static Future<Map<String, dynamic>> approveRefund(String refundId) =>
      RefundService.approveRefund(refundId);

  static Future<Map<String, dynamic>> processRefund(String refundId) =>
      RefundService.processRefund(refundId);

  static Future<Map<String, dynamic>> getPendingRefunds(String sellerId) =>
      RefundService.getPendingRefunds(sellerId);

  // Tax Handling
  static Future<Map<String, dynamic>> calculateTax(double amount, Map<String, dynamic> address) =>
      TaxService.calculateTax(amount, address);

  static Future<Map<String, dynamic>> getTaxRates(String jurisdiction) =>
      TaxService.getTaxRates(jurisdiction);

  // Seller Dashboard
  static Future<Map<String, dynamic>> getDashboardData(String sellerId) =>
      SellerDashboardService.getDashboardData(sellerId);

  static Future<Map<String, dynamic>> getSalesAnalytics(String sellerId, DateTime startDate, DateTime endDate) =>
      SellerDashboardService.getSalesAnalytics(sellerId, startDate, endDate);

  static Future<Map<String, dynamic>> getTopProducts(String sellerId) =>
      SellerDashboardService.getTopProducts(sellerId);

  static Future<Map<String, dynamic>> getRevenueReport(String sellerId, String period) =>
      SellerDashboardService.getRevenueReport(sellerId, period);

  static Future<Map<String, dynamic>> getOrdersBySeller(String sellerId) =>
      OrderLifecycleService.getOrdersBySeller(sellerId);

  // Complete order flow
  static Future<Map<String, dynamic>> processCompleteOrder({
    required String customerId,
    required List<Map<String, dynamic>> cartItems,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethodId,
  }) async {
    try {
      // Convert cart items to order items
      final orderItems = cartItems.map((item) => OrderItem(
        productId: item['productId'],
        productName: item['productName'],
        quantity: item['quantity'],
        price: item['price'].toDouble(),
        total: item['quantity'] * item['price'].toDouble(),
      )).toList();

      // Create order
      final orderResult = await createOrder(
        customerId: customerId,
        items: orderItems,
        shippingAddress: shippingAddress,
      );

      if (!orderResult['success']) {
        return orderResult;
      }

      final order = orderResult['order'] as Order;

      // Process payment (integrate with existing payment service)
      // This would typically call PaymentService.processPayment()

      // Confirm order after successful payment
      await updateOrderStatus(order.id, OrderStatus.confirmed);

      return {'success': true, 'order': order};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
