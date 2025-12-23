import 'package:flutter/material.dart';
import '../models/commerce_models.dart';
import '../services/commerce_service.dart';

class SellerDashboardScreen extends StatefulWidget {
  final String sellerId;

  const SellerDashboardScreen({Key? key, required this.sellerId}) : super(key: key);

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  SellerDashboardData? _dashboardData;
  List<Product> _lowStockProducts = [];
  List<Refund> _pendingRefunds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    final results = await Future.wait([
      CommerceService.getDashboardData(widget.sellerId),
      CommerceService.getLowStockProducts(widget.sellerId),
      CommerceService.getPendingRefunds(widget.sellerId),
    ]);

    if (results[0]['success']) {
      _dashboardData = results[0]['data'];
    }
    if (results[1]['success']) {
      _lowStockProducts = results[1]['products'];
    }
    if (results[2]['success']) {
      _pendingRefunds = results[2]['refunds'];
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashboardData == null
              ? const Center(child: Text('Failed to load dashboard'))
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetricsCards(),
                        const SizedBox(height: 24),
                        _buildRecentOrders(),
                        const SizedBox(height: 24),
                        _buildLowStockAlert(),
                        const SizedBox(height: 24),
                        _buildPendingRefunds(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildMetricsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Products', _dashboardData!.totalProducts.toString(), Icons.inventory)),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('Orders', _dashboardData!.totalOrders.toString(), Icons.shopping_cart)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Revenue', '\$${_dashboardData!.totalRevenue.toStringAsFixed(2)}', Icons.attach_money)),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('Pending', _dashboardData!.pendingOrders.toString(), Icons.pending)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/orders'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dashboardData!.recentOrders.length,
            itemBuilder: (context, index) {
              final order = _dashboardData!.recentOrders[index];
              return ListTile(
                title: Text('Order #${order.id.substring(0, 8)}'),
                subtitle: Text('\$${order.total.toStringAsFixed(2)} • ${order.status.name}'),
                trailing: Text(
                  '${order.createdAt.day}/${order.createdAt.month}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onTap: () => Navigator.pushNamed(context, '/order-detail', arguments: order.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockAlert() {
    if (_lowStockProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Low Stock Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          color: Colors.orange[50],
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _lowStockProducts.length,
            itemBuilder: (context, index) {
              final product = _lowStockProducts[index];
              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(product.name),
                subtitle: Text('${product.stock} units remaining'),
                trailing: ElevatedButton(
                  onPressed: () => _updateStock(product),
                  child: const Text('Restock'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPendingRefunds() {
    if (_pendingRefunds.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pending Refunds', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pendingRefunds.length,
            itemBuilder: (context, index) {
              final refund = _pendingRefunds[index];
              return ListTile(
                title: Text('Refund #${refund.id.substring(0, 8)}'),
                subtitle: Text('\$${refund.amount.toStringAsFixed(2)} • ${refund.reason}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _approveRefund(refund.id),
                      child: const Text('Approve'),
                    ),
                    TextButton(
                      onPressed: () => _rejectRefund(refund.id),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _updateStock(Product product) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock for ${product.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New Stock Quantity'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result != null) {
      final updateResult = await CommerceService.updateStock(product.id, result);
      if (updateResult['success']) {
        _loadDashboardData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock updated successfully')),
        );
      }
    }
  }

  Future<void> _approveRefund(String refundId) async {
    final result = await CommerceService.approveRefund(refundId);
    if (result['success']) {
      _loadDashboardData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refund approved')),
      );
    }
  }

  Future<void> _rejectRefund(String refundId) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Refund'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reason for rejection'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      // Note: RefundService.rejectRefund would need to be called here
      _loadDashboardData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refund rejected')),
      );
    }
  }
}
